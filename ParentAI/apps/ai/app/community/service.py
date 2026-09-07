from sqlalchemy import func

from app.database.database import SessionLocal
from app.database.models import (
    Community,
    CommunityMember,
    CommunityPost,
    ModerationEvent,
    CommunityPostReport
)
from app.community.moderation import (
    moderate_content,
)


def get_communities(user_id: int):
    db = SessionLocal()

    try:
        communities = (
            db.query(Community)
            .order_by(Community.id)
            .all()
        )

        results = []

        for community in communities:

            member_count = (
                db.query(func.count(CommunityMember.id))
                .filter(
                    CommunityMember.community_id
                    == community.id
                )
                .scalar()
            )

            membership = (
                db.query(CommunityMember)
                .filter(
                    CommunityMember.community_id
                    == community.id,
                    CommunityMember.user_id
                    == user_id,
                )
                .first()
            )

            results.append(
                {
                    "id": community.id,
                    "name": community.name,
                    "description": community.description,
                    "member_count": member_count or 0,
                    "joined": membership is not None,
                }
            )

        return results

    finally:
        db.close()


def join_community(
    community_id: int,
    user_id: int,
):
    db = SessionLocal()

    try:
        community = (
            db.query(Community)
            .filter(
                Community.id == community_id
            )
            .first()
        )

        if community is None:
            return None

        existing_membership = (
            db.query(CommunityMember)
            .filter(
                CommunityMember.community_id
                == community_id,
                CommunityMember.user_id
                == user_id,
            )
            .first()
        )

        if existing_membership is None:
            membership = CommunityMember(
                community_id=community_id,
                user_id=user_id,
            )

            db.add(membership)
            db.commit()

        return True

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()


def leave_community(
    community_id: int,
    user_id: int,
):
    db = SessionLocal()

    try:
        membership = (
            db.query(CommunityMember)
            .filter(
                CommunityMember.community_id
                == community_id,
                CommunityMember.user_id
                == user_id,
            )
            .first()
        )

        if membership is None:
            return False

        db.delete(membership)
        db.commit()

        return True

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()
def create_post(
    community_id: int,
    user_id: int,
    content: str,
):
    # --------------------------------------------------------
    # 1. Verify that the community exists and the user
    #    is a member.
    # --------------------------------------------------------

    db = SessionLocal()

    try:
        community = (
            db.query(Community)
            .filter(
                Community.id == community_id
            )
            .first()
        )

        if community is None:
            return {
                "error": "community_not_found"
            }

        membership = (
            db.query(CommunityMember)
            .filter(
                CommunityMember.community_id
                == community_id,
                CommunityMember.user_id
                == user_id,
            )
            .first()
        )

        if membership is None:
            return {
                "error": "not_member"
            }

    finally:
        db.close()

    # --------------------------------------------------------
    # 2. AI moderation happens BEFORE the post is created.
    # --------------------------------------------------------

    try:
        moderation = moderate_content(content)

    except RuntimeError:
        # Moderation failure means we do NOT publish
        # the content.
        raise

    # --------------------------------------------------------
    # 3. Store moderation result.
    # --------------------------------------------------------

    db = SessionLocal()

    try:
        moderation_event = ModerationEvent(
            user_id=user_id,
            content=content,
            result=(
                "allowed"
                if moderation.allowed
                else "blocked"
            ),
            category=moderation.category,
            confidence=moderation.confidence,
            reason=moderation.reason,
        )

        db.add(moderation_event)

        # ----------------------------------------------------
        # 4. Blocked content is NEVER inserted into
        #    community_posts.
        # ----------------------------------------------------

        if not moderation.allowed:
            db.commit()

            return {
                "error": "content_blocked",
                "category": moderation.category,
                "reason": moderation.reason,
                "confidence": moderation.confidence,
            }

        # ----------------------------------------------------
        # 5. Re-check membership before publishing.
        # ----------------------------------------------------

        membership = (
            db.query(CommunityMember)
            .filter(
                CommunityMember.community_id
                == community_id,
                CommunityMember.user_id
                == user_id,
            )
            .first()
        )

        if membership is None:
            db.rollback()

            return {
                "error": "not_member"
            }

        # ----------------------------------------------------
        # 6. Create the public post.
        # ----------------------------------------------------

        post = CommunityPost(
            community_id=community_id,
            user_id=user_id,
            content=content,
        )

        db.add(post)

        db.commit()
        db.refresh(post)

        return post

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()

