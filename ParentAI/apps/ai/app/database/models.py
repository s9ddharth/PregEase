from datetime import datetime
from zoneinfo import ZoneInfo

from sqlalchemy import DateTime, ForeignKey, String, Text, Integer, Enum
from sqlalchemy.orm import (
    DeclarativeBase,
    Mapped,
    mapped_column,
    relationship,
)
from sqlalchemy import (
    Column,
    Integer,
    String,
    Text,
    DateTime,
    ForeignKey,
    UniqueConstraint,
    func,
)
IST = ZoneInfo("Asia/Kolkata")


def ist_now() -> datetime:
    return datetime.now(IST).replace(tzinfo=None)

class Base(DeclarativeBase):
    pass


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        autoincrement=True,
    )

    name: Mapped[str | None] = mapped_column(
        String(100),
        nullable=True,
    )

    email: Mapped[str | None] = mapped_column(
        String(255),
        unique=True,
        nullable=True,
    )

    # We need this for authentication.
    password_hash: Mapped[str | None] = mapped_column(
        String(255),
        nullable=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=ist_now,
    )

    sessions: Mapped[list["ChatSession"]] = relationship(
        back_populates="user",
        cascade="all, delete-orphan",
    )
    pregnancy_profile: Mapped["PregnancyProfile | None"] = relationship(
    back_populates="user",
    uselist=False,
    cascade="all, delete-orphan",
    )
class PregnancyProfile(Base):

    __tablename__ = "pregnancy_profiles"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        autoincrement=True,
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
        nullable=False,
        unique=True,
    )

    lmp_date: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
    )

    dietary_preference: Mapped[str | None] = mapped_column(
        String(50),
        nullable=True,
    )

    custom_dietary_preference: Mapped[str | None] = mapped_column(
        String(255),
        nullable=True,
    )

    food_allergies: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=ist_now,
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=ist_now,
        onupdate=ist_now    ,
    )

    user: Mapped["User"] = relationship(
        back_populates="pregnancy_profile",
    )
class PregnancyWeekContent(Base):
    __tablename__ = "pregnancy_week_content"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        autoincrement=True,
    )

    week: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        unique=True,
    )

    baby_growth: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    body_changes: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    activities: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    nutrition_guidance: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    precautions: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    mental_wellness: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
    )

    content_version: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        default=1,
    )

    status: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
        default="draft",
    )

    reviewed_at: Mapped[datetime | None] = mapped_column(
        DateTime,
        nullable=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=ist_now,
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=ist_now,
        onupdate=ist_now ,
    )

    sources: Mapped[list["PregnancyContentSource"]] = relationship(
        back_populates="content",
        cascade="all, delete-orphan",
    )


class PregnancyContentSource(Base):
    __tablename__ = "pregnancy_content_sources"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        autoincrement=True,
    )

    content_id: Mapped[int] = mapped_column(
        ForeignKey("pregnancy_week_content.id"),
        nullable=False,
    )

    section: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
    )
    organization: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
    )

    title: Mapped[str] = mapped_column(
        String(500),
        nullable=False,
    )

    url: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    source_type: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
        default="guideline",
    )

    reviewed_at: Mapped[datetime | None] = mapped_column(
        DateTime,
        nullable=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=ist_now,
    )

    content: Mapped["PregnancyWeekContent"] = relationship(
        back_populates="sources",
    )
class ChatSession(Base):
    __tablename__ = "chat_sessions"

    id: Mapped[str] = mapped_column(
        String(100),
        primary_key=True,
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
        nullable=False,
    )

    title: Mapped[str | None] = mapped_column(
        String(255),
        nullable=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=ist_now,
    )

    user: Mapped[User] = relationship(
        back_populates="sessions",
    )

    messages: Mapped[list["ChatMessage"]] = relationship(
        back_populates="session",
        cascade="all, delete-orphan",
    )


class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        autoincrement=True,
    )

    session_id: Mapped[str] = mapped_column(
        ForeignKey("chat_sessions.id"),
        nullable=False,
    )

    role: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
    )

    content: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=ist_now,
    )

    session: Mapped[ChatSession] = relationship(
        back_populates="messages",
    )
class Community(Base):
    __tablename__ = "communities"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        autoincrement=True,
    )

    name: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
        unique=True,
    )

    description: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
    )

    category: Mapped[str | None] = mapped_column(
        String(100),
        nullable=True,
    )

    icon_url: Mapped[str | None] = mapped_column(
        String(500),
        nullable=True,
    )

    visibility: Mapped[str] = mapped_column(
        Enum("public", "private", name="community_visibility"),
        nullable=False,
        default="public",
    )

    membership_mode: Mapped[str] = mapped_column(
        Enum("open", "approval", name="community_membership_mode"),
        nullable=False,
        default="open",
    )

    created_by: Mapped[int | None] = mapped_column(
        ForeignKey("users.id"),
        nullable=True,
    )

    slug: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
        unique=True,
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=ist_now,
        onupdate=ist_now,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=ist_now,
    )

    members: Mapped[list["CommunityMember"]] = relationship(
        back_populates="community",
        cascade="all, delete-orphan",
    )

    posts: Mapped[list["CommunityPost"]] = relationship(
        back_populates="community",
        cascade="all, delete-orphan",
    )


