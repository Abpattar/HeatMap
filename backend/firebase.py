import firebase_admin
from firebase_admin import credentials, firestore
import os
import json
import tempfile

if not firebase_admin._apps:
    config_json = os.environ.get('FIREBASE_CONFIG_JSON')

    if config_json:
        # Vercel: parse env var JSON and write to a temp file for the SDK
        config_dict = json.loads(config_json)
        tmp = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(config_dict, tmp)
        tmp.flush()
        cred = credentials.Certificate(tmp.name)
    else:
        # Local dev fallback: use the key file
        KEY_PATH = os.path.join(os.path.dirname(__file__), "firebase_key.json")
        cred = credentials.Certificate(KEY_PATH)

    firebase_admin.initialize_app(cred)

db = firestore.client()

REPORTS_COLLECTION = "heatmap_reports"
CHECKINS_COLLECTION = "volunteer_checkins"