def get_community_posts(community_id: int, user_id: int):
    db = SessionLocal()

    try:
        community = (
            db.query(Community)
            .filter(Community.id == community_id)
            .first()
        )

        if community is None:
            return None

        posts = (
            db.query(CommunityPost)
            .filter(
                CommunityPost.community_id == community_id
            )
            .order_by(
                CommunityPost.created_at.desc()
            )
            .all()
        )

        return [
            {
                "id": post.id,
                "community_id": post.community_id,
                "user_id": post.user_id,
                "content": post.content,
                "created_at": post.created_at,
                "updated_at": post.updated_at,
                "is_owner": post.user_id == user_id,
            }
            for post in posts
        ]

    finally:
        db.close()
def delete_post(
    community_id: int,
    post_id: int,
    user_id: int,
):
    db = SessionLocal()

    try:
        community = (
            db.query(Community)
            .filter(Community.id == community_id)
            .first()
        )

        if community is None:
            return "community_not_found"

        post = (
            db.query(CommunityPost)
            .filter(
                CommunityPost.id == post_id,
                CommunityPost.community_id == community_id,
            )
            .first()
        )

        if post is None:
            return "post_not_found"

        if post.user_id != user_id:
            return "not_owner"

        db.delete(post)
        db.commit()

        return "deleted"

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()

def report_post(
    community_id: int,
    post_id: int,
    user_id: int,
    reason: str,
    details: str | None = None,
):
    """
    Store a user report for a community post.

    Returns:
        "community_not_found"
        "post_not_found"
        "own_post"
        "already_reported"
        CommunityPostReport on success
    """

    db = SessionLocal()

    try:
        print(
            f"REPORT DEBUG: community_id={community_id}, post_id={post_id}"
        )

        all_posts = (
        db.query(CommunityPost)
        .order_by(CommunityPost.id.desc())
    .   all()
        )       

        print(
    "REPORT DEBUG: posts=",
    [
        {
            "id": post.id,
            "community_id": post.community_id,
            "user_id": post.user_id,
        }
        for post in all_posts
    ],
)
        
        # ------------------------------------------------------
        # 1. Verify community exists
        # ------------------------------------------------------

        community = (
            db.query(Community)
            .filter(
                Community.id == community_id
            )
            .first()
        )

        if community is None:
            return "community_not_found"

        # ------------------------------------------------------
        # 2. Find the post by post ID
        # ------------------------------------------------------

        post = (
            db.query(CommunityPost)
            .filter(
                CommunityPost.id == post_id
            )
            .first()
        )

        if post is None:
            return "post_not_found"

        # ------------------------------------------------------
        # 3. Verify the post belongs to this community
        # ------------------------------------------------------

        if post.community_id != community_id:
            return "post_not_found"

        # ------------------------------------------------------
        # 4. Users cannot report their own post
        # ------------------------------------------------------

        if post.user_id == user_id:
            return "own_post"

        # ------------------------------------------------------
        # 5. Prevent duplicate reports
        # ------------------------------------------------------

        existing_report = (
            db.query(CommunityPostReport)
            .filter(
                CommunityPostReport.post_id == post_id,
                CommunityPostReport.reporter_user_id == user_id,
            )
            .first()
        )

        if existing_report is not None:
            return "already_reported"

        # ------------------------------------------------------
        # 6. Create report
        # ------------------------------------------------------

        report = CommunityPostReport(
            post_id=post_id,
            reporter_user_id=user_id,
            reason=reason,
            details=details,
        )

        db.add(report)
        db.commit()
        db.refresh(report)

        return report

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()