from fastapi import APIRouter, Depends, Query,HTTPException
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user_id
from app.database.session import SessionLocal
from app.schemas.wellness import (
    WellnessCheckinCreate,
    WellnessCheckinResponse,
    WellnessPatternResponse
)
from app.services.wellness_service import (
    create_wellness_checkin,
    get_latest_wellness_checkin,
    get_wellness_history,
    get_wellness_pattern
)

router = APIRouter(
    prefix="/wellness",
    tags=["Mental Wellness"],
)
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post(
    "/check-ins",
    response_model=WellnessCheckinResponse,
)
def submit_wellness_checkin(
    checkin: WellnessCheckinCreate,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    try:
        return create_wellness_checkin(
            db=db,
            user_id=user_id,
            checkin=checkin,
        )
    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="We couldn't save your wellness check-in right now. Please try again in a moment.",
        )


@router.get(
    "/check-ins",
    response_model=list[WellnessCheckinResponse],
)
def get_wellness_checkins(
    limit: int = Query(default=20, ge=1, le=100),
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    return get_wellness_history(
        db=db,
        user_id=user_id,
        limit=limit,
    )


@router.get(
    "/check-ins/latest",
    response_model=WellnessCheckinResponse | None,
)
def get_latest_checkin(
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    return get_latest_wellness_checkin(
        db=db,
        user_id=user_id,
    )

@router.get(
    "/check-ins/pattern",
    response_model=WellnessPatternResponse,
)
def get_wellness_checkin_pattern(
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    return get_wellness_pattern(
        db=db,
        user_id=user_id,
    )