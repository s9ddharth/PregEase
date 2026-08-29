from datetime import datetime
from zoneinfo import ZoneInfo

from sqlalchemy import DateTime, ForeignKey, String, Text, Integer
from sqlalchemy.orm import (
    DeclarativeBase,
    Mapped,
    mapped_column,
    relationship,
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