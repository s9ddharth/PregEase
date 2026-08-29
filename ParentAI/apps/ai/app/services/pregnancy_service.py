import json
from datetime import date, datetime

from app.database.models import (PregnancyProfile,PregnancyWeekContent)
from app.database.session import SessionLocal


class PregnancyService:

    # ========================================================
    # CALCULATE PREGNANCY WEEK
    # ========================================================

    @staticmethod
    def calculate_current_week(
        lmp_date: date,
    ) -> int:

        today = date.today()

        days = (
            today - lmp_date
        ).days

        if days < 0:
            return 0

        # 7 days = 1 pregnancy week
        week = (days // 7) + 1

        return week

    # ========================================================
    # CONVERT DATABASE OBJECT TO RESPONSE DICT
    # ========================================================

    @staticmethod
    def _to_dict(
        profile: PregnancyProfile,
    ):

        allergies = []

        if profile.food_allergies:
            try:
                decoded = json.loads(
                    profile.food_allergies
                )

                if isinstance(decoded, list):
                    allergies = [
                        str(item)
                        for item in decoded
                    ]

            except (json.JSONDecodeError, TypeError):
                allergies = []

        lmp_date = profile.lmp_date.date()

        return {
            "id": profile.id,
            "user_id": profile.user_id,
            "lmp_date": lmp_date,
            "dietary_preference":
                profile.dietary_preference,
            "custom_dietary_preference":
                profile.custom_dietary_preference,
            "food_allergies": allergies,
            "current_week":
                PregnancyService.calculate_current_week(
                    lmp_date
                ),
            "created_at": (
                profile.created_at.isoformat()
                if profile.created_at
                else None
            ),
            "updated_at": (
                profile.updated_at.isoformat()
                if profile.updated_at
                else None
            ),
        }

    # ========================================================
    # GET PROFILE
    # ========================================================

    def get_profile(
        self,
        user_id: int,
    ):

        db = SessionLocal()

        try:
            profile = (
                db.query(PregnancyProfile)
                .filter(
                    PregnancyProfile.user_id
                    == user_id
                )
                .first()
            )

            if profile is None:
                return None

            return self._to_dict(profile)

        finally:
            db.close()

    # ========================================================
    # CREATE PROFILE
    # ========================================================

    def create_profile(
        self,
        user_id: int,
        lmp_date: date,
        dietary_preference: str | None,
        custom_dietary_preference: str | None,
        food_allergies: list[str],
    ):

        db = SessionLocal()

        try:
            existing = (
                db.query(PregnancyProfile)
                .filter(
                    PregnancyProfile.user_id
                    == user_id
                )
                .first()
            )

            if existing is not None:
                raise ValueError(
                    "Pregnancy profile already exists."
                )

            profile = PregnancyProfile(
                user_id=user_id,
                lmp_date=datetime.combine(
                    lmp_date,
                    datetime.min.time(),
                ),
                dietary_preference=
                    dietary_preference,
                custom_dietary_preference=
                    custom_dietary_preference,
                food_allergies=json.dumps(
                    food_allergies
                ),
            )

            db.add(profile)
            db.commit()
            db.refresh(profile)

            return self._to_dict(profile)

        except Exception:
            db.rollback()
            raise

        finally:
            db.close()

    # ========================================================
    # UPDATE PROFILE
    # ========================================================

    def update_profile(
        self,
        user_id: int,
        lmp_date: date,
        dietary_preference: str | None,
        custom_dietary_preference: str | None,
        food_allergies: list[str],
    ):

        db = SessionLocal()

        try:
            profile = (
                db.query(PregnancyProfile)
                .filter(
                    PregnancyProfile.user_id
                    == user_id
                )
                .first()
            )

            if profile is None:
                return None

            profile.lmp_date = datetime.combine(
                lmp_date,
                datetime.min.time(),
            )

            profile.dietary_preference = (
                dietary_preference
            )

            profile.custom_dietary_preference = (
                custom_dietary_preference
            )

            profile.food_allergies = json.dumps(
                food_allergies
            )

            db.commit()
            db.refresh(profile)

            return self._to_dict(profile)

        except Exception:
            db.rollback()
            raise

        finally:
            db.close()
    # ========================================================
    # GET WEEKLY PREGNANCY CONTENT
    # ========================================================

    def get_week_content(self, week: int):
        if week < 1 or week > 40:
            return None

        db = SessionLocal()

        try:
            content = (
                db.query(PregnancyWeekContent)
                .filter(
                    PregnancyWeekContent.week == week,
                    PregnancyWeekContent.status == "published",
                )
                .first()
            )

            if content is None:
                return None

            return {
                "id": content.id,
                "week": content.week,
                "baby_growth": content.baby_growth,
                "body_changes": content.body_changes,
                "activities": content.activities,
                "nutrition_guidance": content.nutrition_guidance,
                "precautions": content.precautions,
                "mental_wellness": content.mental_wellness,
                "content_version": content.content_version,
                "status": content.status,
                "reviewed_at": (
                    content.reviewed_at.isoformat()
                    if content.reviewed_at
                    else None
                ),
                "sources": [
                    {
                        "organization": source.organization,
                        "title": source.title,
                        "url": source.url,
                        "source_type": source.source_type,
                        "reviewed_at": (
                            source.reviewed_at.isoformat()
                            if source.reviewed_at
                            else None
                        ),
                    }
                    for source in content.sources
                ],
            }

        finally:
            db.close()

pregnancy_service = PregnancyService()