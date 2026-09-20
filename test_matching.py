"""Readable checks for the fuzzy patient matching prototype."""

import json
from pathlib import Path
from typing import Any, Dict, List

from matching_service import find_patient_matches


DATA_FILE = Path(__file__).with_name("sample_patients.json")


def load_patients() -> List[Dict[str, Any]]:
    with DATA_FILE.open(encoding="utf-8") as file:
        return json.load(file)


def show_case(title: str, incoming: Dict[str, Any], patients: List[Dict[str, Any]]) -> None:
    matches = find_patient_matches(incoming, patients, minimum_score=0, result_limit=3)
    best = matches[0] if matches else None
    print(f"\n{title}")
    if best is None:
        print("  No matches returned")
        return
    print(f"  Best match: {best['patient_name']} ({best['patient_id']})")
    print(f"  Score: {best['total_score']:.2f} | Confidence: {best['confidence']}")
    print(f"  Message: {best['verification_message']}")
    print(f"  Reasons: {'; '.join(best['matching_reasons'])}")
    print(f"  Human verification required: {best['requires_human_verification']}")


def run_tests() -> None:
    patients = load_patients()
    rahul_sharma = patients[0]
    ramesh_patil = patients[1]
    priya_shah = patients[2]

    exact = dict(rahul_sharma)
    spelling = {**rahul_sharma, "name": "Rahul Sharmma"}
    similar_name = {**rahul_sharma, "name": "Rahul Sharm", "phone": "9000000000"}
    ramesh_spelling = {**ramesh_patil, "name": "Ramesh Patill"}
    different_age = {**rahul_sharma, "age": 60}
    different_phone = {**rahul_sharma, "phone": "9000000000"}
    missing_phone = {**rahul_sharma, "phone": None}
    missing_location = {**rahul_sharma, "location": None}
    no_match = {
        "patient_id": "incoming-9",
        "name": "Meera Kulkarni",
        "age": 71,
        "gender": "Female",
        "phone": "8111111111",
        "location": "Pune",
    }

    show_case("1. Exact name match", exact, patients)
    show_case("2. Spelling mistake in name", spelling, patients)
    show_case("3. Different names with similar spelling", similar_name, patients)
    show_case("4. Ramesh Patill spelling mistake", ramesh_spelling, patients)
    show_case("5. Same name but different age", different_age, patients)
    show_case("6. Same name but different phone number", different_phone, patients)
    show_case("7. Missing phone number", missing_phone, patients)
    show_case("8. Missing location", missing_location, patients)
    show_case("9. No reliable match", no_match, patients)

    multiple = {**priya_shah, "name": "Priya Saha", "phone": None}
    possible_matches = find_patient_matches(multiple, patients, minimum_score=0, result_limit=3)
    print("\n10. Multiple possible matches")
    for result in possible_matches:
        print(f"  {result['patient_name']}: {result['total_score']:.2f} ({result['confidence']})")

    # Assertions make this script useful as a lightweight test as well as a demo.
    assert find_patient_matches(exact, patients, minimum_score=85, result_limit=1)[0]["patient_id"] == "P001"
    assert find_patient_matches(spelling, patients, minimum_score=85, result_limit=1)[0]["patient_id"] == "P001"
    assert find_patient_matches(missing_phone, patients, minimum_score=0, result_limit=1)
    assert find_patient_matches(no_match, patients, minimum_score=90, result_limit=3) == []
    assert len(possible_matches) == 3
    print("\nAll matching checks passed.")


if __name__ == "__main__":
    run_tests()
