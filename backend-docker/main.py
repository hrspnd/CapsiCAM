
import os

import httpx
from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel, Field

app = FastAPI(title="Chili Pepper Disease Detection API")

SUPABASE_URL = os.environ.get("SUPABASE_URL", "").rstrip("/")
SUPABASE_PUBLISHABLE_KEY = os.environ.get(
    "SUPABASE_PUBLISHABLE_KEY", ""
)


class ScanCreate(BaseModel):
    image_url: str
    classification: str
    confidence_healthy: float = Field(ge=0, le=1)
    confidence_bls: float = Field(ge=0, le=1)
    confidence_cls: float = Field(ge=0, le=1)
    image_source: str
    heatmap_url: str | None = None
    scanned_at: str | None = None


@app.get("/")
def root():
    return {"message": "Chili Pepper Disease Detection API"}


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.post("/scans", status_code=201)
async def create_scan(
    scan: ScanCreate,
    authorization: str | None = Header(default=None),
):
    if not SUPABASE_URL or not SUPABASE_PUBLISHABLE_KEY:
        raise HTTPException(
            status_code=500,
            detail="Supabase configuration is missing",
        )

    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=401,
            detail="Authentication token is required",
        )

    token = authorization.removeprefix("Bearer ").strip()

    if not token:
        raise HTTPException(status_code=401, detail="Invalid token")

    headers = {
        "apikey": SUPABASE_PUBLISHABLE_KEY,
        "Authorization": f"Bearer {token}",
    }

    async with httpx.AsyncClient(timeout=15.0) as client:
        try:
            user_response = await client.get(
                f"{SUPABASE_URL}/auth/v1/user",
                headers=headers,
            )

            if user_response.status_code != 200:
                raise HTTPException(
                    status_code=401,
                    detail="Invalid or expired session",
                )

            user_id = user_response.json()["id"]

            record = scan.model_dump(exclude_none=True)
            record["user_id"] = user_id

            insert_response = await client.post(
                f"{SUPABASE_URL}/rest/v1/scans",
                headers={
                    **headers,
                    "Content-Type": "application/json",
                    "Prefer": "return=representation",
                },
                json=record,
            )

            if insert_response.status_code not in (200, 201):
                raise HTTPException(
                    status_code=502,
                    detail="Unable to save scan to Supabase",
                )

            return {
                "message": "Scan saved successfully",
                "scan": insert_response.json()[0],
            }

        except httpx.RequestError:
            raise HTTPException(
                status_code=503,
                detail="Unable to connect to Supabase",
            )
