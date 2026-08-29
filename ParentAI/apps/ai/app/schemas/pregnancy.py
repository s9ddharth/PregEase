from datetime import date
from pydantic import BaseModel, Field


class PregnancyProfileCreate(BaseModel):
    lmp_date: date

    dietary_preference: str | None = Field(
        default=None,
        max_length=50,
    )

    custom_dietary_preference: str | None = Field(
        default=None,
        max_length=255,
    )

    food_allergies: list[str] = Field(
        default_factory=list,
    )


class PregnancyProfileResponse(BaseModel):
    id: int
    user_id: int
    lmp_date: date

    dietary_preference: str | None = None
    custom_dietary_preference: str | None = None

    food_allergies: list[str] = Field(
        default_factory=list,
    )

    current_week: int

    created_at: str | None = None
    updated_at: str | None = None