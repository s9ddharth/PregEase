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

        # Rotate the creative direction so repeated taps do not keep
        # asking Ollama for the same style of meals.
        import time

        variation_styles = [
            "regional/home-style meals",
            "quick 15-30 minute meals",
            "one-bowl or one-pot meals",
            "breakfast/brunch-style ideas",
            "light meals and nourishing snacks",
            "comfort-food style meals with a healthier balance",
            "creative combinations that are still familiar and practical",
            "simple family meals that can be shared",
        ]
        variation_style = variation_styles[
            int(time.time() // 60) % len(variation_styles)
        ]

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

Creative direction for this request:
{variation_style}

INDIA-FIRST DEFAULT:
- When cuisine is "Indian" or "any", make the suggestions naturally
  understandable to people in India.
- Prefer familiar Indian home foods and ingredients commonly available
  in Indian homes and markets.
- Prefer familiar Indian names such as poha, upma, idli, dosa, dal,
  sabzi, roti, paratha, curd, paneer, chana, rajma, moong dal,
  khichdi, rice, millet/bajra/ragi, etc. when they fit the approved
  foods and dietary restrictions.
- Include regional variety where appropriate (for example South Indian,
  North Indian, Gujarati, Maharashtrian, Bengali, Punjabi, or other
  Indian styles) rather than repeating one generic "Indian" pattern.
- Use simple Indian English. Avoid unnecessarily Western terms such as
  "grain bowl", "power bowl", or "wrap" when a familiar Indian name
  would be clearer.
- Prefer ingredients that are realistic to find in ordinary Indian
  grocery shops.
- Do not invent traditional Indian dish names. If adapting a familiar
  dish, describe the adaptation clearly.
- Do not assume every Indian user eats vegetarian food; follow the
  user's saved dietary preference and allergies strictly.
- Keep the food ideas practical for home cooking.

IMPORTANT VARIETY RULES:
- The user may press Generate repeatedly, so avoid generic/repetitive answers.
- Make all 3 to 5 suggestions DIFFERENT from each other.
- Do not return several variations of the same dish.
- Avoid defaulting to common combinations such as plain dal + rice,
  roti + dal, or vegetable khichdi unless the requested cuisine/meal
  specifically calls for them.
- Vary the main ingredient, preparation method, texture, and meal style.
- Prefer less obvious combinations from the approved foods list.
- Do not simply rename the same meal.
- If there are enough approved foods, use different primary ingredients
  across the suggestions.
- Keep names specific and appetizing rather than generic names like
  "Healthy meal" or "Nutritious dish".
- The creative direction is a preference, not permission to use foods
  outside the approved foods list.

STRICT SAFETY RULES:
- Use ONLY foods from the approved foods list.
- Never suggest an excluded food or an ingredient that conflicts
  with a listed allergy.
- Do not diagnose conditions or prescribe supplements.
- Keep suggestions practical and pregnancy-appropriate.

Return ONLY valid JSON in this exact format:
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
                        "nutrition ideas. By default, make Indian cuisine "
                        "suggestions familiar to Indian users, using simple "
                        "Indian English and practical home foods. Treat "
                        "allergy exclusions as strict constraints and "
                        "preserve the user's dietary preference. Return "
                        "valid JSON only."
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