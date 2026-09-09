from datetime import datetime

from pydantic import BaseModel, Field, field_validator


class CreateCommunityRuleRequest(BaseModel):
    title: str = Field(min_length=1, max_length=150)
    description: str = Field(min_length=1, max_length=2000)
    sort_order: int = Field(default=0, ge=0)

    @field_validator("title", "description")
    @classmethod
    def strip_text(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("Value cannot be empty.")
        return value


class CreateCommunityRequest(BaseModel):
    name: str = Field(min_length=3, max_length=100)
    description: str | None = Field(default=None, max_length=5000)
    category: str | None = Field(default=None, max_length=100)
    icon_url: str | None = Field(default=None, max_length=500)
    visibility: str = Field(default="public", max_length=20)
    membership_mode: str = Field(default="open", max_length=20)
    rules: list[CreateCommunityRuleRequest] = Field(
        default_factory=list,
        max_length=20,
    )

    @field_validator("name", "category", "description", "icon_url")
    @classmethod
    def strip_optional_text(cls, value: str | None) -> str | None:
        if value is None:
            return None

        value = value.strip()
        return value or None

    @field_validator("visibility", "membership_mode")
    @classmethod
    def normalize_enum_text(cls, value: str) -> str:
        return value.strip().lower()


class CommunityResponse(BaseModel):
    id: int
    name: str
    description: str | None
    category: str | None = None
    icon_url: str | None = None
    visibility: str = "public"
    membership_mode: str = "open"
    slug: str | None = None
    member_count: int
    joined: bool
    role: str | None = None
    status: str | None = None
    created_by: int | None = None


class CommunityDetailsResponse(BaseModel):
    id: int
    name: str
    description: str | None
    category: str | None = None
    icon_url: str | None = None
    visibility: str = "public"
    membership_mode: str = "open"
    slug: str | None = None
    member_count: int
    joined: bool
    role: str | None = None
    status: str | None = None
    created_by: int | None = None
    created_at: datetime
    updated_at: datetime | None = None


class CreatePostRequest(BaseModel):
    content: str = Field(min_length=1, max_length=2000)


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


class ReportPostRequest(BaseModel):
    reason: str = Field(min_length=1, max_length=50)
    details: str | None = Field(default=None, max_length=1000)


class TransferOwnershipRequest(BaseModel):
    new_owner_user_id: int = Field(gt=0)


class CommunityRuleResponse(BaseModel):
    id: int
    community_id: int
    title: str
    description: str
    sort_order: int
    created_at: datetime
    updated_at: datetime


class UpdateCommunityRuleRequest(BaseModel):
    title: str = Field(min_length=1, max_length=150)
    description: str = Field(min_length=1, max_length=2000)
    sort_order: int = Field(default=0, ge=0)


class CommentResponse(BaseModel):
    id: int
    post_id: int
    user_id: int
    content: str
    created_at: datetime
    like_count: int = 0
    liked: bool = False


class CreateCommentRequest(BaseModel):
    content: str = Field(min_length=1, max_length=5000)


class ReportCommentRequest(BaseModel):
    reason: str = Field(min_length=1, max_length=50)
    details: str | None = Field(default=None, max_length=1000)


class CommunityMemberResponse(BaseModel):
    user_id: int
    name: str | None = None
    role: str
    joined_at: datetime


class CommunityReportResponse(BaseModel):
    report_id: int
    type: str
    content_id: int
    reported_by: int
    reason: str
    details: str | None = None
    status: str
    created_at: datetime


class ResolveCommunityReportRequest(BaseModel):
    action: str = Field(min_length=1, max_length=20)