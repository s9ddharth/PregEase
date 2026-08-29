from sqlalchemy import select

from app.database.database import SessionLocal
from app.database.models import ChatSession, ChatMessage


class MemoryManager:

    def add_message(
        self,
        session_id: str,
        role: str,
        content: str,
    ):
        with SessionLocal() as db:

            # Create the chat session if it doesn't exist
            session = db.get(ChatSession, session_id)

            if session is None:
                session = ChatSession(
                    id=session_id,
                    title="NurtureAI Chat",
                )

                db.add(session)
                db.flush()

            # Save the message
            message = ChatMessage(
                session_id=session_id,
                role=role,
                content=content,
            )

            db.add(message)
            db.commit()


    def get_messages(self, session_id: str):

        with SessionLocal() as db:

            statement = (
                select(ChatMessage)
                .where(
                    ChatMessage.session_id == session_id
                )
                .order_by(ChatMessage.created_at.asc())
            )

            messages = db.scalars(statement).all()

            return [
                {
                    "role": message.role,
                    "content": message.content,
                }
                for message in messages
            ]


    def clear(self, session_id: str):

        with SessionLocal() as db:

            statement = (
                select(ChatSession)
                .where(
                    ChatSession.id == session_id
                )
            )

            session = db.scalars(statement).first()

            if session:
                db.delete(session)
                db.commit()


memory_manager = MemoryManager()