from fastapi import APIRouter, Depends, HTTPException, status

from app.api.dependencies import get_current_user_id

from app.community.schemas import (
    CommunityResponse,
    CreateCommunityRequest,
    CommunityDetailsResponse,
    CreatePostRequest,
    PostResponse,
    PostFeedResponse,
    ReportPostRequest,
    TransferOwnershipRequest,
    CommunityRuleResponse,
    CreateCommunityRuleRequest,
    UpdateCommunityRuleRequest,
    CommentResponse,
    CreateCommentRequest,
    ReportCommentRequest,
    CommunityMemberResponse,
    CommunityReportResponse,
    ResolveCommunityReportRequest,
)

from app.community.service import (
    get_communities,
    create_community,
    get_community_details,
    get_community_members,
    delete_community,
    join_community,
    leave_community,
    create_post,
    get_community_posts,
    delete_post,
    report_post,
    add_moderator,
    remove_moderator,
    transfer_ownership,
    get_community_rules,
    create_community_rule,
    update_community_rule,
    delete_community_rule,
    create_comment,
    get_post_comments,
    delete_comment,
    like_comment,
    unlike_comment,
    report_comment,
    get_community_reports,
    resolve_community_report,
)

router = APIRouter(
    prefix="/community",
    tags=["Community"],
)


# ============================================================
# Communities
# ============================================================

@router.post(
    "",
    response_model=CommunityResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_community_endpoint(
    request: CreateCommunityRequest,
    user_id: int = Depends(get_current_user_id),
):
    try:
        result = create_community(
            user_id=user_id,
            name=request.name,
            description=request.description,
            category=request.category,
            icon_url=request.icon_url,
            visibility=request.visibility,
            membership_mode=request.membership_mode,
            rules=[
                {
                    "title": rule.title,
                    "description": rule.description,
                }
                for rule in request.rules
            ],
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(exc),
        )

    if result["error"] == "name_taken":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A community with this name already exists.",
        )

    if result["error"] == "invalid_visibility":
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Visibility must be public or private.",
        )

    if result["error"] == "invalid_membership_mode":
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Membership mode must be open or approval.",
        )

    if result["error"] == "invalid_visibility_membership_combination":
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Private communities must use approval membership.",
        )

    return result


@router.get("", response_model=list[CommunityResponse])
def list_communities(
    search: str | None = None,
    category: str | None = None,
    sort: str = "newest",
    user_id: int = Depends(get_current_user_id),
):
    if sort not in {"popular", "newest"}:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="sort must be 'popular' or 'newest'.",
        )

    return get_communities(
        user_id=user_id,
        search=search,
        category=category,
        sort=sort,
    )


@router.post(
    "/{community_id}/join",
)
def join(
    community_id: int,
    user_id: int = Depends(get_current_user_id),
):
    result = join_community(
        community_id=community_id,
        user_id=user_id,
    )

    if result is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community not found.",
        )

    return {
        "message": "Joined community successfully.",
    }


@router.delete(
    "/{community_id}/join",
)
def leave(
    community_id: int,
    user_id: int = Depends(get_current_user_id),
):
    result = leave_community(
        community_id=community_id,
        user_id=user_id,
    )

    if result is False:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="You are not a member of this community.",
        )

    return {
        "message": "Left community successfully.",
    }


# ============================================================
# Posts
# ============================================================

@router.post(
    "/{community_id}/posts",
    response_model=PostResponse,
)
def create_community_post(
    community_id: int,
    request: CreatePostRequest,
    user_id: int = Depends(get_current_user_id),
):
    try:
        result = create_post(
            community_id=community_id,
            user_id=user_id,
            content=request.content,
        )

    except RuntimeError:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=(
                "Community moderation is temporarily unavailable. "
                "Please try again."
            ),
        )

    if isinstance(result, dict):
        error = result.get("error")

        if error == "community_not_found":
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Community not found.",
            )

        if error == "not_member":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=(
                    "Join the community before creating a post."
                ),
            )

        if error == "content_blocked":
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail={
                    "message": (
                        "Your post was blocked by community moderation."
                    ),
                    "category": result.get("category"),
                    "reason": result.get("reason"),
                },
            )

    return result


