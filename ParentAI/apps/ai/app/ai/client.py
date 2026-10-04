from ollama import Client

from app.ai.prompts import PromptManager
from app.config.settings import settings
from app.memory.database_memory_manager import (
    database_memory_manager,
)


# ============================================================
# OLLAMA CLIENT
# ============================================================

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
    
    def generate_nutrition_suggestions(
        self,
        pregnancy_week: int,
        dietary_preference: str | None,
        custom_dietary_preference: str | None,
        food_allergies: list[str],
        safe_foods: list[dict],
        cuisine: str | None = None,
        meal_type: str | None = None,
    ) -> str:
        import json

        prompt = f"""
You are a pregnancy nutrition assistant.
Generate general meal ideas, not medical advice.

Pregnancy week: {pregnancy_week}
Dietary preference: {dietary_preference or "not specified"}
Custom dietary preference: {custom_dietary_preference or "none"}
Food allergies: {json.dumps(food_allergies)}
Cuisine preference: {cuisine or "any"}
Meal type: {meal_type or "any"}
Approved foods: {json.dumps(safe_foods)}

Rules:
- Use ONLY foods from the approved foods list.
- Never suggest an excluded food or an ingredient that conflicts
  with a listed allergy.
- Do not diagnose conditions or prescribe supplements.
- Keep suggestions practical and pregnancy-appropriate.
- Return ONLY valid JSON in this exact format:
{{
  "title": "Personalized meal ideas",
  "suggestions": [
    {{
      "name": "Meal name",
      "description": "Short description",
      "ingredients": ["ingredient 1", "ingredient 2"]
    }}
  ],
  "safety_note": "General food safety reminder"
}}
Return 3 to 5 suggestions.
"""

        response = client.chat(
            model=settings.ai_model,
            messages=[
                {
                    "role": "system",
                    "content": (
                        "Provide cautious, general pregnancy "
                        "nutrition ideas. Treat allergy exclusions "
                        "as strict constraints. Return valid JSON only."
                    ),
                },
                {"role": "user", "content": prompt},
            ],
            format="json",
        )

        return response["message"]["content"]



# ============================================================
# SHARED AI CLIENT INSTANCE
# ============================================================

ai_client = AIClient()