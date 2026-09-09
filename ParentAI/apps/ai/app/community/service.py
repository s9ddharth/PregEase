import re
import unicodedata

from sqlalchemy import func

from app.database.database import SessionLocal
from app.database.models import (
    Community,
    CommunityMember,
    CommunityPost,
    ModerationEvent,
    CommunityPostReport,
    CommunityModerationRule,
    CommunityComment,
    CommunityCommentLike,
    CommunityCommentReport,
    User,
)
from app.community.moderation import (
    moderate_content,
)



def _slugify(value: str) -> str:
    """Create a URL-safe community slug from a display name."""
    value = unicodedata.normalize("NFKC", value).strip().lower()
    value = value.replace("&", " and ")
    value = re.sub(r"[^a-z0-9]+", "-", value)
    return value.strip("-")[:150]


def _unique_slug(db, name: str) -> str:
    """Return a globally unique slug, adding a numeric suffix when needed."""
    base = _slugify(name)

    if not base:
        raise ValueError("Community name cannot produce a valid slug.")

    slug = base
    suffix = 2

    while db.query(Community).filter(Community.slug == slug).first() is not None:
        suffix_text = f"-{suffix}"
        slug = f"{base[:150 - len(suffix_text)]}{suffix_text}"
        suffix += 1

    return slug


def create_community(
    user_id: int,
    name: str,
    description: str | None,
    category: str | None,
    icon_url: str | None,
    visibility: str,
    membership_mode: str,
    rules: list[dict],
):
    """Create a community, its owner membership, and initial rules atomically."""
    db = SessionLocal()

    try:
        name = name.strip()
        description = description.strip() if description else None
        category = category.strip() if category else None
        icon_url = icon_url.strip() if icon_url else None
        visibility = visibility.strip().lower()
        membership_mode = membership_mode.strip().lower()

        if visibility not in {"public", "private"}:
            return {"error": "invalid_visibility"}

        if membership_mode not in {"open", "approval"}:
            return {"error": "invalid_membership_mode"}

        if visibility == "private" and membership_mode != "approval":
            return {"error": "invalid_visibility_membership_combination"}

        existing_name = (
            db.query(Community)
            .filter(func.lower(Community.name) == name.lower())
            .first()
        )

        if existing_name is not None:
            return {"error": "name_taken"}

        slug = _unique_slug(db, name)

        community = Community(
            name=name,
            description=description,
            category=category,
            icon_url=icon_url,
            visibility=visibility,
            membership_mode=membership_mode,
            created_by=user_id,
            slug=slug,
        )

        db.add(community)
        db.flush()

        membership = CommunityMember(
            community_id=community.id,
            user_id=user_id,
            role="owner",
            status="active",
        )
        db.add(membership)

        for index, rule in enumerate(rules):
            db.add(
                CommunityModerationRule(
                    community_id=community.id,
                    title=rule["title"].strip(),
                    description=rule["description"].strip(),
                    sort_order=index,
                )
            )

        db.commit()
        db.refresh(community)

        return {
            "id": community.id,
            "name": community.name,
            "description": community.description,
            "category": community.category,
            "icon_url": community.icon_url,
            "visibility": community.visibility,
            "membership_mode": community.membership_mode,
            "slug": community.slug,
            "member_count": 1,
            "joined": True,
            "role": "owner",
            "status": "active",
            "created_by": community.created_by,
        }

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()


