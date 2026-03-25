from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class ReportInput(BaseModel):
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    severity: int = Field(..., ge=1, le=10)
    category: Optional[str] = Field(None, description="e.g. Flood, Medical, Fire")
    problem: Optional[str] = Field(None, description="Human-readable problem description")
    location_name: Optional[str] = Field(None, description="Street/area name")
    report_id: Optional[str] = None
    volunteer_id: Optional[str] = None
    timestamp: Optional[datetime] = None


class VolunteerCheckIn(BaseModel):
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    volunteer_id: str
    report_id: Optional[str] = None


class AcceptTaskInput(BaseModel):
    """Volunteer accepts a task — increments people_accepted counter."""
    report_id: str
    volunteer_id: str


class ReportResponse(BaseModel):
    success: bool
    message: str
    data: Optional[dict] = None
