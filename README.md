# HeatMap
Project Name: Dynamic Geospatial Heat Map — NGO Emergency Response

## 🚀 HOW TO RUN THE PROJECT (IMPORTANT!)

### Terminal 1 — Start FastAPI Backend:
```bash
cd /home/neo/Cli/heatmap/backend && source venv/bin/activate && uvicorn main:app --reload --port 8000
```
- API runs at: http://127.0.0.1:8000
- API docs at: http://127.0.0.1:8000/docs

### Terminal 2 — Start Flutter Web Frontend:
```bash
export PATH="$HOME/flutter/bin:$PATH" && cd /home/neo/Cli/heatmap/frontend && flutter run -d chrome --web-port 3000
```
- Opens Chrome automatically at: http://localhost:3000
