from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    status,
)

from app.api.dependencies import get_current_user_id

from app.community.schemas import (
    CommunityResponse,
    CreatePostRequest,
    PostResponse,
    PostFeedResponse
)

from app.community.service import (
    get_communities,
    join_community,
    leave_community,
    create_post,
    get_community_posts,
    delete_post,
)


router = APIRouter(
    prefix="/community",
    tags=["Community"],
)


@router.get(
    "",
    response_model=list[CommunityResponse],
)
def list_communities(
    user_id: int = Depends(get_current_user_id),
):
    return get_communities(user_id)


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
        "message": "Joined community successfully."
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
        "message": "Left community successfully."
    }


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

@router.delete("/{community_id}/posts/{post_id}")
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

    return {"message": "Post deleted successfully."}