@router.get(
    "/{community_id}/posts",
    response_model=list[PostFeedResponse],
)
def list_community_posts(
    community_id: int,
    user_id: int = Depends(get_current_user_id),
):
    posts = get_community_posts(
        community_id,
        user_id,
    )

    if posts is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community not found.",
        )

    return posts


# ============================================================
# Delete Post
# ============================================================

@router.delete(
    "/{community_id}/posts/{post_id}",
)
def delete_community_post(
    community_id: int,
    post_id: int,
    user_id: int = Depends(get_current_user_id),
):
    result = delete_post(
        community_id=community_id,
        post_id=post_id,
        user_id=user_id,
    )

    if result == "community_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community not found.",
        )

    if result == "post_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Post not found.",
        )

    if result == "not_owner":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only delete your own posts.",
        )

    return {
        "message": "Post deleted successfully.",
    }


# ============================================================
# Report Post
# ============================================================

@router.post(
    "/{community_id}/posts/{post_id}/report",
)
def report_community_post(
    community_id: int,
    post_id: int,
    request: ReportPostRequest,
    user_id: int = Depends(get_current_user_id),
):
    result = report_post(
        community_id=community_id,
        post_id=post_id,
        user_id=user_id,
        reason=request.reason,
        details=request.details,
    )

    if result == "community_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community not found.",
        )

    if result == "post_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Post not found.",
        )

    if result == "own_post":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You cannot report your own post.",
        )

    if result == "already_reported":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="You have already reported this post.",
        )

    return {
        "message": "Report submitted successfully.",
    }

@router.post("/{community_id}/moderators/{target_user_id}")
def add_community_moderator(
    community_id: int,
    target_user_id: int,
    user_id: int = Depends(get_current_user_id),
):
    result = add_moderator(
        community_id=community_id,
        owner_user_id=user_id,
        target_user_id=target_user_id,
    )
    if result == "community_not_found":
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Community not found.")
    if result == "not_owner":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only the community owner can manage moderators.")
    if result == "target_not_member":
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Target user is not an active member of this community.")
    if result == "target_is_owner":
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="The target user is already the owner.")
    if result == "already_moderator":
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="The target user is already a moderator.")
    return {"message": "Moderator added successfully."}


@router.delete("/{community_id}/moderators/{target_user_id}")
def remove_community_moderator(
    community_id: int,
    target_user_id: int,
    user_id: int = Depends(get_current_user_id),
):
    result = remove_moderator(
        community_id=community_id,
        owner_user_id=user_id,
        target_user_id=target_user_id,
    )
    if result == "community_not_found":
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Community not found.")
    if result == "not_owner":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only the community owner can manage moderators.")
    if result == "target_not_member":
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Target user is not an active member of this community.")
    if result == "not_moderator":
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="The target user is not a moderator.")
    return {"message": "Moderator removed successfully."}


@router.post("/{community_id}/transfer-ownership")
def transfer_community_ownership(
    community_id: int,
    request: TransferOwnershipRequest,
    user_id: int = Depends(get_current_user_id),
):
    result = transfer_ownership(
        community_id=community_id,
        current_owner_user_id=user_id,
        new_owner_user_id=request.new_owner_user_id,
    )
    if result == "community_not_found":
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Community not found.")
    if result == "not_owner":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only the current community owner can transfer ownership.")
    if result == "same_owner":
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="The new owner must be a different user.")
    if result == "target_not_member":
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="The new owner must be an active community member.")
    return {"message": "Community ownership transferred successfully."}

# ============================================================
# Community Rules
# ============================================================

@router.get(
    "/{community_id}/rules",
    response_model=list[CommunityRuleResponse],
)
def list_community_rules(
    community_id: int,
    user_id: int = Depends(get_current_user_id),
):
    rules = get_community_rules(
        community_id=community_id,
    )

    if rules is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community not found.",
        )

    return rules


