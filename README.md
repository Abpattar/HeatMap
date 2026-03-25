# HeatMap — Emergency Response System

Dynamic Geospatial Heat Map for NGO Emergency Response, rebuilt to run on **Vercel** serverless.

## 🚀 Live Deployment
The project can be deployed easily to Vercel.
- **Frontend**: Flutter Web static build
- **Backend API**: Python FastAPI running on Vercel Serverless Functions

## 🛠️ Local Development

### 1. Start FastAPI Backend
```bash
cd backend
source venv/bin/activate
pip install -r requirements.txt
export FIREBASE_CONFIG_JSON=$(cat .env.production)
uvicorn main:app --reload --port 8000
```
- API runs at: http://127.0.0.1:8000
- API docs at: http://127.0.0.1:8000/docs

### 2. Start Flutter Web Frontend
```bash
cd frontend
flutter clean
flutter pub get
flutter run -d web-server --web-port 3000
# Or using chrome:
# flutter run -d chrome --web-port 3000
```
- App runs at: http://localhost:3000

---
## ✨ Deployment to Vercel
1. Ensure your `.env.production` (containing the Firebase key) is **ignored** by Git.
2. Push this repository to GitHub.
3. Import the repository into Vercel.
4. Add the `FIREBASE_CONFIG_JSON` Environment Variable in project settings. Set its value to the JSON contents of `.env.production`.
5. Deploy! Vercel will automatically host the Flutter frontend and the FastAPI backend (`/api/*`).
