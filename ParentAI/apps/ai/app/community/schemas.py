from datetime import datetime

from pydantic import BaseModel, Field


class CommunityResponse(BaseModel):
    id: int
    name: str
    description: str | None
    member_count: int
    joined: bool


class CreatePostRequest(BaseModel):
    content: str = Field(
        min_length=1,
        max_length=2000,
    )


class PostResponse(BaseModel):
    id: int
    community_id: int
    user_id: int
    content: str
    created_at: datetime
    updated_at: datetime


class PostFeedResponse(BaseModel):
    id: int
    community_id: int
    user_id: int
    content: str
    created_at: datetime
    updated_at: datetime
    is_owner: bool