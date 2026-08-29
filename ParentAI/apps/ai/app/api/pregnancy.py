from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    status,
)

from app.api.dependencies import (
    get_current_user_id,
)

from app.schemas.pregnancy import (
    PregnancyProfileCreate,
    PregnancyProfileResponse,
)

from app.services.pregnancy_service import (
    pregnancy_service,
)


router = APIRouter(
    prefix="/pregnancy",
    tags=["Pregnancy"],
)


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