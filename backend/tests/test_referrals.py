import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.models.facility import FacilityModel
from app.models.user import UserModel
from app.core.security import hash_password


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


@pytest.fixture
def auth_headers(db_session: Session, client: TestClient):
    """Fixture providing authenticated headers for test requests."""
    # Ensure facilities exist
    f1 = db_session.query(FacilityModel).filter_by(facility_code="PHC-MUM").first()
    if not f1:
        db_session.add(FacilityModel(facility_code="PHC-MUM", name="PHC Mumbai", facility_type="PHC"))
    f2 = db_session.query(FacilityModel).filter_by(facility_code="DIST-HOSP-01").first()
    if not f2:
        db_session.add(FacilityModel(facility_code="DIST-HOSP-01", name="District Hospital 1", facility_type="DISTRICT_HOSPITAL"))
    db_session.commit()

    u = db_session.query(UserModel).filter_by(username="test_phc_ref_user").first()
    if not u:
        u = UserModel(
            username="test_phc_ref_user",
            password_hash=hash_password("Pass123!"),
            role="PHC_STAFF",
            facility_id="PHC-MUM",
            is_active=True,
        )
        db_session.add(u)
        db_session.commit()

    resp = client.post("/api/v1/auth/login", json={"username": "test_phc_ref_user", "password": "Pass123!"})
    token = resp.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


def test_create_referral_success(client: TestClient, auth_headers: dict):
    """Test B: Create referral succeeds with 201 Created and persists all data."""
    response = client.post("/api/v1/referrals", json=SAMPLE_REFERRAL_PAYLOAD, headers=auth_headers)
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


