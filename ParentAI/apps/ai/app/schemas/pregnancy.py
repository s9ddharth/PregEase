from datetime import date

from pydantic import BaseModel, Field


from pydantic import BaseModel, Field


class NutritionSuggestionsRequest(BaseModel):
    cuisine: str | None = Field(default=None, max_length=80)
    meal_type: str | None = Field(default=None, max_length=50)


class NutritionMealSuggestion(BaseModel):
    name: str
    description: str
    ingredients: list[str]


class NutritionSuggestionsResponse(BaseModel):
    current_week: int
    title: str
    suggestions: list[NutritionMealSuggestion]
    safety_note: str



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

    dietary_preference: str | None
    custom_dietary_preference: str | None

    food_allergies: list[str]

    current_week: int

    created_at: str | None
    updated_at: str | None


class PersonalizedNutritionResponse(BaseModel):
    current_week: int
    content_week: int

    nutrition_guidance: str | None

    foods: list[dict]

    dietary_preference: str | None
    custom_dietary_preference: str | None
    food_allergies: list[str]

    content_version: int | None
    reviewed_at: str | None

class BabyPreparationItemUpdate(BaseModel):
    week: int = Field(ge=1, le=40)
    item_key: str = Field(min_length=1, max_length=100)
    is_completed: bool


class BabyPreparationItemResponse(BaseModel):
    week: int
    item_key: str
    is_completed: bool
    completed_at: str | None


class BabyPreparationChecklistItem(BaseModel):
    key: str
    title: str
    is_completed: bool
    completed_at: str | None


class BabyPreparationChecklistResponse(BaseModel):
    current_week: int
    checklist_week: int
    guidance: str | None
    items: list[BabyPreparationChecklistItem]
    completed_count: int
    total_count: int

class ExerciseSleepGuidanceResponse(BaseModel):
    current_week: int
    content_week: int
    activities: str | None
    sleep_guidance: str | None
    precautions: str | None
    content_version: int
    status: str
    reviewed_at: str | None