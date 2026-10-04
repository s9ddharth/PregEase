from datetime import datetime
from enum import Enum

from pydantic import BaseModel, Field


class WellnessLevel(str, Enum):
    LOW = "LOW"
    MODERATE = "MODERATE"
    HIGH = "HIGH"


class WellnessCheckinCreate(BaseModel):
    mood_score: int = Field(..., ge=1, le=5)
    stress_score: int = Field(..., ge=1, le=5)
    anxiety_score: int = Field(..., ge=1, le=5)
    sleep_score: int = Field(..., ge=1, le=5)
    support_score: int = Field(..., ge=1, le=5)


class WellnessCheckinResponse(BaseModel):
    id: int
    mood_score: int
    stress_score: int
    anxiety_score: int
    sleep_score: int
    support_score: int
    overall_level: WellnessLevel
    guidance: str
    created_at: datetime

    class Config:
        from_attributes = True

class WellnessPatternResponse(BaseModel):
    has_repeated_concern: bool
    pattern: str
    message: str