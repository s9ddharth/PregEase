import re
import unicodedata

from pydantic import BaseModel
from ollama import ResponseError

from app.config.settings import settings
from app.ai.client import client
from app.database.database import SessionLocal
from app.database.models import CommunityModerationRule


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
    Normalize text before deterministic moderation checks.

    This helps detect simple variations involving:
    - capitalization
    - Unicode representation
    - repeated whitespace
    - punctuation
    - repeated characters
    """

    text = unicodedata.normalize("NFKC", text)

    text = text.lower()

    # Replace punctuation/symbols with spaces.
    text = re.sub(r"[^\w\s]", " ", text, flags=re.UNICODE)

    # Collapse repeated whitespace.
    text = re.sub(r"\s+", " ", text)

    return text.strip()


def _normalize_rule_pattern(pattern: str) -> str:
    return normalize_text(pattern)


def check_database_rules(content: str) -> ModerationResult | None:
    """
    Check high-confidence moderation rules stored in MySQL.

    Returns:
        ModerationResult when a rule matches.
        None when no deterministic rule matches.
    """

    normalized_content = normalize_text(content)

    if not normalized_content:
        return None

    db = SessionLocal()

    try:
        rules = (
            db.query(CommunityModerationRule)
            .filter(CommunityModerationRule.active.is_(True))
            .all()
        )

        for rule in rules:
            pattern = _normalize_rule_pattern(rule.pattern)

            if not pattern:
                continue

            matched = False

            if rule.rule_type == "exact":
                matched = normalized_content == pattern

            elif rule.rule_type == "phrase":
                matched = pattern in normalized_content

            elif rule.rule_type == "keyword_combination":
                keywords = pattern.split()

                matched = all(
                    keyword in normalized_content
                    for keyword in keywords
                )

            elif rule.rule_type == "regex":
                try:
                    matched = re.search(
                        pattern,
                        normalized_content,
                        flags=re.IGNORECASE | re.UNICODE,
                    ) is not None
                except re.error:
                    print(
                        f"Invalid moderation regex rule: {rule.pattern}"
                    )
                    continue

            if matched:
                return ModerationResult(
                    allowed=False,
                    language=rule.language,
                    category=rule.category,
                    confidence=1.0,
                    reason="Matched a community safety rule.",
                )

        return None

    finally:
        db.close()


def moderate_content(content: str) -> ModerationResult:
    """
    Two-layer moderation:

    1. Deterministic MySQL rules
    2. Multilingual AI moderation
    """

    # ---------------------------------------------------------
    # Layer 1: deterministic database rules
    # ---------------------------------------------------------

    database_result = check_database_rules(content)

    if database_result is not None:
        return database_result

    # ---------------------------------------------------------
    # Layer 2: multilingual AI moderation
    # ---------------------------------------------------------

    prompt = f"{MODERATION_PROMPT}\n\n{content}"

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
            min(1.0, result.confidence),
        )

        return result

    except (
        ResponseError,
        ValueError,
        TypeError,
    ) as exc:
        print(f"Community moderation failed: {exc}")

        raise RuntimeError(
            "Community moderation service unavailable."
        ) from exc