@router.post(
    "/{community_id}/rules",
    response_model=CommunityRuleResponse,
)
def create_rule(
    community_id: int,
    request: CreateCommunityRuleRequest,
    user_id: int = Depends(get_current_user_id),
):
    result = create_community_rule(
        community_id=community_id,
        user_id=user_id,
        title=request.title,
        description=request.description,
        sort_order=request.sort_order,
    )

    if result == "community_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community not found.",
        )

    if result == "not_manager":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "Only the community owner or a moderator "
                "can manage community rules."
            ),
        )

    return result


@router.put(
    "/{community_id}/rules/{rule_id}",
    response_model=CommunityRuleResponse,
)
def update_rule(
    community_id: int,
    rule_id: int,
    request: UpdateCommunityRuleRequest,
    user_id: int = Depends(get_current_user_id),
):
    result = update_community_rule(
        community_id=community_id,
        rule_id=rule_id,
        user_id=user_id,
        title=request.title,
        description=request.description,
        sort_order=request.sort_order,
    )

    if result == "community_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community not found.",
        )

    if result == "not_manager":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "Only the community owner or a moderator "
                "can manage community rules."
            ),
        )

    if result == "rule_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community rule not found.",
        )

    return result


@router.delete(
    "/{community_id}/rules/{rule_id}",
)
def delete_rule(
    community_id: int,
    rule_id: int,
    user_id: int = Depends(get_current_user_id),
):
    result = delete_community_rule(
        community_id=community_id,
        rule_id=rule_id,
        user_id=user_id,
    )

    if result == "community_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community not found.",
        )

    if result == "not_manager":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "Only the community owner or a moderator "
                "can manage community rules."
            ),
        )

    if result == "rule_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community rule not found.",
        )

    return {
        "message": "Community rule deleted successfully.",
    }

@router.get(
    "/{community_id}",
    response_model=CommunityResponse,
)
def get_community(
    community_id: int,
    user_id: int = Depends(get_current_user_id),
):
    result = get_community_details(
        community_id=community_id,
        user_id=user_id,
    )

    if result is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community not found.",
        )

    return result
@router.post(
    "/{community_id}/posts/{post_id}/comments",
    response_model=CommentResponse,
)
def create_community_comment(
    community_id: int,
    post_id: int,
    request: CreateCommentRequest,
    user_id: int = Depends(get_current_user_id),
):
    try:
        result = create_comment(
            community_id=community_id,
            post_id=post_id,
            user_id=user_id,
            content=request.content,
        )
    except RuntimeError:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Community moderation is temporarily unavailable. Please try again.",
        )

    if result.get("error") == "community_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community not found.",
        )

    if result.get("error") == "not_member":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Join the community before commenting.",
        )

    if result.get("error") == "post_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Post not found.",
        )

    if result.get("error") == "content_blocked":
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail={
                "message": "Your comment was blocked by community moderation.",
                "category": result.get("category"),
                "reason": result.get("reason"),
            },
        )

    return result


@router.get(
    "/{community_id}/posts/{post_id}/comments",
    response_model=list[CommentResponse],
)
def list_community_comments(
    community_id: int,
    post_id: int,
    user_id: int = Depends(get_current_user_id),
):
    result = get_post_comments(
        community_id=community_id,
        post_id=post_id,
        user_id=user_id,
    )

    if result is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community or post not found.",
        )

    return result


@router.delete(
    "/{community_id}/posts/{post_id}/comments/{comment_id}"
)
def delete_community_comment(
    community_id: int,
    post_id: int,
    comment_id: int,
    user_id: int = Depends(get_current_user_id),
):
    result = delete_comment(
        community_id=community_id,
        post_id=post_id,
        comment_id=comment_id,
        user_id=user_id,
    )

    if result == "community_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community not found.",
        )

    if result == "comment_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Comment not found.",
        )

    if result == "not_member":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not a member of this community.",
        )

    if result == "not_allowed":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not allowed to delete this comment.",
        )

    return {"message": "Comment deleted successfully."}


