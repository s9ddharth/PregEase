
from datetime import datetime
from typing import Literal

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user_id
from app.database.database import SessionLocal
from app.database.models import PregnancyAppointment


router = APIRouter(
    prefix="/appointments",
    tags=["Appointments"],
)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


class AppointmentCreate(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    appointment_date: datetime
    location: str | None = None
    notes: str | None = None
    reminder_at: datetime | None = None


class AppointmentUpdate(BaseModel):
    title: str | None = Field(default=None, min_length=1, max_length=200)
    appointment_date: datetime | None = None
    location: str | None = None
    notes: str | None = None
    reminder_at: datetime | None = None
    status: Literal["scheduled", "completed", "cancelled"] | None = None


def appointment_to_dict(item):
    return {
        "id": item.id,
        "user_id": item.user_id,
        "title": item.title,
        "appointment_date": item.appointment_date,
        "location": item.location,
        "notes": item.notes,
        "status": item.status,
        "reminder_at": item.reminder_at,
        "created_by": item.created_by,
        "created_at": item.created_at,
        "updated_at": item.updated_at,
    }


@router.get("")
def list_appointments(
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    items = (
        db.query(PregnancyAppointment)
        .filter(PregnancyAppointment.user_id == user_id)
        .order_by(PregnancyAppointment.appointment_date.asc())
        .all()
    )
    return [appointment_to_dict(item) for item in items]


@router.post("", status_code=201)
def create_appointment(
    request: AppointmentCreate,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    now = datetime.now()

    item = PregnancyAppointment(
        user_id=user_id,
        created_by=user_id,
        title=request.title,
        appointment_date=request.appointment_date,
        location=request.location,
        notes=request.notes,
        reminder_at=request.reminder_at,
        status="scheduled",
        created_at=now,
        updated_at=now,
    )

    db.add(item)
    db.commit()
    db.refresh(item)

    return appointment_to_dict(item)


@router.put("/{appointment_id}")
def update_appointment(
    appointment_id: int,
    request: AppointmentUpdate,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    item = (
        db.query(PregnancyAppointment)
        .filter(
            PregnancyAppointment.id == appointment_id,
            PregnancyAppointment.user_id == user_id,
        )
        .first()
    )

    if item is None:
        raise HTTPException(
            status_code=404,
            detail="Appointment not found.",
        )

    changes = request.dict(exclude_unset=True)

    for field, value in changes.items():
        if value is not None or field in ("location", "notes", "reminder_at"):
            setattr(item, field, value)

    item.updated_at = datetime.now()

    db.commit()
    db.refresh(item)

    return appointment_to_dict(item)


@router.patch("/{appointment_id}/cancel")
def cancel_appointment(
    appointment_id: int,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    item = (
        db.query(PregnancyAppointment)
        .filter(
            PregnancyAppointment.id == appointment_id,
            PregnancyAppointment.user_id == user_id,
        )
        .first()
    )

    if item is None:
        raise HTTPException(
            status_code=404,
            detail="Appointment not found.",
        )

    item.status = "cancelled"
    item.updated_at = datetime.now()

    db.commit()
    db.refresh(item)

    return appointment_to_dict(item)
