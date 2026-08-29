from fastapi import APIRouter, Depends, HTTPException

from app.schemas.chat import ChatRequest, ChatResponse
from app.services.chat_service import chat_service
from app.api.dependencies import get_current_user_id


router = APIRouter(
    prefix="/chat",
    tags=["Chat"],
)


@router.post("/", response_model=ChatResponse)
def chat(
    request: ChatRequest,
    user_id: int = Depends(get_current_user_id),
):
    reply = chat_service.generate_reply(
        request.session_id,
        request.message,
        user_id,
    )

    return ChatResponse(
        reply=reply
    )


@router.get("/history/{session_id}")
def get_chat_history(
    session_id: str,
    user_id: int = Depends(get_current_user_id),
):
    return chat_service.get_history(
        session_id,
        user_id,
    )


@router.get("/sessions")
def get_chat_sessions(
    user_id: int = Depends(get_current_user_id),
):
    return chat_service.get_sessions(
        user_id,
    )


@router.delete("/sessions/{session_id}")
def delete_chat_session(
    session_id: str,
    user_id: int = Depends(get_current_user_id),
):
    deleted = chat_service.delete_session(
        session_id,
        user_id,
    )

    if not deleted:
        raise HTTPException(
            status_code=404,
            detail="Chat session not found.",
        )

    return {
        "message": "Chat session deleted successfully."
    }