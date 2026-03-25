# Vercel serverless entry point for FastAPI
# Vercel looks for `app` in the file pointed to by vercel.json builds src.
# Since main.py already exports `app`, this file re-exports it.
from main import app  # noqa: F401
