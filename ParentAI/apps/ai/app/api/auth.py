from datetime import datetime, timedelta, timezone

import jwt
from fastapi import APIRouter, Depends, HTTPException, status
from pwdlib import PasswordHash
from app.api.dependencies import get_current_user_id
from app.database.database import SessionLocal
from app.database.models import User
from app.schemas.auth import (
    RegisterRequest,
    RegisterResponse,
)


router = APIRouter(
    prefix="/auth",
    tags=["Authentication"],
)


password_hash = PasswordHash.recommended()

ALGORITHM = "HS256"

ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24


def get_secret_key() -> str:
    from app.config.settings import settings

    return settings.jwt_secret_key


def create_access_token(user_id: int) -> str:
    expire = (
        datetime.now(timezone.utc)
        + timedelta(
            minutes=ACCESS_TOKEN_EXPIRE_MINUTES
        )
    )

    payload = {
        "sub": str(user_id),
        "exp": expire,
    }

    return jwt.encode(
        payload,
        get_secret_key(),
        algorithm=ALGORITHM,
    )


@router.post(
    "/register",
    response_model=RegisterResponse,
)
def register(request: RegisterRequest):

    db = SessionLocal()

    try:
        existing_user = (
            db.query(User)
            .filter(User.email == request.email)
            .first()
        )

        if existing_user:
            raise HTTPException(
                status_code=409,
                detail="An account with this email already exists.",
            )

        hashed_password = password_hash.hash(
            request.password
        )

        user = User(
            name=request.name,
            email=request.email,
            password_hash=hashed_password,
        )

        db.add(user)
        db.commit()
        db.refresh(user)

        return RegisterResponse(
            id=user.id,
            name=user.name,
            email=user.email,
            message="Account created successfully.",
        )

    except HTTPException:
        raise

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()


@router.post("/login")
def login(
    email: str,
    password: str,
):
    db = SessionLocal()

    try:
        user = (
            db.query(User)
            .filter(User.email == email)
            .first()
        )

        if user is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password.",
            )

        if not user.password_hash:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password.",
            )

        valid_password = password_hash.verify(
            password,
            user.password_hash,
        )

        if not valid_password:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password.",
            )

        access_token = create_access_token(
            user.id
        )

        return {
            "access_token": access_token,
            "token_type": "bearer",
            "user": {
                "id": user.id,
                "name": user.name,
                "email": user.email,
            },
        }

    finally:
        db.close()
@router.get("/me")
def get_me(
    user_id: int = Depends(get_current_user_id),
):
    return {
        "authenticated": True,
        "user_id": user_id,
    }