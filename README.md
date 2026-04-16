# AURA HeatMap - NGO Emergency Response System

A real-time geospatial heat map for NGO emergency response, built with Flutter Web, Leaflet.js, FastAPI, and Firebase Firestore.

**Live Demo:** https://heat-map-ten.vercel.app/

---

## Features

- **Real-time Crisis Visualization** - Live markers for emergency incidents with severity-based colors (Red/Yellow/Green)
- **Severity-Based Ripple Effects** - All markers have animated ripples; intensity varies by severity
- **Smart Marker Clustering** - Pins automatically group when zoomed out. Clusters are colored dynamically by severity and density: colors upgrade (e.g. 7+ Green become Yellow, 8+ Yellow become Red) when areas are highly concentrated. Zooming reveals individual pins.
- **Category Filtering** - Filter incidents by type: Flood, Fire, Medical, Shelter, Food
- **Search Functionality** - Search incidents by problem description, location, category, or severity zone
- **Multi-Modal Real-Time Navigation** - Get directions to incidents via three transport modes:
  - 🚗 **Car** — Fastest highway route (solid blue line)
  - 🏍️ **Bike** — Local/cycling-friendly route (solid blue line)
  - 🚶 **Walk** — Pedestrian pathway (dotted blue line)
  - Each mode fetches a **genuinely different route** from separate OSRM profile servers with real-time distance, duration, and ETA
- **Turn-by-Turn Navigation HUD** - During active navigation, a top HUD shows the current instruction, remaining distance, and ETA. Steps auto-advance as you approach each maneuver point
- **Smart Pin Management** - During navigation, only the destination pin and critical emergency (severity ≥ 7) pins remain visible
- **GPS Location Tracking** - Real-time user location with animated blue dot and accuracy circle
- **Light/Dark Theme** - Auto-switches at 6 AM/PM, manual toggle available
- **Ghost Heat Zones** - Visualize areas with historical incident patterns
- **Mobile Optimized** - Fully responsive UI with media queries for phone, tablet, and desktop

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter Web + Leaflet.js |
| Map Tiles | Carto Voyager Light/Dark (free, no API key) |
| Routing | FOSSGIS OSRM (separate car/bike/foot servers) |
| Clustering | Leaflet.markercluster |
| Backend | FastAPI (Python) |
| Database | Firebase Firestore |
| Hosting | Vercel |

### Key Frontend Libraries

| Library | Version | Purpose |
|---------|---------|---------|
| Leaflet.js | 1.9.4 | Interactive map rendering |
| leaflet-heat | 0.2.0 | Ghost heat zone visualization |
| leaflet-routing-machine | 3.2.12 | Routing control integration |
| leaflet.markercluster | 1.5.3 | Smart pin grouping at zoom levels |

---

## Project Structure

```
heatmap/
├── backend/                 # FastAPI server
│   ├── main.py             # API endpoints
│   ├── models.py           # Pydantic models
│   ├── firebase.py         # Firestore connection
│   ├── api.py              # Vercel entry point
│   ├── firebase_key.json   # Firebase credentials (DO NOT COMMIT)
│   └── requirements.txt    # Python dependencies
│
├── frontend/               # Flutter Web app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/heatmap_screen.dart
│   │   ├── widgets/
│   │   └── services/
│   ├── web/
│   │   └── index.html      # Main map UI + logic
│   ├── build/web/          # Production build output
│   └── pubspec.yaml
│
└── README.md               # This file
```

---

## Prerequisites

- **Flutter SDK** (3.x or later)
- **Python 3.9+**
- **Firebase Project** with Firestore enabled
- **Node.js** (for Vercel CLI, optional)

---

## Local Development

### 1. Clone and Setup

```bash
git clone <your-repo-url>
cd heatmap
```

### 2. Backend Setup

```bash
cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# or: venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt

# Add Firebase credentials (one of these methods):
# Option A: Place firebase_key.json in backend folder
# Option B: Set environment variable
export FIREBASE_CONFIG_JSON='{"type":"service_account",...}'

# Run the server
uvicorn main:app --reload --port 8000
```

**Backend URLs:**
- API: http://127.0.0.1:8000
- Swagger Docs: http://127.0.0.1:8000/docs
- ReDoc: http://127.0.0.1:8000/redoc

### 3. Frontend Setup

```bash
cd frontend

# Ensure Flutter is in PATH
export PATH="$HOME/flutter/bin:$PATH"

# Get dependencies
flutter pub get

# Run in Chrome (development)
flutter run -d chrome --web-port 3000

# Or build for production
flutter build web --release
```

**Frontend URL:** http://localhost:3000

### 4. Quick Start (Both Terminals)

**Terminal 1 - Backend:**
```bash
cd /path/to/heatmap/backend && source venv/bin/activate && uvicorn main:app --reload --port 8000
```

**Terminal 2 - Frontend:**
```bash
cd /path/to/heatmap/frontend && flutter run -d chrome --web-port 3000
```

### 5. Kill Busy Ports (if needed)

```bash
fuser -k 8000/tcp  # Kill backend port
fuser -k 3000/tcp  # Kill frontend port
```

---

## Navigation & Routing

### Transport Modes

| Mode | OSRM Server | Route Style | Optimized For |
|------|-------------|-------------|---------------|
| 🚗 Car | `routing.openstreetmap.de/routed-car` | Solid blue line | Highways, main roads |
| 🏍️ Bike | `routing.openstreetmap.de/routed-bike` | Solid blue line | Cycling lanes, local roads |
| 🚶 Walk | `routing.openstreetmap.de/routed-foot` | Dotted blue line | Sidewalks, pedestrian paths |

Each mode uses a **separate OSRM server instance** with its own routing profile, ensuring genuinely different routes with accurate distance and time calculations.

### Navigation Flow