def get_communities(
    user_id: int,
    search: str | None = None,
    category: str | None = None,
    sort: str = "newest",
):
    db = SessionLocal()

    try:
        query = db.query(Community)

        # Search by community name or description.
        if search:
            search_term = f"%{search.strip()}%"

            query = query.filter(
                Community.name.ilike(search_term)
                | Community.description.ilike(search_term)
            )

        # Filter by category.
        if category:
            query = query.filter(
                Community.category.ilike(category.strip())
            )

        # Sorting.
        if sort == "popular":
            query = (
                query.outerjoin(
                    CommunityMember,
                    (
                        (CommunityMember.community_id == Community.id)
                        & (CommunityMember.status == "active")
                    ),
                )
                .group_by(Community.id)
                .order_by(
                    func.count(CommunityMember.id).desc(),
                    Community.id.desc(),
                )
            )
        else:
            # newest
            query = query.order_by(
                Community.created_at.desc(),
                Community.id.desc(),
            )

        communities = query.all()

        results = []

        for community in communities:
            member_count = (
                db.query(func.count(CommunityMember.id))
                .filter(
                    CommunityMember.community_id == community.id,
                    CommunityMember.status == "active",
                )
                .scalar()
            )

            membership = (
                db.query(CommunityMember)
                .filter(
                    CommunityMember.community_id == community.id,
                    CommunityMember.user_id == user_id,
                )
                .first()
            )

            results.append(
                {
                    "id": community.id,
                    "name": community.name,
                    "description": community.description,
                    "category": community.category,
                    "icon_url": community.icon_url,
                    "visibility": community.visibility,
                    "membership_mode": community.membership_mode,
                    "slug": community.slug,
                    "member_count": member_count or 0,
                    "joined": (
                        membership is not None
                        and membership.status == "active"
                    ),
                    "role": membership.role if membership else None,
                    "status": membership.status if membership else None,
                    "created_by": community.created_by,
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
            .filter(Community.id == community_id)
            .first()
        )

        if community is None:
            return None

        existing_membership = (
            db.query(CommunityMember)
            .filter(
                CommunityMember.community_id == community_id,
                CommunityMember.user_id == user_id,
            )
            .first()
        )

        if existing_membership is not None:
            return {
                "status": existing_membership.status,
                "role": existing_membership.role,
            }

        membership_status = (
            "pending"
            if community.membership_mode == "approval"
            else "active"
        )

        membership = CommunityMember(
            community_id=community_id,
            user_id=user_id,
            role="member",
            status=membership_status,
        )

        db.add(membership)
        db.commit()

        return {
            "status": membership_status,
            "role": "member",
        }

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

def _get_active_member(db, community_id: int, user_id: int):
    return (
        db.query(CommunityMember)
        .filter(
            CommunityMember.community_id == community_id,
            CommunityMember.user_id == user_id,
            CommunityMember.status == "active",
        )
        .first()
    )


def add_moderator(
    community_id: int,
    owner_user_id: int,
    target_user_id: int,
):
    db = SessionLocal()

    try:
        community = (
            db.query(Community)
            .filter(Community.id == community_id)
            .first()
        )

        if not community:
            return "community_not_found"

        owner = _get_active_member(
            db,
            community_id,
            owner_user_id,
        )

        if not owner or owner.role != "owner":
            return "not_owner"

        target = _get_active_member(
            db,
            community_id,
            target_user_id,
        )

        if not target:
            return "target_not_member"

        if target.role == "owner":
            return "target_is_owner"

        if target.role == "moderator":
            return "already_moderator"

        target.role = "moderator"

        db.commit()

        return "success"

    finally:
        db.close()


def remove_moderator(
    community_id: int,
    owner_user_id: int,
    target_user_id: int,
):
    db = SessionLocal()

    try:
        community = (
            db.query(Community)
            .filter(Community.id == community_id)
            .first()
        )

        if not community:
            return "community_not_found"

        owner = _get_active_member(
            db,
            community_id,
            owner_user_id,
        )

        if not owner or owner.role != "owner":
            return "not_owner"

        target = _get_active_member(
            db,
            community_id,
            target_user_id,
        )

        if not target:
            return "target_not_member"

        if target.role != "moderator":
            return "not_moderator"

        target.role = "member"

        db.commit()

        return "success"

    finally:
        db.close()


def transfer_ownership(
    community_id: int,
    current_owner_user_id: int,
    new_owner_user_id: int,
):
    db = SessionLocal()

    try:
        community = (
            db.query(Community)
            .filter(Community.id == community_id)
            .with_for_update()
            .first()
        )

        if not community:
            return "community_not_found"

        current_owner = _get_active_member(
            db,
            community_id,
            current_owner_user_id,
        )

        if not current_owner or current_owner.role != "owner":
            return "not_owner"

        if current_owner_user_id == new_owner_user_id:
            return "same_owner"

        new_owner = _get_active_member(
            db,
            community_id,
            new_owner_user_id,
        )

        if not new_owner:
            return "target_not_member"

        # Previous owner becomes moderator.
        current_owner.role = "moderator"

        # Existing active member becomes owner.
        new_owner.role = "owner"

        db.commit()

        return "success"

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()

def _get_community_manager(
    db,
    community_id: int,
    user_id: int,
):
    return (
        db.query(CommunityMember)
        .filter(
            CommunityMember.community_id == community_id,
            CommunityMember.user_id == user_id,
            CommunityMember.status == "active",
            CommunityMember.role.in_(["owner", "moderator"]),
        )
        .first()
    )


def get_community_rules(
    community_id: int,
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

        rules = (
            db.query(CommunityModerationRule)
            .filter(
                CommunityModerationRule.community_id
                == community_id
            )
            .order_by(
                CommunityModerationRule.sort_order.asc(),
                CommunityModerationRule.id.asc(),
            )
            .all()
        )

        return rules

    finally:
        db.close()


def create_community_rule(
    community_id: int,
    user_id: int,
    title: str,
    description: str,
    sort_order: int,
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
            return "community_not_found"

        manager = _get_community_manager(
            db,
            community_id,
            user_id,
        )

        if manager is None:
            return "not_manager"

        rule = CommunityModerationRule(
            community_id=community_id,
            title=title.strip(),
            description=description.strip(),
            sort_order=sort_order,
        )

        db.add(rule)
        db.commit()
        db.refresh(rule)

        return rule

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()


def update_community_rule(
    community_id: int,
    rule_id: int,
    user_id: int,
    title: str,
    description: str,
    sort_order: int,
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
            return "community_not_found"

        manager = _get_community_manager(
            db,
            community_id,
            user_id,
        )

        if manager is None:
            return "not_manager"

        rule = (
            db.query(CommunityModerationRule)
            .filter(
                CommunityModerationRule.id == rule_id,
                CommunityModerationRule.community_id
                == community_id,
            )
            .first()
        )

        if rule is None:
            return "rule_not_found"

        rule.title = title.strip()
        rule.description = description.strip()
        rule.sort_order = sort_order

        db.commit()
        db.refresh(rule)

        return rule

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()


def delete_community_rule(
    community_id: int,
    rule_id: int,
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
            return "community_not_found"

        manager = _get_community_manager(
            db,
            community_id,
            user_id,
        )

        if manager is None:
            return "not_manager"

        rule = (
            db.query(CommunityModerationRule)
            .filter(
                CommunityModerationRule.id == rule_id,
                CommunityModerationRule.community_id
                == community_id,
            )
            .first()
        )

        if rule is None:
            return "rule_not_found"

        db.delete(rule)
        db.commit()

        return "deleted"

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()
def get_community_details(
    community_id: int,
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
            return None

        member_count = (
            db.query(CommunityMember)
            .filter(
                CommunityMember.community_id == community_id,
                CommunityMember.status == "active",
            )
            .count()
        )

        membership = (
            db.query(CommunityMember)
            .filter(
                CommunityMember.community_id == community_id,
                CommunityMember.user_id == user_id,
            )
            .first()
        )

        return {
            "id": community.id,
            "name": community.name,
            "description": community.description,
            "category": community.category,
            "icon_url": community.icon_url,
            "visibility": community.visibility,
            "membership_mode": community.membership_mode,
            "slug": community.slug,
            "created_by": community.created_by,
            "created_at": community.created_at,
            "updated_at": community.updated_at,
            "member_count": member_count,
            "joined": (
                membership is not None
                and membership.status == "active"
            ),
            "role": (
                membership.role
                if membership is not None
                else None
            ),
            "status": (
                membership.status
                if membership is not None
                else None
            ),
        }

    finally:
        db.close()
def create_comment(
    community_id: int,
    post_id: int,
    user_id: int,
    content: str,
):
    db = SessionLocal()

    try:
        community = (
            db.query(Community)
            .filter(Community.id == community_id)
            .first()
        )

        if community is None:
            return {"error": "community_not_found"}

        member = _get_active_member(
            db,
            community_id,
            user_id,
        )

        if member is None:
            return {"error": "not_member"}

        post = (
            db.query(CommunityPost)
            .filter(
                CommunityPost.id == post_id,
                CommunityPost.community_id == community_id,
            )
            .first()
        )

        if post is None:
            return {"error": "post_not_found"}

        moderation_result = moderate_content(content)

        if moderation_result["result"] == "blocked":
            return {
                "error": "content_blocked",
                "category": moderation_result.get("category"),
                "reason": moderation_result.get("reason"),
            }

        comment = CommunityComment(
            post_id=post_id,
            user_id=user_id,
            content=content.strip(),
        )

        db.add(comment)
        db.commit()
        db.refresh(comment)

        return {
            "id": comment.id,
            "post_id": comment.post_id,
            "user_id": comment.user_id,
            "content": comment.content,
            "created_at": comment.created_at,
            "like_count": 0,
            "liked": False,
        }

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()


def get_post_comments(
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
            return None

        post = (
            db.query(CommunityPost)
            .filter(
                CommunityPost.id == post_id,
                CommunityPost.community_id == community_id,
            )
            .first()
        )

        if post is None:
            return None

        comments = (
            db.query(CommunityComment)
            .filter(
                CommunityComment.post_id == post_id,
            )
            .order_by(
                CommunityComment.created_at.asc(),
                CommunityComment.id.asc(),
            )
            .all()
        )

        result = []

        for comment in comments:
            like_count = (
                db.query(CommunityCommentLike)
                .filter(
                    CommunityCommentLike.comment_id == comment.id,
                )
                .count()
            )

            liked = (
                db.query(CommunityCommentLike)
                .filter(
                    CommunityCommentLike.comment_id == comment.id,
                    CommunityCommentLike.user_id == user_id,
                )
                .first()
                is not None
            )

            result.append(
                {
                    "id": comment.id,
                    "post_id": comment.post_id,
                    "user_id": comment.user_id,
                    "content": comment.content,
                    "created_at": comment.created_at,
                    "like_count": like_count,
                    "liked": liked,
                }
            )

        return result

    finally:
        db.close()


def delete_comment(
    community_id: int,
    post_id: int,
    comment_id: int,
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

        comment = (
            db.query(CommunityComment)
            .join(
                CommunityPost,
                CommunityComment.post_id == CommunityPost.id,
            )
            .filter(
                CommunityComment.id == comment_id,
                CommunityPost.id == post_id,
                CommunityPost.community_id == community_id,
            )
            .first()
        )

        if comment is None:
            return "comment_not_found"

        member = _get_active_member(
            db,
            community_id,
            user_id,
        )

        if member is None:
            return "not_member"

        if (
            comment.user_id != user_id
            and member.role not in ["owner", "moderator"]
        ):
            return "not_allowed"

        db.delete(comment)
        db.commit()

        return "deleted"

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()

def like_comment(
    community_id: int,
    post_id: int,
    comment_id: int,
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

        member = _get_active_member(
            db,
            community_id,
            user_id,
        )

        if member is None:
            return "not_member"

        comment = (
            db.query(CommunityComment)
            .join(
                CommunityPost,
                CommunityComment.post_id == CommunityPost.id,
            )
            .filter(
                CommunityComment.id == comment_id,
                CommunityPost.id == post_id,
                CommunityPost.community_id == community_id,
            )
            .first()
        )

        if comment is None:
            return "comment_not_found"

        existing_like = (
            db.query(CommunityCommentLike)
            .filter(
                CommunityCommentLike.comment_id == comment_id,
                CommunityCommentLike.user_id == user_id,
            )
            .first()
        )

        if existing_like is not None:
            return "already_liked"

        like = CommunityCommentLike(
            comment_id=comment_id,
            user_id=user_id,
        )

        db.add(like)
        db.commit()

        return "liked"

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()


def unlike_comment(
    community_id: int,
    post_id: int,
    comment_id: int,
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

        member = _get_active_member(
            db,
            community_id,
            user_id,
        )

        if member is None:
            return "not_member"

        comment = (
            db.query(CommunityComment)
            .join(
                CommunityPost,
                CommunityComment.post_id == CommunityPost.id,
            )
            .filter(
                CommunityComment.id == comment_id,
                CommunityPost.id == post_id,
                CommunityPost.community_id == community_id,
            )
            .first()
        )

        if comment is None:
            return "comment_not_found"

        like = (
            db.query(CommunityCommentLike)
            .filter(
                CommunityCommentLike.comment_id == comment_id,
                CommunityCommentLike.user_id == user_id,
            )
            .first()
        )

        if like is None:
            return "not_liked"

        db.delete(like)
        db.commit()

        return "unliked"

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()


def report_comment(
    community_id: int,
    post_id: int,
    comment_id: int,
    user_id: int,
    reason: str,
    details: str | None,
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

        member = _get_active_member(
            db,
            community_id,
            user_id,
        )

        if member is None:
            return "not_member"

        comment = (
            db.query(CommunityComment)
            .join(
                CommunityPost,
                CommunityComment.post_id == CommunityPost.id,
            )
            .filter(
                CommunityComment.id == comment_id,
                CommunityPost.id == post_id,
                CommunityPost.community_id == community_id,
            )
            .first()
        )

        if comment is None:
            return "comment_not_found"

        if comment.user_id == user_id:
            return "own_comment"

        existing_report = (
            db.query(CommunityCommentReport)
            .filter(
                CommunityCommentReport.comment_id == comment_id,
                CommunityCommentReport.reporter_user_id == user_id,
            )
            .first()
        )

        if existing_report is not None:
            return "already_reported"

        report = CommunityCommentReport(
            comment_id=comment_id,
            reporter_user_id=user_id,
            reason=reason.strip(),
            details=details.strip() if details else None,
        )

        db.add(report)
        db.commit()

        return "reported"

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()

def get_community_members(community_id: int):
    db = SessionLocal()

    try:
        community = (
            db.query(Community)
            .filter(Community.id == community_id)
            .first()
        )

        if community is None:
            return None

        members = (
            db.query(CommunityMember, User)
            .join(User, User.id == CommunityMember.user_id)
            .filter(
                CommunityMember.community_id == community_id,
                CommunityMember.status == "active",
            )
            .order_by(
                CommunityMember.role.asc(),
                CommunityMember.joined_at.asc(),
            )
            .all()
        )

        return [
            {
                "user_id": member.user_id,
                "name": user.name,
                "role": member.role,
                "joined_at": member.joined_at,
            }
            for member, user in members
        ]

    finally:
        db.close()

def delete_community(community_id: int, user_id: int):
    db = SessionLocal()

    try:
        community = (
            db.query(Community)
            .filter(Community.id == community_id)
            .first()
        )

        if community is None:
            return "community_not_found"

        # PregEase-managed/system communities cannot be deleted.
        if community.created_by is None:
            return "system_community"

        # Only the community owner can delete it.
        owner = (
            db.query(CommunityMember)
            .filter(
                CommunityMember.community_id == community_id,
                CommunityMember.user_id == user_id,
                CommunityMember.role == "owner",
                CommunityMember.status == "active",
            )
            .first()
        )

        if owner is None:
            return "not_owner"

        db.delete(community)
        db.commit()

        return "success"

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()

def get_community_reports(community_id: int, user_id: int):
    db = SessionLocal()

    try:
        community = (
            db.query(Community)
            .filter(Community.id == community_id)
            .first()
        )

        if community is None:
            return "community_not_found"

        manager = _get_community_manager(
            db,
            community_id,
            user_id,
        )

        if manager is None:
            return "not_manager"

        post_reports = (
            db.query(CommunityPostReport)
            .join(
                CommunityPost,
                CommunityPost.id == CommunityPostReport.post_id,
            )
            .filter(
                CommunityPost.community_id == community_id,
                CommunityPostReport.status == "open",
            )
            .all()
        )

        comment_reports = (
            db.query(CommunityCommentReport)
            .join(
                CommunityComment,
                CommunityComment.id == CommunityCommentReport.comment_id,
            )
            .join(
                CommunityPost,
                CommunityPost.id == CommunityComment.post_id,
            )
            .filter(
                CommunityPost.community_id == community_id,
                CommunityCommentReport.status == "open",
            )
            .all()
        )

        reports = []

        for report in post_reports:
            reports.append(
                {
                    "report_id": report.id,
                    "type": "post",
                    "content_id": report.post_id,
                    "reported_by": report.reporter_user_id,
                    "reason": report.reason,
                    "details": report.details,
                    "status": report.status,
                    "created_at": report.created_at,
                }
            )

        for report in comment_reports:
            reports.append(
                {
                    "report_id": report.id,
                    "type": "comment",
                    "content_id": report.comment_id,
                    "reported_by": report.reporter_user_id,
                    "reason": report.reason,
                    "details": report.details,
                    "status": report.status,
                    "created_at": report.created_at,
                }
            )

        reports.sort(
            key=lambda report: (
                report["created_at"],
                report["report_id"],
            ),
            reverse=True,
        )

        return reports

    finally:
        db.close()

def resolve_community_report(
    community_id: int,
    report_id: int,
    user_id: int,
    action: str,
):
    db = SessionLocal()

    try:
        if action not in {"dismiss", "remove"}:
            return "invalid_action"

        community = (
            db.query(Community)
            .filter(Community.id == community_id)
            .first()
        )

        if community is None:
            return "community_not_found"

        manager = _get_community_manager(
            db,
            community_id,
            user_id,
        )

        if manager is None:
            return "not_manager"

        # Check post report first.
        post_report = (
            db.query(CommunityPostReport)
            .join(
                CommunityPost,
                CommunityPost.id == CommunityPostReport.post_id,
            )
            .filter(
                CommunityPostReport.id == report_id,
                CommunityPost.community_id == community_id,
            )
            .first()
        )

        if post_report is not None:
            if post_report.status == "resolved":
                return "already_resolved"

            if action == "remove":
                db.delete(
                    db.query(CommunityPost)
                    .filter(CommunityPost.id == post_report.post_id)
                    .first()
                )

            post_report.status = "resolved"
            db.commit()

            return "success"

        # Check comment report.
        comment_report = (
            db.query(CommunityCommentReport)
            .join(
                CommunityComment,
                CommunityComment.id == CommunityCommentReport.comment_id,
            )
            .join(
                CommunityPost,
                CommunityPost.id == CommunityComment.post_id,
            )
            .filter(
                CommunityCommentReport.id == report_id,
                CommunityPost.community_id == community_id,
            )
            .first()
        )

        if comment_report is not None:
            if comment_report.status == "resolved":
                return "already_resolved"

            if action == "remove":
                db.delete(
                    db.query(CommunityComment)
                    .filter(
                        CommunityComment.id == comment_report.comment_id
                    )
                    .first()
                )

            comment_report.status = "resolved"
            db.commit()

            return "success"

        return "report_not_found"

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()