@router.post(
    "/{community_id}/posts/{post_id}/comments/{comment_id}/like"
)
def like_community_comment(
    community_id: int,
    post_id: int,
    comment_id: int,
    user_id: int = Depends(get_current_user_id),
):
    result = like_comment(
        community_id=community_id,
        post_id=post_id,
        comment_id=comment_id,
        user_id=user_id,
    )

    if result == "community_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community not found.",
        )

    if result == "comment_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Comment not found.",
        )

    if result == "not_member":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Join the community first.",
        )

    if result == "already_liked":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Comment already liked.",
        )

    return {"message": "Comment liked successfully."}


@router.delete(
    "/{community_id}/posts/{post_id}/comments/{comment_id}/like"
)
def unlike_community_comment(
    community_id: int,
    post_id: int,
    comment_id: int,
    user_id: int = Depends(get_current_user_id),
):
    result = unlike_comment(
        community_id=community_id,
        post_id=post_id,
        comment_id=comment_id,
        user_id=user_id,
    )

    if result == "community_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community not found.",
        )

    if result == "comment_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Comment not found.",
        )

    if result == "not_member":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Join the community first.",
        )

    if result == "not_liked":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Comment is not liked.",
        )

    return {"message": "Comment unliked successfully."}


@router.post(
    "/{community_id}/posts/{post_id}/comments/{comment_id}/report"
)
def report_community_comment(
    community_id: int,
    post_id: int,
    comment_id: int,
    request: ReportCommentRequest,
    user_id: int = Depends(get_current_user_id),
):
    result = report_comment(
        community_id=community_id,
        post_id=post_id,
        comment_id=comment_id,
        user_id=user_id,
        reason=request.reason,
        details=request.details,
    )

    if result == "community_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community not found.",
        )

    if result == "comment_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Comment not found.",
        )

    if result == "not_member":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Join the community first.",
        )

    if result == "own_comment":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You cannot report your own comment.",
        )

    if result == "already_reported":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="You have already reported this comment.",
        )

    return {"message": "Comment report submitted successfully."}
@router.get(
    "/{community_id}/members",
    response_model=list[CommunityMemberResponse],
)
def list_community_members(
    community_id: int,
    user_id: int = Depends(get_current_user_id),
):
    result = get_community_members(community_id)

    if result is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community not found.",
        )

    return result
@router.delete("/{community_id}")
def delete_community_endpoint(
    community_id: int,
    user_id: int = Depends(get_current_user_id),
):
    result = delete_community(
        community_id=community_id,
        user_id=user_id,
    )

    if result == "community_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community not found.",
        )

    if result == "system_community":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="PregEase-managed communities cannot be deleted.",
        )

    if result == "not_owner":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only the community owner can delete this community.",
        )

    return {
        "message": "Community deleted successfully."
    }
@router.get(
    "/{community_id}/reports",
    response_model=list[CommunityReportResponse],
)
def list_community_reports(
    community_id: int,
    user_id: int = Depends(get_current_user_id),
):
    result = get_community_reports(
        community_id=community_id,
        user_id=user_id,
    )

    if result == "community_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community not found.",
        )

    if result == "not_manager":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only community owners and moderators can view reports.",
        )

    return result
@router.post(
    "/{community_id}/reports/{report_id}/resolve",
)
def resolve_report(
    community_id: int,
    report_id: int,
    request: ResolveCommunityReportRequest,
    user_id: int = Depends(get_current_user_id),
):
    result = resolve_community_report(
        community_id=community_id,
        report_id=report_id,
        user_id=user_id,
        action=request.action,
    )

    if result == "invalid_action":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="action must be 'dismiss' or 'remove'.",
        )

    if result == "community_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Community not found.",
        )

    if result == "not_manager":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only community owners and moderators can manage reports.",
        )

    if result == "report_not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Report not found.",
        )

    if result == "already_resolved":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Report has already been resolved.",
        )

    return {
        "message": "Report resolved successfully.",
        "action": request.action,
    }