1. Click a pin → tap **"Directions →"**
2. Route sheet appears with all 3 transport modes loading in parallel
3. Each mode shows its **real distance** and **real ETA** from the OSRM API
4. Select a mode → route draws on the map with appropriate style
5. Press **"▶ Start"** → HUD appears with turn-by-turn guidance
6. Non-essential pins hide; only destination + critical pins remain
7. Press **"End"** to stop navigation and restore all pins

### Marker Clustering

When zoomed out, nearby pins are grouped into clusters:
- **Green clusters** (1-3 severity avg) — Low-priority incidents
- **Yellow clusters** (4-6 severity avg) — Medium-priority incidents
- **Red clusters** (7+ severity avg) — Critical incidents
- Cluster shows the **count** of grouped pins
- Clicking a cluster zooms in to reveal sub-clusters or individual pins
- At zoom level 16+, all pins are shown individually

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Health check |
| GET | `/health` | Health + timestamp |
| POST | `/report` | Submit new crisis report |
| POST | `/accept_task` | Volunteer accepts task |
| POST | `/checkin` | Volunteer check-in (resolves nearby) |
| GET | `/reports` | All active reports |
| GET | `/reports/ghost` | Ghost heat zones |

### Example: Submit a Report

```bash
curl -X POST http://127.0.0.1:8000/report \
  -H "Content-Type: application/json" \
  -d '{
    "latitude": 12.9716,
    "longitude": 77.5946,
    "severity": 8,
    "category": "Flood",
    "problem": "Flash flood on main road",
    "location_name": "MG Road"
  }'
```

---

## Firestore Document Schema

```json
{
  "id": "uuid",
  "latitude": 12.97,
  "longitude": 77.59,
  "severity": 9,
  "intensity": 0.9,
  "zone": "red",
  "category": "Flood",
  "problem": "Flash flood blocking main road",
  "location_name": "Koramangala 5th Block",
  "resolved": false,
  "ghost_heat": false,
  "report_count": 1,
  "complaint_count": 1,
  "people_accepted": 0,
  "task_status": "open",
  "timestamp": "2026-03-25T10:30:00Z",
  "volunteer_id": null
}
```

### Categories
`Flood` | `Fire` | `Medical` | `Shelter` | `Food`

### Severity Zones & Ripple Effects

| Zone | Severity | Color | Ripple Size | Animation Speed |
|------|----------|-------|-------------|-----------------|
| Red | 7-10 | #ef4444 | 60px | 1.5s (fast) |
| Yellow | 4-6 | #f59e0b | 45px | 2.0s (medium) |
| Green | 1-3 | #10b981 | 30px | 2.5s (slow) |

---

## Theme System

| Theme | Time | Tiles | Background |
|-------|------|-------|------------|
| Light | 6 AM - 6 PM | Carto Voyager | #f8fafc |
| Dark | 6 PM - 6 AM | Carto Voyager (dark filter) | #1e293b (slate) |

**Manual Toggle:** Sun/Moon button at bottom-right of map

---

## Deployment to Vercel

### 1. Prepare Repository

```bash
# Ensure firebase_key.json is in .gitignore
echo "firebase_key.json" >> .gitignore

# Build Flutter frontend
cd frontend && flutter build web --release
```

### 2. Push to GitHub

```bash
git add .
git commit -m "Ready for deployment"
git push origin main
```

### 3. Deploy on Vercel

1. Import project from GitHub in [Vercel Dashboard](https://vercel.com/dashboard)
2. Set environment variable:
   - **Name:** `FIREBASE_CONFIG_JSON`
   - **Value:** Contents of your `firebase_key.json` (as a single-line JSON string)
3. Deploy!

### 4. Verify Deployment

- **Frontend:** https://your-project.vercel.app/
- **Backend API:** https://your-project.vercel.app/api/health

---

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `FIREBASE_CONFIG_JSON` | Firebase service account JSON (stringified) | Yes (production) |

---

## Firebase Setup

### 1. Create Firestore Database

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing
3. Enable Firestore Database (Start in test mode)
4. Set region to `asia-south1` (Mumbai) for India

### 2. Get Service Account Key

1. Project Settings → Service Accounts
2. Generate new private key
3. Save as `backend/firebase_key.json`

### 3. Security Rules (Production)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /heatmap_reports/{document} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

---

## Troubleshooting

### Port Already in Use

```bash
# Check what's using the port
lsof -i :3000
lsof -i :8000

# Kill the process
fuser -k 3000/tcp
fuser -k 8000/tcp
```

### Flutter Not Found

```bash
# Add Flutter to PATH
export PATH="$HOME/flutter/bin:$PATH"

# Or add to ~/.bashrc for persistence
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
```

### Firebase Connection Issues

1. Check `firebase_key.json` exists and is valid
2. Verify Firestore rules allow reads
3. Check network connectivity to Firebase

### Map Not Loading

1. Check browser console for errors
2. Verify Leaflet.js CDN is accessible
3. Try clearing browser cache

### Routing Not Working

1. FOSSGIS OSRM servers are free/public — may have occasional downtime
2. Check browser console for CORS or network errors
3. Fallback: the route sheet will show "N/A" for unavailable modes

---

## Contributing

This is part of the **AURA Platform** for the Google Solution Challenge. Contact the team for contribution guidelines.

## Team

| Person | Role |
|--------|------|
| Heat Map Dev | This module - FastAPI + Firebase + Leaflet.js |
| Frontend Dev | Flutter Mobile/Web App - volunteer UI |
| AI Dev | Gemini parsing, severity scoring |
| Platform Dev | Other NGO platform features |

---

## License

MIT License - See LICENSE file for details.

---

Built with Flutter, Leaflet.js, FastAPI, and Firebase for the Google Solution Challenge 2026.
