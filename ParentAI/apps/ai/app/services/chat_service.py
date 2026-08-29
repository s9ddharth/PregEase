from app.ai.client import ai_client


class ChatService:

    def generate_reply(
        self,
        session_id: str,
        message: str,
        user_id: int,
    ) -> str:

        print("✅ ChatService started")

        reply = ai_client.generate(
            session_id,
            message,
            user_id,
        )

        print("✅ ChatService finished")

        return reply

    def get_history(
        self,
        session_id: str,
        user_id: int,
    ):
        return ai_client.get_history(
            session_id,
            user_id,
        )

    def get_sessions(
        self,
        user_id: int,
    ):
        return ai_client.get_sessions(
            user_id,
        )

    def delete_session(
        self,
        session_id: str,
        user_id: int,
    ):
        return ai_client.delete_session(
            session_id,
            user_id,
        )


chat_service = ChatService()