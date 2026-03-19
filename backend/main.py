from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime, timezone
from models import ReportInput, VolunteerCheckIn, ReportResponse
from firebase import db, REPORTS_COLLECTION, CHECKINS_COLLECTION
import uuid

# ── App Setup ──────────────────────────────────────────────────────────────────
app = FastAPI(
    title="HeatMap API",
    description="Dynamic Geospatial Intelligence Layer — NGO Emergency Response",
    version="1.0.0"
)

# CORS — allows Flutter Web and mobile to talk to this API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Tighten this in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Health Check ───────────────────────────────────────────────────────────────
@app.get("/")
def root():
    return {"status": "HeatMap API is running 🔥"}


@app.get("/health")
def health():
    return {"status": "ok", "timestamp": datetime.now(timezone.utc).isoformat()}


# ── POST /report — Receive a new crisis report ─────────────────────────────────
@app.post("/report", response_model=ReportResponse)
def create_report(report: ReportInput):
    """
    Receives a crisis report from Gemini's severity function.
    Minimum required: latitude, longitude, severity (1-10).
    Optional: category, report_id, volunteer_id, timestamp.
    Stores it in Firestore → Flutter Web map updates in real time.
    """
    try:
        # Generate a unique ID if not provided
        doc_id = report.report_id or str(uuid.uuid4())

        # Map severity score (1-10) to heat intensity (0.0-1.0)
        intensity = round(report.severity / 10, 2)

        # Determine zone color label
        if report.severity <= 3:
            zone = "green"
        elif report.severity <= 6:
            zone = "yellow"
        else:
            zone = "red"

        # Build the Firestore document
        doc = {
            "id": doc_id,
            "latitude": report.latitude,
            "longitude": report.longitude,
            "severity": report.severity,
            "intensity": intensity,        # Used by the heatmap layer (0.0 - 1.0)
            "zone": zone,                  # green / yellow / red
            "category": report.category,  # Optional for now
            "volunteer_id": report.volunteer_id,
            "timestamp": report.timestamp or datetime.now(timezone.utc),
            "resolved": False,             # Becomes True when volunteer checks in
            "report_count": 1,             # Increments if same area reported again (Ghost Heat)
        }

        # Write to Firestore
        db.collection(REPORTS_COLLECTION).document(doc_id).set(doc)

        # Check for Ghost Heat — same area reported before?
        _check_and_flag_ghost_heat(report.latitude, report.longitude, doc_id)

        return ReportResponse(
            success=True,
            message=f"Report stored successfully. Zone: {zone.upper()}",
            data={"id": doc_id, "zone": zone, "intensity": intensity}
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ── POST /checkin — Volunteer checks in → heat decays ─────────────────────────
@app.post("/checkin", response_model=ReportResponse)
def volunteer_checkin(checkin: VolunteerCheckIn):
    """
    When a volunteer checks in at a location,
    the heat at that coordinate is marked resolved
    and disappears from the map in real time.
    """
    try:
        # Find all unresolved reports near this coordinate
        reports = db.collection(REPORTS_COLLECTION)\
            .where("resolved", "==", False)\
            .stream()

        resolved_count = 0
        RADIUS = 0.005  # ~500 meters in lat/lng degrees

        for report in reports:
            data = report.to_dict()
            lat_diff = abs(data["latitude"] - checkin.latitude)
            lng_diff = abs(data["longitude"] - checkin.longitude)

            if lat_diff <= RADIUS and lng_diff <= RADIUS:
                # Mark as resolved → Firestore listener removes it from map
                db.collection(REPORTS_COLLECTION).document(report.id).update({
                    "resolved": True,
                    "resolved_by": checkin.volunteer_id,
                    "resolved_at": datetime.now(timezone.utc),
                })
                resolved_count += 1

        # Log the check-in
        db.collection(CHECKINS_COLLECTION).add({
            "volunteer_id": checkin.volunteer_id,
            "latitude": checkin.latitude,
            "longitude": checkin.longitude,
            "report_id": checkin.report_id,
            "timestamp": datetime.now(timezone.utc),
        })

        return ReportResponse(
            success=True,
            message=f"Check-in logged. {resolved_count} report(s) resolved.",
            data={"resolved_count": resolved_count}
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ── GET /reports — Fetch all active (unresolved) reports for the map ───────────
@app.get("/reports")
def get_active_reports():
    """
    Returns all unresolved reports for the map to render.
    The Flutter Web map calls this on initial load,
    then Firestore live listeners handle updates.
    """
    try:
        reports = db.collection(REPORTS_COLLECTION)\
            .where("resolved", "==", False)\
            .stream()

        result = []
        for r in reports:
            data = r.to_dict()
            # Convert datetime to string for JSON serialization
            if "timestamp" in data and hasattr(data["timestamp"], "isoformat"):
                data["timestamp"] = data["timestamp"].isoformat()
            if "resolved_at" in data and hasattr(data.get("resolved_at"), "isoformat"):
                data["resolved_at"] = data["resolved_at"].isoformat()
            result.append(data)

        return {"success": True, "count": len(result), "reports": result}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ── GET /reports/ghost — Fetch ghost heat zones ────────────────────────────────
@app.get("/reports/ghost")
def get_ghost_heat():
    """
    Returns areas that have been repeatedly reported (3+ times).
    These are rendered as faded 'Ghost Heat' on the map
    to warn admins of escalating zones.
    """
    try:
        reports = db.collection(REPORTS_COLLECTION)\
            .where("ghost_heat", "==", True)\
            .stream()

        result = []
        for r in reports:
            data = r.to_dict()
            if "timestamp" in data and hasattr(data["timestamp"], "isoformat"):
                data["timestamp"] = data["timestamp"].isoformat()
            result.append(data)

        return {"success": True, "count": len(result), "ghost_zones": result}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ── Helper: Ghost Heat Detection ───────────────────────────────────────────────
def _check_and_flag_ghost_heat(lat: float, lng: float, current_doc_id: str):
    """
    Checks if the same area has been reported 3+ times.
    If yes, flags all reports in that area with ghost_heat = True.
    This triggers the faded heat overlay on the frontend.
    """
    RADIUS = 0.005  # ~500 meters

    reports = db.collection(REPORTS_COLLECTION)\
        .where("resolved", "==", False)\
        .stream()

    nearby = []
    for r in reports:
        data = r.to_dict()
        lat_diff = abs(data["latitude"] - lat)
        lng_diff = abs(data["longitude"] - lng)
        if lat_diff <= RADIUS and lng_diff <= RADIUS:
            nearby.append(r.id)

    # If 3 or more reports in same area → flag all as Ghost Heat
    if len(nearby) >= 3:
        for doc_id in nearby:
            db.collection(REPORTS_COLLECTION).document(doc_id).update({
                "ghost_heat": True
            })