class CommunityMember(Base):
    __tablename__ = "community_members"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        autoincrement=True,
    )

    community_id: Mapped[int] = mapped_column(
        ForeignKey("communities.id"),
        nullable=False,
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
        nullable=False,
    )

    role: Mapped[str] = mapped_column(
        Enum("owner", "moderator", "member", name="community_member_role"),
        nullable=False,
        default="member",
    )

    status: Mapped[str] = mapped_column(
        Enum("active", "pending", "banned", name="community_member_status"),
        nullable=False,
        default="active",
    )

    joined_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=ist_now,
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=ist_now,
        onupdate=ist_now,
    )

    community: Mapped["Community"] = relationship(
        back_populates="members",
    )

    user: Mapped["User"] = relationship()


class CommunityPost(Base):
    __tablename__ = "community_posts"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        autoincrement=True,
    )

    community_id: Mapped[int] = mapped_column(
        ForeignKey("communities.id"),
        nullable=False,
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
        nullable=False,
    )

    content: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=ist_now,
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=ist_now,
        onupdate=ist_now,
    )

    community: Mapped["Community"] = relationship(
        back_populates="posts",
    )

    user: Mapped["User"] = relationship()

    comments: Mapped[list["CommunityComment"]] = relationship(
        back_populates="post",
        cascade="all, delete-orphan",
    )


class CommunityComment(Base):
    __tablename__ = "community_comments"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        autoincrement=True,
    )

    post_id: Mapped[int] = mapped_column(
        ForeignKey("community_posts.id"),
        nullable=False,
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
        nullable=False,
    )

    content: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=ist_now,
    )

    post: Mapped["CommunityPost"] = relationship(
        back_populates="comments",
    )

    user: Mapped["User"] = relationship()

class CommunityCommentLike(Base):
    __tablename__ = "community_comment_likes"

    id = Column(Integer, primary_key=True, autoincrement=True)

    comment_id = Column(
        Integer,
        ForeignKey("community_comments.id", ondelete="CASCADE"),
        nullable=False,
    )

    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )

    created_at = Column(
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
    )

    __table_args__ = (
        UniqueConstraint(
            "comment_id",
            "user_id",
            name="uq_comment_like",
        ),
    )

class ModerationEvent(Base):
    __tablename__ = "moderation_events"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        autoincrement=True,
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
        nullable=False,
    )

    content: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    result: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
    )

    category: Mapped[str | None] = mapped_column(
        String(100),
        nullable=True,
    )

    confidence: Mapped[float | None] = mapped_column(
        nullable=True,
    )

    reason: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=ist_now,
    )

    user: Mapped["User"] = relationship()

class CommunityModerationRule(Base):
    __tablename__ = "community_rules"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        autoincrement=True,
    )

    community_id: Mapped[int] = mapped_column(
        ForeignKey("communities.id"),
        nullable=False,
    )

    title: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
    )

    description: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    sort_order: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        default=0,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=ist_now,
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=ist_now,
        onupdate=ist_now,
    )

    community: Mapped["Community"] = relationship()


class CommunityPostReport(Base):
    __tablename__ = "community_post_reports"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )

    post_id: Mapped[int] = mapped_column(
        ForeignKey(
            "community_posts.id",
            ondelete="CASCADE",
        ),
        nullable=False,
    )

    reporter_user_id: Mapped[int] = mapped_column(
        ForeignKey(
            "users.id",
            ondelete="CASCADE",
        ),
        nullable=False,
    )

    reason: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
    )

    details: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=ist_now,
    )
    status = Column(String(20), nullable=False, default="open")

    


class CommunityCommentReport(Base):
    __tablename__ = "community_comment_reports"

    id = Column(Integer, primary_key=True, autoincrement=True)
    comment_id = Column(
        Integer,
        ForeignKey("community_comments.id", ondelete="CASCADE"),
        nullable=False,
    )
    reporter_user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    reason = Column(String(50), nullable=False)
    details = Column(Text, nullable=True)
    created_at = Column(
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
    )
    status = Column(String(20), nullable=False, default="open")

    __table_args__ = (
        UniqueConstraint(
            "comment_id",
            "reporter_user_id",
            name="uq_comment_report_user",
        ),
    )
