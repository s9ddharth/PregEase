from sqlalchemy.orm import Session

from app.database.models import WellnessCheckin
from app.schemas.wellness import WellnessCheckinCreate


def calculate_wellness_level(
    checkin: WellnessCheckinCreate,
) -> str:
    # Higher values mean greater concern.
    #
    # Mood: 1 = very low, 5 = very good
    # Stress: 1 = very low, 5 = very high
    # Anxiety: 1 = very low, 5 = very high
    # Sleep: 1 = very poor, 5 = very good
    # Support: 1 = no support, 5 = strong support

    concern_score = (
        (6 - checkin.mood_score)
        + checkin.stress_score
        + checkin.anxiety_score
        + (6 - checkin.sleep_score)
        + (6 - checkin.support_score)
    )

    if concern_score <= 10:
        return "LOW"

    if concern_score <= 17:
        return "MODERATE"

    return "HIGH"


def get_guidance(level: str) -> str:
    guidance = {
        "LOW": (
            "You're doing well. Keep making time for rest, connection, "
            "and small moments that help you feel grounded."
        ),
        "MODERATE": (
            "It sounds like you may be carrying a little more than usual. "
            "Consider taking some time to rest and talking with someone "
            "you trust or a healthcare professional if these feelings continue."
        ),
        "HIGH": (
            "You may be going through a particularly difficult time. "
            "Please consider reaching out to a trusted person or healthcare "
            "professional for additional support. You don't have to handle "
            "this alone."
        ),
    }

    return guidance[level]


def create_wellness_checkin(
    db: Session,
    user_id: int,
    checkin: WellnessCheckinCreate,
) -> WellnessCheckin:
    level = calculate_wellness_level(checkin)
    guidance = get_guidance(level)

    responses = {
        "mood_score": checkin.mood_score,
        "stress_score": checkin.stress_score,
        "anxiety_score": checkin.anxiety_score,
        "sleep_score": checkin.sleep_score,
        "support_score": checkin.support_score,
    }

    wellness_checkin = WellnessCheckin(
        user_id=user_id,
        mood_score=checkin.mood_score,
        stress_score=checkin.stress_score,
        anxiety_score=checkin.anxiety_score,
        sleep_score=checkin.sleep_score,
        support_score=checkin.support_score,
        overall_level=level,
        responses_json=responses,
        guidance=guidance,
    )

    db.add(wellness_checkin)
    db.commit()
    db.refresh(wellness_checkin)

    return wellness_checkin


def get_wellness_history(
    db: Session,
    user_id: int,
    limit: int = 20,
):
    return (
        db.query(WellnessCheckin)
        .filter(WellnessCheckin.user_id == user_id)
        .order_by(WellnessCheckin.created_at.desc())
        .limit(limit)
        .all()
    )


def get_latest_wellness_checkin(
    db: Session,
    user_id: int,
):
    return (
        db.query(WellnessCheckin)
        .filter(WellnessCheckin.user_id == user_id)
        .order_by(WellnessCheckin.created_at.desc())
        .first()
    )


def get_wellness_pattern(
    db: Session,
    user_id: int,
):
    recent_checkins = (
        db.query(WellnessCheckin)
        .filter(WellnessCheckin.user_id == user_id)
        .order_by(WellnessCheckin.created_at.desc())
        .limit(3)
        .all()
    )

    if len(recent_checkins) < 3:
        return {
            "has_repeated_concern": False,
            "pattern": "INSUFFICIENT_DATA",
            "message": (
                "Complete a few more check-ins to see patterns "
                "in your wellness history."
            ),
        }

    levels = [checkin.overall_level for checkin in recent_checkins]

    moderate_or_high_count = sum(
        1 for level in levels
        if level in ("MODERATE", "HIGH")
    )

    high_count = sum(
        1 for level in levels
        if level == "HIGH"
    )

    if high_count >= 2:
        return {
            "has_repeated_concern": True,
            "pattern": "REPEATED_HIGH_CONCERN",
            "message": (
                "Your recent check-ins suggest that you may be experiencing "
                "ongoing difficulties. Consider talking with someone you trust "
                "or a healthcare professional."
            ),
        }

    if moderate_or_high_count == 3:
        return {
            "has_repeated_concern": True,
            "pattern": "PERSISTENT_CONCERN",
            "message": (
                "Your recent check-ins suggest that you may be experiencing "
                "ongoing difficulties. Consider talking with someone you trust "
                "or a healthcare professional."
            ),
        }

    return {
        "has_repeated_concern": False,
        "pattern": "NO_REPEATED_CONCERN",
        "message": (
            "Your recent check-ins do not show a repeated concern. "
            "Keep checking in with yourself regularly."
        ),
    }