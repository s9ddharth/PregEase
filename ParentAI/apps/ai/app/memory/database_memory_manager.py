from app.database.models import (
    ChatMessage,
    ChatSession,
)

from app.database.session import SessionLocal


class DatabaseMemoryManager:

    # ========================================================
    # ADD MESSAGE
    # ========================================================

    def add_message(
        self,
        session_id: str,
        user_id: int,
        role: str,
        content: str,
    ):
        db = SessionLocal()

        try:
            # Find existing session
            session = db.get(
                ChatSession,
                session_id,
            )

            # Create session if it doesn't exist
            if session is None:

                session = ChatSession(
                    id=session_id,
                    user_id=user_id,
                    title=(
                        content[:60]
                        if role == "user"
                        else "New conversation"
                    ),
                )

                db.add(session)
                db.flush()

            # Make sure the session belongs to this user
            elif session.user_id != user_id:
                raise PermissionError(
                    "You do not have access to this chat session."
                )

            # Save message
            message = ChatMessage(
                session_id=session_id,
                role=role,
                content=content,
            )

            db.add(message)
            db.commit()

        except Exception:
            db.rollback()
            raise

        finally:
            db.close()

    # ========================================================
    # GET MESSAGES
    # ========================================================

    def get_messages(
        self,
        session_id: str,
        user_id: int,
    ):
        db = SessionLocal()

        try:
            # First verify session ownership
            session = db.get(
                ChatSession,
                session_id,
            )

            if session is None:
                return []

            if session.user_id != user_id:
                raise PermissionError(
                    "You do not have access to this chat session."
                )

            messages = (
                db.query(ChatMessage)
                .filter(
                    ChatMessage.session_id == session_id
                )
                .order_by(
                    ChatMessage.created_at.asc()
                )
                .all()
            )

            # Keep latest 10 messages for AI context
            messages = messages[-10:]

            return [
                {
                    "role": message.role,
                    "content": message.content,
                }
                for message in messages
            ]

        finally:
            db.close()

    # ========================================================
    # GET USER'S CHAT SESSIONS
    # ========================================================

    def get_sessions(
        self,
        user_id: int,
    ):
        db = SessionLocal()

        try:
            sessions = (
                db.query(ChatSession)
                .filter(
                    ChatSession.user_id == user_id
                )
                .order_by(
                    ChatSession.created_at.desc()
                )
                .all()
            )

            return [
                {
                    "id": session.id,
                    "title": session.title,
                    "created_at": (
                        session.created_at.isoformat()
                        if session.created_at
                        else None
                    ),
                }
                for session in sessions
            ]

        finally:
            db.close()

    # ========================================================
    # DELETE CHAT SESSION
    # ========================================================

    def delete_session(
        self,
        session_id: str,
        user_id: int,
    ):
        db = SessionLocal()

        try:
            # Find the session
            session = db.get(
                ChatSession,
                session_id,
            )

            # Session doesn't exist
            if session is None:
                return False

            # Make sure this user owns the session
            if session.user_id != user_id:
                return False

            # Delete session.
            #
            # ChatSession has:
            #
            # cascade="all, delete-orphan"
            #
            # so associated ChatMessage records
            # are deleted as well.

            db.delete(session)
            db.commit()

            return True

        except Exception:
            db.rollback()
            raise

        finally:
            db.close()

    # ========================================================
    # CLEAR CHAT
    # ========================================================

    def clear(
        self,
        session_id: str,
        user_id: int,
    ):
        db = SessionLocal()

        try:
            session = db.get(
                ChatSession,
                session_id,
            )

            if session is None:
                return False

            if session.user_id != user_id:
                return False

            db.query(ChatMessage).filter(
                ChatMessage.session_id == session_id
            ).delete()

            db.delete(session)

            db.commit()

            return True

        except Exception:
            db.rollback()
            raise

        finally:
            db.close()


database_memory_manager = DatabaseMemoryManager()