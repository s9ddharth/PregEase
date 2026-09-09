import re
import unicodedata

from pydantic import BaseModel
from ollama import ResponseError

from app.config.settings import settings
from app.ai.client import client


class ModerationResult(BaseModel):
    allowed: bool
    language: str | None
    category: str | None
    confidence: float
    reason: str | None


MODERATION_PROMPT = """
You are the multilingual content safety moderator for PregEase,
a pregnancy and parenting support community.

The submitted message may be written in ANY human language.

Understand the meaning of the message in its original language.

Do NOT block content simply because:
- it is not English
- it contains slang
- it contains transliteration
- it contains a medical question
- it contains emotional language

ALLOW normal:
- pregnancy questions
- parenting questions
- baby care questions
- personal experiences
- emotional support
- respectful disagreement
- medical questions
- general health information
- normal conversations between parents

BLOCK:
- harassment or bullying
- hate or discrimination
- threats or encouragement of violence
- sexual or sexually explicit content
- sexual content involving minors
- scams or spam
- encouragement of self-harm
- encouragement of dangerous behavior
- dangerous medical misinformation presented as instructions
- malicious exposure of private information
- doxxing
- abusive or deliberately degrading content

A medical question is NOT automatically unsafe.

Return ONLY the requested structured result.

LANGUAGE:
Return the primary language using a short language code when possible.

Examples:
en = English
hi = Hindi
ta = Tamil
ml = Malayalam
es = Spanish
fr = French
de = German
ar = Arabic
pt = Portuguese
bn = Bengali
te = Telugu
kn = Kannada

For mixed-language content, return the primary language.

If language cannot be determined, return null.

If allowed:
- allowed = true
- category = null
- reason = null

If blocked:
- allowed = false
- category must be one of:

harassment
hate
violence
sexual
minor_safety
spam
self_harm
dangerous_medical
privacy
abuse
other

- reason must briefly explain why the content was blocked.

Return confidence between 0.0 and 1.0.

Message to review:
"""


def normalize_text(text: str) -> str:
    """
    Normalize text before moderation.

    Handles:
    - Unicode normalization
    - capitalization
    - punctuation
    - repeated whitespace
    """

    text = unicodedata.normalize(
        "NFKC",
        text,
    )

    text = text.lower()

    text = re.sub(
        r"[^\w\s]",
        " ",
        text,
        flags=re.UNICODE,
    )

    text = re.sub(
        r"\s+",
        " ",
        text,
    )

    return text.strip()


def check_database_rules(
    content: str,
) -> ModerationResult | None:
    """
    Database moderation rules are intentionally disabled
    for the current MVP.

    CommunityModerationRule is currently used by the
    Community Rules feature and contains community-rule
    fields such as:

        title
        description
        sort_order

    It is therefore not safe to treat that model as a
    content-blocking rule model.

    AI moderation is used as the moderation layer for now.

    Returns:
        None so moderation proceeds to the AI moderator.
    """

    normalized_content = normalize_text(content)

    if not normalized_content:
        return None

    return None


def moderate_content(
    content: str,
) -> ModerationResult:
    """
    Moderate community content.

    Current MVP flow:

    1. Normalize/check the content.
    2. AI multilingual moderation.
    3. Return a structured ModerationResult.
    """

    # ---------------------------------------------------------
    # Layer 1:
    # Database rules are currently disabled because the
    # CommunityModerationRule model is being used for
    # community guidelines rather than blocked-content rules.
    # ---------------------------------------------------------

    database_result = check_database_rules(
        content
    )

    if database_result is not None:
        return database_result

    # ---------------------------------------------------------
    # Layer 2:
    # Multilingual AI moderation
    # ---------------------------------------------------------

    normalized_content = normalize_text(
        content
    )

    if not normalized_content:
        return ModerationResult(
            allowed=False,
            language=None,
            category="other",
            confidence=1.0,
            reason="Content cannot be empty.",
        )

    prompt = (
        f"{MODERATION_PROMPT}\n\n"
        f"{content}"
    )

    try:
        response = client.chat(
            model=settings.ai_model,
            messages=[
                {
                    "role": "user",
                    "content": prompt,
                }
            ],
            format=ModerationResult.model_json_schema(),
            options={
                "temperature": 0,
            },
        )

        result = ModerationResult.model_validate_json(
            response["message"]["content"]
        )

        result.confidence = max(
            0.0,
            min(
                1.0,
                result.confidence,
            ),
        )

        return result

    except (
        ResponseError,
        ValueError,
        TypeError,
    ) as exc:

        print(
            f"Community moderation failed: {exc}"
        )

        raise RuntimeError(
            "Community moderation service unavailable."
        ) from exc