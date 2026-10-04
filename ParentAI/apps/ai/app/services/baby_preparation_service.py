from datetime import datetime

from app.database.models import (
    BabyPreparationProgress,
    PregnancyProfile,
    PregnancyWeekContent,
)
from app.database.session import SessionLocal
from app.services.pregnancy_service import (
    pregnancy_service,
)


class BabyPreparationService:
    """
    Provides weekly baby-preparation guidance and saves
    checklist progress for each user and pregnancy week.
    """

    @staticmethod
    def _checklist_for_week(week: int) -> list[dict]:
        """
        Initial MVP checklist definitions.

        These are general preparation tasks, not medical
        instructions. The same checklist is returned when
        a user revisits the same week.
        """
        if week <= 12:
            items = [
                (
                    "discuss_support",
                    "Discuss questions and support needs at an antenatal visit",
                ),
                (
                    "start_notes",
                    "Start a list of questions for your care team",
                ),
                (
                    "review_budget",
                    "Start planning a budget for baby essentials",
                ),
            ]
        elif week <= 20:
            items = [
                (
                    "review_birth_questions",
                    "Write down questions about birth and care options",
                ),
                (
                    "identify_support",
                    "Discuss who may support you during pregnancy and birth",
                ),
                (
                    "baby_essentials_list",
                    "Start a list of essential baby items",
                ),
            ]
        elif week <= 28:
            items = [
                (
                    "birth_preferences",
                    "Discuss birth preferences with your care team",
                ),
                (
                    "transport_plan",
                    "Consider transport arrangements for the birth",
                ),
                (
                    "sleep_space",
                    "Research a safe sleep space for your baby",
                ),
                (
                    "support_after_birth",
                    "Plan who can help during the first days at home",
                ),
            ]
        elif week <= 36:
            items = [
                (
                    "hospital_bag",
                    "Prepare a draft list for your hospital bag",
                ),
                (
                    "documents",
                    "Check which documents your maternity facility requires",
                ),
                (
                    "transport_confirm",
                    "Confirm your transport plan for the birth",
                ),
                (
                    "safe_sleep_setup",
                    "Prepare a suitable safe sleep space",
                ),
                (
                    "feeding_questions",
                    "Write down questions about feeding and newborn care",
                ),
            ]
        else:
            items = [
                (
                    "hospital_bag_check",
                    "Review your hospital bag and essential documents",
                ),
                (
                    "transport_final",
                    "Make sure your transport and support contacts are ready",
                ),
                (
                    "newborn_supplies",
                    "Check that basic newborn supplies are available",
                ),
                (
                    "safe_sleep_final",
                    "Check the baby's sleep space is ready",
                ),
                (
                    "care_team_contacts",
                    "Keep your maternity care team's contact details accessible",
                ),
            ]

        return [
            {"key": key, "title": title}
            for key, title in items
        ]

    def get_checklist(self, user_id: int, week: int | None = None):
        db = SessionLocal()

        try:
            profile = (
                db.query(PregnancyProfile)
                .filter(PregnancyProfile.user_id == user_id)
                .first()
            )

            if profile is None:
                return None

            current_week = (
                pregnancy_service.calculate_current_week(
                    profile.lmp_date.date()
                )
            )

            target_week = current_week if week is None else week

            if target_week < 1 or target_week > 40:
                raise ValueError(
                    "Pregnancy week must be between 1 and 40."
                )

            content_week = min(max(target_week, 1), 40)

            content = (
                db.query(PregnancyWeekContent)
                .filter(
                    PregnancyWeekContent.week == content_week,
                    PregnancyWeekContent.status == "published",
                )
                .first()
            )

            checklist_items = self._checklist_for_week(
                content_week
            )

            progress_rows = (
                db.query(BabyPreparationProgress)
                .filter(
                    BabyPreparationProgress.user_id == user_id,
                    BabyPreparationProgress.week == content_week,
                )
                .all()
            )

            progress_by_key = {
                row.item_key: row
                for row in progress_rows
            }

            items = []

            for item in checklist_items:
                progress = progress_by_key.get(item["key"])

                items.append(
                    {
                        **item,
                        "is_completed": (
                            progress.is_completed
                            if progress
                            else False
                        ),
                        "completed_at": (
                            progress.completed_at.isoformat()
                            if progress and progress.completed_at
                            else None
                        ),
                    }
                )

            completed_count = sum(
                1 for item in items if item["is_completed"]
            )

            return {
                "current_week": current_week,
                "checklist_week": content_week,
                "guidance": (
                    content.baby_preparation
                    if content
                    else None
                ),
                "items": items,
                "completed_count": completed_count,
                "total_count": len(items),
            }

        finally:
            db.close()

    def update_item(
        self,
        user_id: int,
        week: int,
        item_key: str,
        is_completed: bool,
    ):
        if week < 1 or week > 40:
            raise ValueError(
                "Pregnancy week must be between 1 and 40."
            )

        allowed_items = {
            item["key"]
            for item in self._checklist_for_week(week)
        }

        if item_key not in allowed_items:
            raise ValueError(
                "Checklist item is not valid for this pregnancy week."
            )

        db = SessionLocal()

        try:
            profile = (
                db.query(PregnancyProfile)
                .filter(PregnancyProfile.user_id == user_id)
                .first()
            )

            if profile is None:
                return None

            progress = (
                db.query(BabyPreparationProgress)
                .filter(
                    BabyPreparationProgress.user_id == user_id,
                    BabyPreparationProgress.week == week,
                    BabyPreparationProgress.item_key == item_key,
                )
                .first()
            )

            now = datetime.utcnow()

            if progress is None:
                progress = BabyPreparationProgress(
                    user_id=user_id,
                    week=week,
                    item_key=item_key,
                    is_completed=is_completed,
                    completed_at=now if is_completed else None,
                )
                db.add(progress)
            else:
                progress.is_completed = is_completed
                progress.completed_at = (
                    now if is_completed else None
                )

            db.commit()

            return {
                "week": week,
                "item_key": item_key,
                "is_completed": is_completed,
                "completed_at": (
                    progress.completed_at.isoformat()
                    if progress.completed_at
                    else None
                ),
            }

        except Exception:
            db.rollback()
            raise

        finally:
            db.close()


baby_preparation_service = BabyPreparationService()