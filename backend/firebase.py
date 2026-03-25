import firebase_admin
from firebase_admin import credentials, firestore
import os
import json
import tempfile

if not firebase_admin._apps:
    config_json = os.environ.get('FIREBASE_CONFIG_JSON')

    if config_json:
        # Vercel: parse env var JSON, write to a temp file for the SDK, then clean up
        config_dict = json.loads(config_json)
        tmp = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        try:
            json.dump(config_dict, tmp)
            tmp.flush()
            tmp.close()
            cred = credentials.Certificate(tmp.name)
        finally:
            os.unlink(tmp.name)  # Always delete the temp file — no resource leak
    else:
        # Local dev fallback: use the key file
        KEY_PATH = os.path.join(os.path.dirname(__file__), "firebase_key.json")
        cred = credentials.Certificate(KEY_PATH)

    firebase_admin.initialize_app(cred)

db = firestore.client()

REPORTS_COLLECTION = "heatmap_reports"
CHECKINS_COLLECTION = "volunteer_checkins"
