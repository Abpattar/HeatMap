from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime, timezone
from models import ReportInput, VolunteerCheckIn, ReportResponse, AcceptTaskInput
from firebase import db, REPORTS_COLLECTION, CHECKINS_COLLECTION
import uuid

app = FastAPI(title="HeatMap API", version="2.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {"status": "HeatMap API is running 🔥"}


@app.get("/health")
def health():
    return {"status": "ok", "timestamp": datetime.now(timezone.utc).isoformat()}


# ── POST /report ───────────────────────────────────────────────────────────────
@app.post("/report", response_model=ReportResponse)
def create_report(report: ReportInput):
    try:
        doc_id = report.report_id or str(uuid.uuid4())
        intensity = round(report.severity / 10, 2)
        zone = "green" if report.severity <= 3 else "yellow" if report.severity <= 6 else "red"

        doc = {
            "id": doc_id,
            "latitude": report.latitude,
            "longitude": report.longitude,
            "severity": report.severity,
            "intensity": intensity,
            "zone": zone,
            "category": report.category,
            "problem": report.problem or report.category or "Unknown Issue",
            "location_name": report.location_name or f"{report.latitude:.4f}, {report.longitude:.4f}",
            "volunteer_id": report.volunteer_id,
            "timestamp": report.timestamp or datetime.now(timezone.utc),
            "resolved": False,
            "report_count": 1,
            # New fields for task management
            "complaint_count": 1,       # How many users reported this
            "people_accepted": 0,       # Volunteers who accepted the task
            "task_status": "open",      # open / in_progress / resolved
        }

        db.collection(REPORTS_COLLECTION).document(doc_id).set(doc)
        _check_and_flag_ghost_heat(report.latitude, report.longitude, doc_id)

        return ReportResponse(
            success=True,
            message=f"Report stored. Zone: {zone.upper()}",
            data={"id": doc_id, "zone": zone, "intensity": intensity}
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ── POST /accept_task — Volunteer accepts a task ───────────────────────────────
@app.post("/accept_task", response_model=ReportResponse)
def accept_task(payload: AcceptTaskInput):
    """
    Volunteer taps 'Accept Task' on a report.
    Increments people_accepted and sets task_status to in_progress.
    """
    try:
        ref = db.collection(REPORTS_COLLECTION).document(payload.report_id)
        doc = ref.get()
        if not doc.exists:
            raise HTTPException(status_code=404, detail="Report not found")

        data = doc.to_dict()
        new_count = data.get("people_accepted", 0) + 1

        ref.update({
            "people_accepted": new_count,
            "task_status": "in_progress",
            "last_accepted_by": payload.volunteer_id,
            "last_accepted_at": datetime.now(timezone.utc),
        })

        return ReportResponse(
            success=True,
            message=f"Task accepted. {new_count} volunteer(s) on this.",
            data={"report_id": payload.report_id, "people_accepted": new_count}
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ── POST /checkin ──────────────────────────────────────────────────────────────
@app.post("/checkin", response_model=ReportResponse)
def volunteer_checkin(checkin: VolunteerCheckIn):
    try:
        reports = db.collection(REPORTS_COLLECTION).where("resolved", "==", False).stream()
        resolved_count = 0
        RADIUS = 0.005  # ~500 m

        for report in reports:
            data = report.to_dict()
            if (abs(data["latitude"] - checkin.latitude) <= RADIUS and
                    abs(data["longitude"] - checkin.longitude) <= RADIUS):
                db.collection(REPORTS_COLLECTION).document(report.id).update({
                    "resolved": True,
                    "task_status": "resolved",
                    "resolved_by": checkin.volunteer_id,
                    "resolved_at": datetime.now(timezone.utc),
                })
                resolved_count += 1

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


# ── GET /reports ───────────────────────────────────────────────────────────────
@app.get("/reports")
def get_active_reports():
    try:
        reports = db.collection(REPORTS_COLLECTION).where("resolved", "==", False).stream()
        result = []
        for r in reports:
            data = r.to_dict()
            for key in ("timestamp", "resolved_at", "last_accepted_at"):
                if key in data and hasattr(data[key], "isoformat"):
                    data[key] = data[key].isoformat()
            result.append(data)
        return {"success": True, "count": len(result), "reports": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ── GET /reports/ghost ─────────────────────────────────────────────────────────
@app.get("/reports/ghost")
def get_ghost_heat():
    try:
        reports = db.collection(REPORTS_COLLECTION).where("ghost_heat", "==", True).stream()
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
    RADIUS = 0.005
    reports = db.collection(REPORTS_COLLECTION).where("resolved", "==", False).stream()
    nearby = []
    for r in reports:
        data = r.to_dict()
        if (abs(data["latitude"] - lat) <= RADIUS and
                abs(data["longitude"] - lng) <= RADIUS):
            nearby.append(r.id)

    if len(nearby) >= 3:
        for doc_id in nearby:
            db.collection(REPORTS_COLLECTION).document(doc_id).update({"ghost_heat": True})
