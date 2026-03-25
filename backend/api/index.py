"""
Vercel Python serverless entry-point.
Vercel looks for `handler` in api/index.py and wraps it with mangum
to adapt FastAPI (ASGI) to the AWS Lambda/Vercel serverless runtime.
"""
from mangum import Mangum
from main import app  # noqa: F401  — re-uses the fully configured FastAPI app

handler = Mangum(app, lifespan="off")
