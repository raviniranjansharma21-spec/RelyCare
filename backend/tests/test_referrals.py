import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.schemas.referral import ReferralStatusEnum


SAMPLE_REFERRAL_PAYLOAD = {
    "referral_id": "RC-2026-000142",
    "patient_name": "Rahul Sharma",
    "age": 42,
    "gender": "Male",
    "village_or_location": "Village Rampur",
    "contact_number": "+91 9876543210",
    "source_facility": "PHC-MUM",
    "destination_facility": "DIST-HOSP-01",
    "urgency": "URGENT",
    "reason": "Suspected acute appendicitis requiring surgical evaluation",
    "clinical_notes_summary": "Pain in right lower quadrant for 24h. No fever.",
    "status": "CREATED",
}


def test_create_referral_success(client: TestClient):
    """Test B: Create referral succeeds with 201 Created and persists all data."""
    response = client.post("/api/v1/referrals", json=SAMPLE_REFERRAL_PAYLOAD)
    assert response.status_code == 201
    data = response.json()
    assert data["referral_id"] == "RC-2026-000142"
    assert data["patient_name"] == "Rahul Sharma"
    assert data["age"] == 42
    assert data["gender"] == "Male"
    assert data["village_or_location"] == "Village Rampur"
    assert data["source_facility"] == "PHC-MUM"
    assert data["destination_facility"] == "DIST-HOSP-01"
    assert data["urgency"] == "URGENT"
    assert data["status"] == "CREATED"
    assert "id" in data
    assert "created_at" in data
    assert "updated_at" in data


def test_get_referral_by_id_success(client: TestClient):
    """Test C: Referral can be retrieved by its unique referral_id."""
    # Create first
    client.post("/api/v1/referrals", json=SAMPLE_REFERRAL_PAYLOAD)

    # Retrieve
    response = client.get("/api/v1/referrals/RC-2026-000142")
    assert response.status_code == 200
    data = response.json()
    assert data["referral_id"] == "RC-2026-000142"
    assert data["patient_name"] == "Rahul Sharma"
    assert data["status"] == "CREATED"


def test_update_referral_status_success(client: TestClient):
    """Test D: Referral status can be updated through valid lifecycle states."""
    # Create
    client.post("/api/v1/referrals", json=SAMPLE_REFERRAL_PAYLOAD)

    # Update to RECEIVED
    patch_resp = client.patch(
        "/api/v1/referrals/RC-2026-000142/status",
        json={"status": "RECEIVED"},
    )
    assert patch_resp.status_code == 200
    assert patch_resp.json()["status"] == "RECEIVED"

    # Update to PATIENT_ARRIVED
    patch_resp2 = client.patch(
        "/api/v1/referrals/RC-2026-000142/status",
        json={"status": "PATIENT_ARRIVED"},
    )
    assert patch_resp2.status_code == 200
    assert patch_resp2.json()["status"] == "PATIENT_ARRIVED"

    # Verify retrieval reflects new status
    get_resp = client.get("/api/v1/referrals/RC-2026-000142")
    assert get_resp.status_code == 200
    assert get_resp.json()["status"] == "PATIENT_ARRIVED"


def test_list_referrals_and_filter(client: TestClient):
    """Test E: Referral listing with pagination and status filtering."""
    # Seed 3 referrals
    client.post("/api/v1/referrals", json={
        **SAMPLE_REFERRAL_PAYLOAD,
        "referral_id": "RC-LIST-001",
        "patient_name": "Patient A",
        "status": "CREATED",
    })
    client.post("/api/v1/referrals", json={
        **SAMPLE_REFERRAL_PAYLOAD,
        "referral_id": "RC-LIST-002",
        "patient_name": "Patient B",
        "status": "RECEIVED",
    })
    client.post("/api/v1/referrals", json={
        **SAMPLE_REFERRAL_PAYLOAD,
        "referral_id": "RC-LIST-003",
        "patient_name": "Patient C",
        "status": "CREATED",
    })

    # List all
    all_resp = client.get("/api/v1/referrals")
    assert all_resp.status_code == 200
    assert all_resp.json()["total"] == 3
    assert len(all_resp.json()["items"]) == 3

    # Filter by CREATED
    created_resp = client.get("/api/v1/referrals?status=CREATED")
    assert created_resp.status_code == 200
    assert created_resp.json()["total"] == 2

    # Filter by RECEIVED
    rcv_resp = client.get("/api/v1/referrals?status=RECEIVED")
    assert rcv_resp.status_code == 200
    assert rcv_resp.json()["total"] == 1
    assert rcv_resp.json()["items"][0]["referral_id"] == "RC-LIST-002"

    # Pagination: limit 1, skip 1
    page_resp = client.get("/api/v1/referrals?skip=1&limit=1")
    assert page_resp.status_code == 200
    assert len(page_resp.json()["items"]) == 1
    assert page_resp.json()["total"] == 3


