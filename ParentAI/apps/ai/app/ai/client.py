from ollama import Client

from app.ai.prompts import PromptManager
from app.config.settings import settings
from app.memory.database_memory_manager import (
    database_memory_manager,
)


client = Client(
    host="http://127.0.0.1:11434"
)


class AIClient:

    # ========================================================
    # GET CHAT HISTORY
    # ========================================================

    def get_history(
        self,
        session_id: str,
        user_id: int,
    ):
        return database_memory_manager.get_messages(
            session_id,
            user_id,
        )

    # ========================================================
    # GET USER'S CHAT SESSIONS
    # ========================================================

    def get_sessions(
        self,
        user_id: int,
    ):
        return database_memory_manager.get_sessions(
            user_id,
        )

    # ========================================================
    # DELETE CHAT SESSION
    # ========================================================

    def delete_session(
        self,
        session_id: str,
        user_id: int,
    ):
        return database_memory_manager.delete_session(
            session_id,
            user_id,
        )

    # ========================================================
    # GENERATE AI RESPONSE
    # ========================================================

    def generate(
        self,
        session_id: str,
        message: str,
        user_id: int,
    ) -> str:

        print(f"➡️ Session: {session_id}")
        print(f"➡️ User: {user_id}")

        # ----------------------------------------------------
        # Save user's message
        # ----------------------------------------------------

        database_memory_manager.add_message(
            session_id,
            user_id,
            "user",
            message,
        )

        # ----------------------------------------------------
        # Build conversation
        # ----------------------------------------------------

        messages = [
            {
                "role": "system",
                "content": PromptManager.get_general_prompt(),
            }
        ]

        # ----------------------------------------------------
        # Add conversation history
        # ----------------------------------------------------

        messages.extend(
            database_memory_manager.get_messages(
                session_id,
                user_id,
            )
        )

        print(messages)

        # ----------------------------------------------------
        # Send conversation to Ollama
        # ----------------------------------------------------

        response = client.chat(
            model=settings.ai_model,
            messages=messages,
        )

        reply = response["message"]["content"]

        # ----------------------------------------------------
        # Save AI response
        # ----------------------------------------------------

        database_memory_manager.add_message(
            session_id,
            user_id,
            "assistant",
            reply,
        )

        print("✅ Ollama responded")

        return reply


ai_client = AIClient()