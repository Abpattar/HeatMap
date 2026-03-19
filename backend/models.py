from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class ReportInput(BaseModel):
    """
    Input model for a crisis report.
    v1 requires only lat, lng, severity.
    All other fields are optional and can be added later
    when the team integrates their parts.
    """
    latitude: float = Field(..., ge=-90, le=90, description="Latitude of the report")
    longitude: float = Field(..., ge=-180, le=180, description="Longitude of the report")
    severity: int = Field(..., ge=1, le=10, description="Urgency score from Gemini (1-10)")

    # Future fields — optional for now, ready for integration
    category: Optional[str] = Field(None, description="e.g. Flood, Medical, Fire")
    report_id: Optional[str] = Field(None, description="Unique ID from the main system")
    volunteer_id: Optional[str] = Field(None, description="Volunteer who checked in")
    timestamp: Optional[datetime] = Field(None, description="Time of report")


class VolunteerCheckIn(BaseModel):
    """
    When a volunteer checks in at a location,
    the heat at that coordinate fades/decays.
    """
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    volunteer_id: str
    report_id: Optional[str] = None


class ReportResponse(BaseModel):
    """
    Standard API response wrapper.
    """
    success: bool
    message: str
    data: Optional[dict] = None
