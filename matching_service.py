"""Explainable fuzzy patient identity matching for synthetic referral records."""

import math
import re
from typing import Any, Dict, List, Optional

from rapidfuzz import fuzz


# Prototype weights only. They are intentionally easy to change for experiments.
WEIGHTS = {
    "name": 0.35,
    "age": 0.15,
    "phone": 0.20,
    "location": 0.10,
    "gender": 0.05,
    "referral_context": 0.15,
}
SUPPORTED_FIELDS = frozenset(WEIGHTS)

HIGH_THRESHOLD = 85.0
MEDIUM_THRESHOLD = 70.0


def _text(value: Any) -> str:
    """Return a safe, normalized text value for comparisons."""
    if value is None:
        return ""
    return re.sub(r"\s+", " ", str(value).strip().lower()).strip()


def normalize_name(value: Any) -> str:
    """Normalize case, punctuation, and repeated spaces in a name."""
    return re.sub(r"[^a-z0-9 ]", "", _text(value)).strip()


def normalize_phone(value: Any) -> str:
    """Keep all phone digits after removing an international 00 prefix."""
    digits = re.sub(r"\D", "", str(value or ""))
    return digits[2:] if digits.startswith("00") else digits


def normalize_gender(value: Any) -> str:
    """Map common gender spellings and abbreviations to one value."""
    gender = _text(value)
    aliases = {"m": "male", "man": "male", "f": "female", "woman": "female"}
    return aliases.get(gender, gender)


def normalize_location(value: Any) -> str:
    """Normalize basic punctuation and whitespace in a location."""
    return re.sub(r"[^a-z0-9 ]", "", _text(value)).strip()


def normalize_context(value: Any) -> str:
    """Turn simple context values, including dictionaries, into comparable text."""
    if isinstance(value, dict):
        return _text(" ".join(f"{key} {item}" for key, item in sorted(value.items())))
    return _text(value)


def _field_score(field: str, incoming: Dict[str, Any], existing: Dict[str, Any]) -> Optional[float]:
    """Return a 0-100 score, or None when this field cannot be compared."""
    incoming_value = incoming.get(field)
    existing_value = existing.get(field)

    if incoming_value in (None, "") or existing_value in (None, ""):
        return None

    if field == "name":
        first = normalize_name(incoming_value)
        second = normalize_name(existing_value)
        return float(fuzz.WRatio(first, second)) if first and second else None

    if field == "phone":
        first = normalize_phone(incoming_value)
        second = normalize_phone(existing_value)
        if not first or not second:
            return None
        return 100.0 if first == second else 0.0

    if field == "age":
        try:
            difference = abs(float(incoming_value) - float(existing_value))
        except (TypeError, ValueError):
            return None
        return max(0.0, 100.0 - (difference * 10.0))

    if field == "gender":
        first = normalize_gender(incoming_value)
        second = normalize_gender(existing_value)
        return 100.0 if first and first == second else 0.0

    if field == "location":
        first = normalize_location(incoming_value)
        second = normalize_location(existing_value)
        return float(fuzz.WRatio(first, second)) if first and second else None

    if field == "referral_context":
        first = normalize_context(incoming_value)
        second = normalize_context(existing_value)
        return float(fuzz.WRatio(first, second)) if first and second else None

    return None


def _confidence_level(score: float, high_threshold: float, medium_threshold: float) -> str:
    if score >= high_threshold:
        return "HIGH"
    if score >= medium_threshold:
        return "MEDIUM"
    return "LOW"


def _matching_reasons(field_scores: Dict[str, Optional[float]]) -> List[str]:
    reasons = []
    labels = {
        "name": "name",
        "age": "age",
        "phone": "phone number",
        "location": "location",
        "gender": "gender",
        "referral_context": "referral context",
    }
    for field, score in field_scores.items():
        if score is None:
            reasons.append(f"{labels[field]} not available for comparison")
        elif score >= 85:
            reasons.append(f"strong {labels[field]} match ({score:.1f})")
        elif score >= 70:
            reasons.append(f"partial {labels[field]} match ({score:.1f})")
        else:
            reasons.append(f"different {labels[field]} ({score:.1f})")
    return reasons


def score_patient_match(
    incoming_patient: Dict[str, Any],
    existing_patient: Dict[str, Any],
    *,
    weights: Optional[Dict[str, float]] = None,
    high_threshold: float = HIGH_THRESHOLD,
    medium_threshold: float = MEDIUM_THRESHOLD,
) -> Dict[str, Any]:
    """Score one incoming record against one existing record."""
    if weights is None:
        active_weights = WEIGHTS
    else:
        unknown_fields = set(weights) - SUPPORTED_FIELDS
        if unknown_fields:
            raise ValueError(f"Unsupported weight fields: {sorted(unknown_fields)}")
        for field, weight in weights.items():
            try:
                valid_weight = math.isfinite(weight)
            except TypeError as error:
                raise ValueError(f"Weight for {field!r} must be finite") from error
            if not valid_weight or weight < 0:
                raise ValueError(f"Weight for {field!r} must be finite and non-negative")
        active_weights = weights

    field_scores = {
        field: _field_score(field, incoming_patient, existing_patient)
        for field in active_weights
    }
    available_fields = [field for field, score in field_scores.items() if score is not None]
    available_weight = sum(active_weights[field] for field in available_fields)

    if available_weight == 0:
        total_score = 0.0
    else:
        # Re-normalize available weights so missing fields do not automatically lower the score.
        total_score = sum(
            field_scores[field] * active_weights[field]
            for field in available_fields
        ) / available_weight

    confidence = _confidence_level(total_score, high_threshold, medium_threshold)
    return {
        "patient_id": existing_patient.get("patient_id", "unknown"),
        "patient_name": existing_patient.get("name", "Unknown"),
        "total_score": round(total_score, 2),
        "confidence": confidence,
        "individual_field_scores": {
            field: None if score is None else round(score, 2)
            for field, score in field_scores.items()
        },
        "matching_reasons": _matching_reasons(field_scores),
        "requires_human_verification": True,
        "verification_message": {
            "HIGH": "Likely match - human confirmation required.",
            "MEDIUM": "Possible match - manual verification required.",
            "LOW": "No reliable match - keep records separate unless verified.",
        }[confidence],
    }


def find_patient_matches(
    incoming_patient: Dict[str, Any],
    existing_patients: List[Dict[str, Any]],
    *,
    minimum_score: float = 0.0,
    result_limit: int = 5,
    weights: Optional[Dict[str, float]] = None,
) -> List[Dict[str, Any]]:
    """Return the highest-scoring possible matches above the requested minimum."""
    if not isinstance(incoming_patient, dict) or not isinstance(existing_patients, list):
        return []
    if result_limit <= 0:
        return []

    results = [
        score_patient_match(incoming_patient, patient, weights=weights)
        for patient in existing_patients
        if isinstance(patient, dict)
    ]
    results = [result for result in results if result["total_score"] >= minimum_score]
    results.sort(key=lambda result: result["total_score"], reverse=True)
    return results[:result_limit]


if __name__ == "__main__":
    print("Import find_patient_matches() to use the matching module.")
