import firebase_admin
from firebase_admin import credentials, firestore
import os

# Path to the Firebase service account key
KEY_PATH = os.path.join(os.path.dirname(__file__), "firebase_key.json")

# Initialize Firebase only once
if not firebase_admin._apps:
    cred = credentials.Certificate(KEY_PATH)
    firebase_admin.initialize_app(cred)

# Firestore client — used across the app
db = firestore.client()

# Collection names — defined here so they're easy to change later
REPORTS_COLLECTION = "heatmap_reports"
CHECKINS_COLLECTION = "volunteer_checkins"