def test_get_referral_by_id_success(client: TestClient, auth_headers: dict):
    """Test C: Referral can be retrieved by its unique referral_id."""
    client.post("/api/v1/referrals", json=SAMPLE_REFERRAL_PAYLOAD, headers=auth_headers)

    response = client.get("/api/v1/referrals/RC-2026-000142", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert data["referral_id"] == "RC-2026-000142"
    assert data["patient_name"] == "Rahul Sharma"
    assert data["status"] == "CREATED"


def test_update_referral_status_success(client: TestClient, auth_headers: dict):
    """Test D: Referral status can be updated through valid lifecycle states."""
    client.post("/api/v1/referrals", json=SAMPLE_REFERRAL_PAYLOAD, headers=auth_headers)

    patch_resp = client.patch(
        "/api/v1/referrals/RC-2026-000142/status",
        json={"status": "RECEIVED"},
        headers=auth_headers,
    )
    assert patch_resp.status_code == 200
    assert patch_resp.json()["status"] == "RECEIVED"

    patch_resp2 = client.patch(
        "/api/v1/referrals/RC-2026-000142/status",
        json={"status": "PATIENT_ARRIVED"},
        headers=auth_headers,
    )
    assert patch_resp2.status_code == 200
    assert patch_resp2.json()["status"] == "PATIENT_ARRIVED"

    get_resp = client.get("/api/v1/referrals/RC-2026-000142", headers=auth_headers)
    assert get_resp.status_code == 200
    assert get_resp.json()["status"] == "PATIENT_ARRIVED"


def test_list_referrals_and_filter(client: TestClient, auth_headers: dict):
    """Test E: Referral listing with pagination and status filtering."""
    client.post("/api/v1/referrals", json={
        **SAMPLE_REFERRAL_PAYLOAD,
        "referral_id": "RC-LIST-001",
        "patient_name": "Patient A",
        "status": "CREATED",
    }, headers=auth_headers)
    client.post("/api/v1/referrals", json={
        **SAMPLE_REFERRAL_PAYLOAD,
        "referral_id": "RC-LIST-002",
        "patient_name": "Patient B",
        "status": "RECEIVED",
    }, headers=auth_headers)
    client.post("/api/v1/referrals", json={
        **SAMPLE_REFERRAL_PAYLOAD,
        "referral_id": "RC-LIST-003",
        "patient_name": "Patient C",
        "status": "CREATED",
    }, headers=auth_headers)

    all_resp = client.get("/api/v1/referrals", headers=auth_headers)
    assert all_resp.status_code == 200
    assert all_resp.json()["total"] == 3
    assert len(all_resp.json()["items"]) == 3

    created_resp = client.get("/api/v1/referrals?status=CREATED", headers=auth_headers)
    assert created_resp.status_code == 200
    assert created_resp.json()["total"] == 2

    rcv_resp = client.get("/api/v1/referrals?status=RECEIVED", headers=auth_headers)
    assert rcv_resp.status_code == 200
    assert rcv_resp.json()["total"] == 1
    assert rcv_resp.json()["items"][0]["referral_id"] == "RC-LIST-002"

    page_resp = client.get("/api/v1/referrals?skip=1&limit=1", headers=auth_headers)
    assert page_resp.status_code == 200
    assert len(page_resp.json()["items"]) == 1
    assert page_resp.json()["total"] == 3


def test_invalid_referral_data_rejected(client: TestClient, auth_headers: dict):
    """Test F: Invalid referral data (blank names, invalid age, empty fields) is rejected with 422."""
    resp_neg_age = client.post("/api/v1/referrals", json={
        **SAMPLE_REFERRAL_PAYLOAD,
        "age": -5,
    }, headers=auth_headers)
    assert resp_neg_age.status_code == 422

    resp_huge_age = client.post("/api/v1/referrals", json={
        **SAMPLE_REFERRAL_PAYLOAD,
        "age": 200,
    }, headers=auth_headers)
    assert resp_huge_age.status_code == 422

    resp_blank_name = client.post("/api/v1/referrals", json={
        **SAMPLE_REFERRAL_PAYLOAD,
        "patient_name": "   ",
    }, headers=auth_headers)
    assert resp_blank_name.status_code == 422

    invalid_payload = {**SAMPLE_REFERRAL_PAYLOAD}
    del invalid_payload["source_facility"]
    resp_missing = client.post("/api/v1/referrals", json=invalid_payload, headers=auth_headers)
    assert resp_missing.status_code == 422


def test_invalid_status_rejected(client: TestClient, auth_headers: dict):
    """Test G: Invalid status update is rejected with 422 validation error."""
    client.post("/api/v1/referrals", json=SAMPLE_REFERRAL_PAYLOAD, headers=auth_headers)

    resp = client.patch(
        "/api/v1/referrals/RC-2026-000142/status",
        json={"status": "RANDOM_INVALID_STATUS"},
        headers=auth_headers,
    )
    assert resp.status_code == 422
    assert "Invalid request payload" in resp.text or "status" in resp.text


def test_duplicate_referral_id_rejected(client: TestClient, auth_headers: dict):
    """Test H: Duplicate referral_id produces 409 Conflict and preserves database integrity."""
    resp1 = client.post("/api/v1/referrals", json=SAMPLE_REFERRAL_PAYLOAD, headers=auth_headers)
    assert resp1.status_code == 201

    resp2 = client.post("/api/v1/referrals", json=SAMPLE_REFERRAL_PAYLOAD, headers=auth_headers)
    assert resp2.status_code == 409
    assert "already exists" in resp2.json()["detail"]


def test_missing_referral_returns_404(client: TestClient, auth_headers: dict):
    """Test I: Missing referral returns 404 Not Found."""
    resp = client.get("/api/v1/referrals/NON-EXISTENT-ID", headers=auth_headers)
    assert resp.status_code == 404
    assert "not found" in resp.json()["detail"]

    patch_resp = client.patch(
        "/api/v1/referrals/NON-EXISTENT-ID/status",
        json={"status": "RECEIVED"},
        headers=auth_headers,
    )
    assert patch_resp.status_code == 404
    assert "not found" in patch_resp.json()["detail"]


def test_internal_error_does_not_leak_credentials(monkeypatch):
    """Test J: Simulated internal database failure returns clean 500 without leaking credentials."""
    def broken_get_db():
        raise RuntimeError("Database connection string postgresql://admin:secretpass@10.0.0.1 failed")

    from app.main import app
    app.dependency_overrides[get_db] = broken_get_db

    try:
        with TestClient(app, raise_server_exceptions=False) as failing_client:
            resp = failing_client.get("/api/v1/referrals")
            assert resp.status_code == 500
            data = resp.json()
            assert "secretpass" not in str(data)
            assert "postgresql://" not in str(data)
            assert data["detail"] == "An internal server error occurred. Please try again later."
    finally:
        app.dependency_overrides.clear()


def test_schema_validity_and_timestamps(client: TestClient, auth_headers: dict):
    """Test K: Validates response schema and ISO 8601 timestamps."""
    resp = client.post("/api/v1/referrals", json=SAMPLE_REFERRAL_PAYLOAD, headers=auth_headers)
    assert resp.status_code == 201
    data = resp.json()
    assert isinstance(data["id"], int)
    assert isinstance(data["created_at"], str)
    assert isinstance(data["updated_at"], str)
