import json
from datetime import date, datetime

from sqlalchemy import text

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

                # Baby
                "baby_growth": content.baby_growth,

                # Mother
                "body_changes": content.body_changes,

                # Lifestyle
                "activities": content.activities,
                "sleep_guidance": content.sleep_guidance,

                # Nutrition
                "nutrition_guidance": content.nutrition_guidance,

                # Mental wellness
                "mental_wellness": content.mental_wellness,

                # Preparation
                "baby_preparation": content.baby_preparation,

                # Safety
                "precautions": content.precautions,

                # Weekly suggestions
                "weekly_tips": content.weekly_tips,

                # Content management
                "content_version": content.content_version,
                "status": content.status,

                "reviewed_at": (
                    content.reviewed_at.isoformat()
                    if content.reviewed_at
                    else None
                ),

                # Evidence / references
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
    # ========================================================
    # GET CURRENT WEEK CONTENT FOR USER
    # ========================================================

    def get_current_week_content(self, user_id: int):
        db = SessionLocal()

        try:
            profile = (
                db.query(PregnancyProfile)
                .filter(
                    PregnancyProfile.user_id == user_id
                )
                .first()
            )

            if profile is None:
                return None

            lmp_date = profile.lmp_date.date()

            current_week = self.calculate_current_week(
                lmp_date
            )

            # Pregnancy content is currently defined
            # for weeks 1 through 40.
            content_week = min(
                max(current_week, 1),
                40,
            )

            content = (
                db.query(PregnancyWeekContent)
                .filter(
                    PregnancyWeekContent.week == content_week,
                    PregnancyWeekContent.status == "published",
                )
                .first()
            )

            if content is None:
                return {
                    "current_week": current_week,
                    "content_week": content_week,
                    "content": None,
                    "nutrition_profile": {
                        "dietary_preference":
                            profile.dietary_preference,
                        "custom_dietary_preference":
                            profile.custom_dietary_preference,
                        "food_allergies": self._decode_allergies(
                            profile.food_allergies
                        ),
                    },
                }

            return {
                "current_week": current_week,
                "content_week": content_week,

                "content": {
                    "id": content.id,
                    "week": content.week,
                    "baby_growth": content.baby_growth,
                    "body_changes": content.body_changes,
                    "activities": content.activities,
                    "nutrition_guidance":
                        content.nutrition_guidance,
                    "precautions": content.precautions,
                    "mental_wellness":
                        content.mental_wellness,
                    "sleep_guidance":
                        content.sleep_guidance,
                    "baby_preparation":
                        content.baby_preparation,
                    "weekly_tips":
                        content.weekly_tips,
                    "content_version":
                        content.content_version,
                    "status": content.status,
                    "reviewed_at": (
                        content.reviewed_at.isoformat()
                        if content.reviewed_at
                        else None
                    ),
                    "sources": [
                        {
                            "section": source.section,
                            "organization":
                                source.organization,
                            "title": source.title,
                            "url": source.url,
                            "source_type":
                                source.source_type,
                            "reviewed_at": (
                                source.reviewed_at.isoformat()
                                if source.reviewed_at
                                else None
                            ),
                        }
                        for source in content.sources
                    ],
                },

                "nutrition_profile": {
                    "dietary_preference":
                        profile.dietary_preference,
                    "custom_dietary_preference":
                        profile.custom_dietary_preference,
                    "food_allergies": self._decode_allergies(
                        profile.food_allergies
                    ),
                },
            }

        finally:
            db.close()
    # ========================================================
    # DECODE FOOD ALLERGIES
    # ========================================================

    @staticmethod
    def _decode_allergies(
        food_allergies: str | None,
    ) -> list[str]:

        if not food_allergies:
            return []

        try:
            decoded = json.loads(food_allergies)

            if isinstance(decoded, list):
                return [
                    str(item)
                    for item in decoded
                ]

        except (
            json.JSONDecodeError,
            TypeError,
        ):
            pass

        return []
        # ========================================================
    # GET PERSONALIZED NUTRITION
    # ========================================================

    def get_personalized_nutrition(
        self,
        user_id: int,
    ):
        db = SessionLocal()

        try:
            profile = (
                db.query(PregnancyProfile)
                .filter(
                    PregnancyProfile.user_id == user_id
                )
                .first()
            )

            if profile is None:
                return None

            lmp_date = profile.lmp_date.date()

            current_week = self.calculate_current_week(
                lmp_date
            )

            content_week = min(
                max(current_week, 1),
                40,
            )

            content = (
                db.query(PregnancyWeekContent)
                .filter(
                    PregnancyWeekContent.week
                    == content_week,
                    PregnancyWeekContent.status
                    == "published",
                )
                .first()
            )

            if content is None:
                return {
                    "current_week": current_week,
                    "content_week": content_week,
                    "nutrition_guidance": None,
                    "foods": [],
                    "dietary_preference":
                        profile.dietary_preference,
                    "custom_dietary_preference":
                        profile.custom_dietary_preference,
                    "food_allergies":
                        self._decode_allergies(
                            profile.food_allergies
                        ),
                }

            foods = (
                content.nutrition_foods_json
                or []
            )

            dietary_preference = (
                profile.dietary_preference
                or "custom"
            ).strip().lower()

            allergies = {
                allergy.strip().lower()
                for allergy in self._decode_allergies(
                    profile.food_allergies
                )
            }

            personalized_foods = []

            for food in foods:

                if not isinstance(food, dict):
                    continue

                name = str(
                    food.get("name", "")
                ).strip()

                if not name:
                    continue

                diet_types = {
                    str(item).strip().lower()
                    for item in food.get(
                        "diet_types",
                        []
                    )
                }

                allergen_tags = {
                    str(item).strip().lower()
                    for item in food.get(
                        "allergen_tags",
                        []
                    )
                }

                # ------------------------------------------------
                # DIET FILTER
                # ------------------------------------------------

                if dietary_preference == "custom":
                    # Custom diets are not interpreted automatically.
                    # Keep the curated general food list and expose
                    # the user's custom preference separately.
                    pass

                elif dietary_preference == "vegan":
                    if "vegan" not in diet_types:
                        continue

                elif dietary_preference == "vegetarian":
                    if not (
                        "vegetarian" in diet_types
                        or "vegan" in diet_types
                    ):
                        continue

                elif dietary_preference == "non_vegetarian":
                    # Non-vegetarian users can consume plant-based
                    # and animal-based foods.
                    pass

                else:
                    # Unknown preference:
                    # fall back to the general curated list rather
                    # than accidentally excluding every food.
                    pass

                # ------------------------------------------------
                # ALLERGY FILTER
                # ------------------------------------------------

                if allergies.intersection(
                    allergen_tags
                ):
                    continue

                personalized_foods.append(
                    {
                        "name": name,
                        "diet_types": sorted(
                            diet_types
                        ),
                        "allergen_tags": sorted(
                            allergen_tags
                        ),
                    }
                )

            return {
                "current_week": current_week,
                "content_week": content_week,

                "nutrition_guidance":
                    content.nutrition_guidance,

                "foods":
                    personalized_foods,

                "dietary_preference":
                    profile.dietary_preference,

                "custom_dietary_preference":
                    profile.custom_dietary_preference,

                "food_allergies":
                    sorted(allergies),

                "content_version":
                    content.content_version,

                "reviewed_at": (
                    content.reviewed_at.isoformat()
                    if content.reviewed_at
                    else None
                ),
            }
        finally:
            db.close()
    # ========================================================
    # GET EXERCISE AND SLEEP GUIDANCE
    # ========================================================

    def get_exercise_sleep_guidance(
        self,
        user_id: int,
        week: int | None = None,
    ):
        db = SessionLocal()

        try:
            profile = (
                db.query(PregnancyProfile)
                .filter(
                    PregnancyProfile.user_id == user_id
                )
                .first()
            )

            if profile is None:
                return None

            current_week = self.calculate_current_week(
                profile.lmp_date.date()
            )

            content_week = (
                current_week if week is None else week
            )

            if content_week < 1 or content_week > 40:
                raise ValueError(
                    "Pregnancy week must be between 1 and 40."
                )

            content = (
                db.query(PregnancyWeekContent)
                .filter(
                    PregnancyWeekContent.week == content_week,
                    PregnancyWeekContent.status == "published",
                )
                .first()
            )

            if content is None:
                return {
                    "current_week": current_week,
                    "content_week": content_week,
                    "activities": None,
                    "sleep_guidance": None,
                    "precautions": None,
                    "content_version": 1,
                    "status": "unavailable",
                    "reviewed_at": None,
                }

            return {
                "current_week": current_week,
                "content_week": content_week,
                "activities": content.activities,
                "sleep_guidance": content.sleep_guidance,
                "precautions": content.precautions,
                "content_version": content.content_version,
                "status": content.status,
                "reviewed_at": (
                    content.reviewed_at.isoformat()
                    if content.reviewed_at
                    else None
                ),
            }

        finally:
            db.close()


    # ========================================================
    # GET CURRENT WEEK FATHER TIP
    # ========================================================

    def get_current_week_father_tip(self, user_id: int):
        db = SessionLocal()

        try:
            profile = (
                db.query(PregnancyProfile)
                .filter(PregnancyProfile.user_id == user_id)
                .first()
            )

            if profile is None:
                return None

            lmp_date = (
                profile.lmp_date.date()
                if hasattr(profile.lmp_date, "date")
                else profile.lmp_date
            )
            current_week = self.calculate_current_week(lmp_date)
            content_week = min(max(current_week, 1), 40)

            result = db.execute(
                text("""
                    SELECT title, summary, content_json
                    FROM weekly_content
                    WHERE week_number = :week
                      AND content_type = 'father_tip'
                      AND is_active = 1
                    ORDER BY display_order ASC
                    LIMIT 1
                """),
                {"week": content_week},
            ).mappings().first()

            if result is None:
                return {
                    "current_week": current_week,
                    "content_week": content_week,
                    "title": None,
                    "tip": None,
                }

            content = result["content_json"]
            if isinstance(content, str):
                try:
                    content = json.loads(content)
                except json.JSONDecodeError:
                    content = {}

            if not isinstance(content, dict):
                content = {}

            return {
                "current_week": current_week,
                "content_week": content_week,
                "title": content.get("title") or result["title"],
                "tip": content.get("tip") or result["summary"],
            }

        finally:
            db.close()


pregnancy_service = PregnancyService()