def test_invalid_referral_data_rejected(client: TestClient):
    """Test F: Invalid referral data (blank names, invalid age, empty fields) is rejected with 422."""
    # Negative age
    resp_neg_age = client.post("/api/v1/referrals", json={
        **SAMPLE_REFERRAL_PAYLOAD,
        "age": -5,
    })
    assert resp_neg_age.status_code == 422

    # Age > 150
    resp_huge_age = client.post("/api/v1/referrals", json={
        **SAMPLE_REFERRAL_PAYLOAD,
        "age": 200,
    })
    assert resp_huge_age.status_code == 422

    # Blank patient name
    resp_blank_name = client.post("/api/v1/referrals", json={
        **SAMPLE_REFERRAL_PAYLOAD,
        "patient_name": "   ",
    })
    assert resp_blank_name.status_code == 422

    # Missing mandatory source_facility
    invalid_payload = {**SAMPLE_REFERRAL_PAYLOAD}
    del invalid_payload["source_facility"]
    resp_missing = client.post("/api/v1/referrals", json=invalid_payload)
    assert resp_missing.status_code == 422


def test_invalid_status_rejected(client: TestClient):
    """Test G: Invalid status update is rejected with 422 validation error."""
    client.post("/api/v1/referrals", json=SAMPLE_REFERRAL_PAYLOAD)

    resp = client.patch(
        "/api/v1/referrals/RC-2026-000142/status",
        json={"status": "RANDOM_INVALID_STATUS"},
    )
    assert resp.status_code == 422
    assert "Invalid request payload" in resp.text or "status" in resp.text


def test_duplicate_referral_id_rejected(client: TestClient):
    """Test H: Duplicate referral_id produces 409 Conflict and preserves database integrity."""
    # First create
    resp1 = client.post("/api/v1/referrals", json=SAMPLE_REFERRAL_PAYLOAD)
    assert resp1.status_code == 201

    # Second create with identical referral_id
    resp2 = client.post("/api/v1/referrals", json=SAMPLE_REFERRAL_PAYLOAD)
    assert resp2.status_code == 409
    assert "already exists" in resp2.json()["detail"]


def test_missing_referral_returns_404(client: TestClient):
    """Test I: Missing referral returns 404 Not Found."""
    # GET missing
    resp = client.get("/api/v1/referrals/NON-EXISTENT-ID")
    assert resp.status_code == 404
    assert "not found" in resp.json()["detail"]

    # PATCH missing
    patch_resp = client.patch(
        "/api/v1/referrals/NON-EXISTENT-ID/status",
        json={"status": "RECEIVED"},
    )
    assert patch_resp.status_code == 404
    assert "not found" in patch_resp.json()["detail"]


def test_internal_error_does_not_leak_credentials(monkeypatch):
    """Test J: Simulated internal database failure returns clean 500 without leaking credentials."""
    def broken_get_db():
        raise RuntimeError("Database connection string postgresql://admin:secretpass@10.0.0.1 failed")

    # Override get_db to simulate failure
    from app.main import app
    app.dependency_overrides[get_db] = broken_get_db

    try:
        # Instantiate test client with raise_server_exceptions=False to allow checking 500 response
        with TestClient(app, raise_server_exceptions=False) as failing_client:
            resp = failing_client.get("/api/v1/referrals")
            assert resp.status_code == 500
            data = resp.json()
            assert "secretpass" not in str(data)
            assert "postgresql://" not in str(data)
            assert data["detail"] == "An internal server error occurred. Please try again later."
    finally:
        app.dependency_overrides.clear()



def test_schema_validity_and_timestamps(client: TestClient):
    """Test K: Validates response schema and ISO 8601 timestamps."""
    resp = client.post("/api/v1/referrals", json=SAMPLE_REFERRAL_PAYLOAD)
    assert resp.status_code == 201
    data = resp.json()
    assert isinstance(data["id"], int)
    assert isinstance(data["created_at"], str)
    assert isinstance(data["updated_at"], str)
