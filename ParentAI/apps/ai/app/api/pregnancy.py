import json
from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    status,
    Body
)
from app.ai.client import ai_client

from app.api.dependencies import (
    get_current_user_id,
)

from app.schemas.pregnancy import (
    PregnancyProfileCreate,
    PregnancyProfileResponse,
    PersonalizedNutritionResponse,
    BabyPreparationChecklistResponse,
    BabyPreparationItemUpdate,
    BabyPreparationItemResponse,
    ExerciseSleepGuidanceResponse,
    NutritionSuggestionsRequest,
    NutritionSuggestionsResponse
)

from app.services.pregnancy_service import (
    pregnancy_service,
)
from app.services.baby_preparation_service import (
    baby_preparation_service,
)
from app.api.auth import get_current_user_id
import logging

router = APIRouter(
    prefix="/pregnancy",
    tags=["Pregnancy"],
)
logger = logging.getLogger(__name__)


# ============================================================
# GET PREGNANCY PROFILE
# ============================================================

@router.get(
    "/profile",
    response_model=PregnancyProfileResponse,
)
def get_pregnancy_profile(
    user_id: int = Depends(
        get_current_user_id
    ),
):

    profile = pregnancy_service.get_profile(
        user_id
    )

    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Pregnancy profile not found.",
        )

    return profile


# ============================================================
# CREATE PREGNANCY PROFILE
# ============================================================

@router.post(
    "/profile",
    response_model=PregnancyProfileResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_pregnancy_profile(
    data: PregnancyProfileCreate,
    user_id: int = Depends(
        get_current_user_id
    ),
):

    try:

        return pregnancy_service.create_profile(
            user_id=user_id,
            lmp_date=data.lmp_date,
            dietary_preference=
                data.dietary_preference,
            custom_dietary_preference=
                data.custom_dietary_preference,
            food_allergies=
                data.food_allergies,
        )

    except ValueError as e:

        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(e),
        )


# ============================================================
# UPDATE PREGNANCY PROFILE
# ============================================================

@router.put(
    "/profile",
    response_model=PregnancyProfileResponse,
)
def update_pregnancy_profile(
    data: PregnancyProfileCreate,
    user_id: int = Depends(
        get_current_user_id
    ),
):

    profile = pregnancy_service.update_profile(
        user_id=user_id,
        lmp_date=data.lmp_date,
        dietary_preference=
            data.dietary_preference,
        custom_dietary_preference=
            data.custom_dietary_preference,
        food_allergies=
            data.food_allergies,
    )

    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Pregnancy profile not found.",
        )

    return profile
# ============================================================
# GET WEEKLY PREGNANCY CONTENT
# ============================================================

@router.get(
    "/week/{week}",
)
def get_weekly_pregnancy_content(
    week: int,
    user_id: int = Depends(
        get_current_user_id
    ),
):
    content = (
        pregnancy_service.get_week_content(
            week
        )
    )

    if content is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "Published pregnancy content "
                "for this week is not available."
            ),
        )

    return content
# ============================================================
# GET CURRENT WEEK PREGNANCY CONTENT
# ============================================================

@router.get(
    "/current-week",
)
def get_current_week_pregnancy_content(
    user_id: int = Depends(
        get_current_user_id
    ),
):
    content = (
        pregnancy_service.get_current_week_content(
            user_id
        )
    )

    if content is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Pregnancy profile not found.",
        )

    if content["content"] is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "Published pregnancy content "
                "for the current week is not available."
            ),
        )
    return content
@router.get(
    "/nutrition",
    response_model=PersonalizedNutritionResponse,
)
def get_personalized_nutrition(
    user_id: int = Depends(get_current_user_id),
):
    nutrition = pregnancy_service.get_personalized_nutrition(
        user_id
    )

    if nutrition is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Pregnancy profile not found.",
        )

    if nutrition["nutrition_guidance"] is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "Published pregnancy nutrition content "
                "for the current week is not available."
            ),
        )

    return nutrition
@router.get(
    "/baby-preparation",
    response_model=BabyPreparationChecklistResponse,
)
def get_baby_preparation_checklist(
    week: int | None = None,
    user_id: int = Depends(get_current_user_id),
):
    try:
        result = baby_preparation_service.get_checklist(
            user_id=user_id,
            week=week,
        )

        if result is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Pregnancy profile not found.",
            )

        return result

    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(exc),
        )


@router.put(
    "/baby-preparation/checklist-item",
    response_model=BabyPreparationItemResponse,
)
def update_baby_preparation_checklist_item(
    data: BabyPreparationItemUpdate,
    user_id: int = Depends(get_current_user_id),
):
    try:
        result = baby_preparation_service.update_item(
            user_id=user_id,
            week=data.week,
            item_key=data.item_key,
            is_completed=data.is_completed,
        )

        if result is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Pregnancy profile not found.",
            )

        return result

    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(exc),
        )
@router.get(
    "/exercise-sleep",
    response_model=ExerciseSleepGuidanceResponse,
)
def get_exercise_sleep_guidance(
    week: int | None = None,
    user_id: int = Depends(get_current_user_id),
):
    try:
        result = pregnancy_service.get_exercise_sleep_guidance(
            user_id=user_id,
            week=week,
        )

        if result is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Pregnancy profile not found.",
            )

        if result["status"] == "unavailable":
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=(
                    "Published exercise and sleep guidance "
                    "is not available for this week."
                ),
            )

        return result

    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(exc),
        )

# ============================================================
# GET CURRENT WEEK FATHER TIP
# ============================================================

@router.get("/father-tip")
def get_current_week_father_tip(
    user_id: int = Depends(get_current_user_id),
):
    result = pregnancy_service.get_current_week_father_tip(
        user_id
    )

    if result is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Pregnancy profile not found.",
        )

    if result["tip"] is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Father tip is not available for this week.",
        )

    return result


@router.post(
    "/nutrition/suggestions",
    response_model=NutritionSuggestionsResponse,
)
def generate_nutrition_suggestions(
    request: NutritionSuggestionsRequest,
    user_id: int = Depends(get_current_user_id),
):
    nutrition = pregnancy_service.get_personalized_nutrition(user_id)

    if nutrition is None:
        raise HTTPException(
            status_code=404,
            detail="Pregnancy profile not found.",
        )

    if not nutrition.get("nutrition_guidance"):
        raise HTTPException(
            status_code=404,
            detail="Nutrition content is unavailable for this pregnancy week.",
        )

    try:
        raw_result = ai_client.generate_nutrition_suggestions(
            pregnancy_week=nutrition["current_week"],
            dietary_preference=nutrition.get("dietary_preference"),
            custom_dietary_preference=nutrition.get(
                "custom_dietary_preference"
            ),
            food_allergies=nutrition.get("food_allergies", []),
            safe_foods=nutrition.get("foods", []),
            cuisine=request.cuisine,
            meal_type=request.meal_type,
        )

        result = json.loads(raw_result)

        # Validate the AI output against the response schema.
        validated = NutritionSuggestionsResponse(
            current_week=nutrition["current_week"],
            title=result["title"],
            suggestions=result["suggestions"],
            safety_note=result["safety_note"],
        )

        return validated

    except Exception as exc:
        logger.exception("Failed to generate nutrition suggestions")
        raise HTTPException(
            status_code=502,
            detail="Nutrition suggestions could not be generated. Please try again.",
        ) from exc