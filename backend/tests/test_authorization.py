import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.models.facility import FacilityModel
from app.models.user import UserModel
from app.core.security import hash_password, create_access_token


@pytest.fixture(autouse=True)
def setup_rbac_test_data(db_session: Session):
    """Setup facilities and users for RBAC and facility authorization tests."""
    phc1 = FacilityModel(facility_code="PHC_01", name="PHC 1", facility_type="PHC", is_active=True)
    phc2 = FacilityModel(facility_code="PHC_02", name="PHC 2", facility_type="PHC", is_active=True)
    dh1 = FacilityModel(facility_code="DH_01", name="District Hospital 1", facility_type="DISTRICT_HOSPITAL", is_active=True)
    dh2 = FacilityModel(facility_code="DH_02", name="District Hospital 2", facility_type="DISTRICT_HOSPITAL", is_active=True)
    db_session.add_all([phc1, phc2, dh1, dh2])
    db_session.commit()

    u_phc1 = UserModel(
        username="user_phc1",
        password_hash=hash_password("Pass123!"),
        role="PHC_STAFF",
        facility_id="PHC_01",
        is_active=True,
    )
    u_phc2 = UserModel(
        username="user_phc2",
        password_hash=hash_password("Pass123!"),
        role="PHC_STAFF",
        facility_id="PHC_02",
        is_active=True,
    )
    u_dh1 = UserModel(
        username="user_dh1",
        password_hash=hash_password("Pass123!"),
        role="HOSPITAL_STAFF",
        facility_id="DH_01",
        is_active=True,
    )
    u_dh2 = UserModel(
        username="user_dh2",
        password_hash=hash_password("Pass123!"),
        role="HOSPITAL_STAFF",
        facility_id="DH_02",
        is_active=True,
    )
    db_session.add_all([u_phc1, u_phc2, u_dh1, u_dh2])
    db_session.commit()


def get_auth_header(client: TestClient, username: str) -> dict:
    resp = client.post("/api/v1/auth/login", json={"username": username, "password": "Pass123!"})
    token = resp.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


def test_unauthenticated_access_rejected(client: TestClient):
    response = client.get("/api/v1/referrals")
    assert response.status_code == 401


def test_phc_create_referral_authorized(client: TestClient):
    headers = get_auth_header(client, "user_phc1")
    payload = {
        "referral_id": "RC-AUTH-TEST-001",
        "patient_name": "Test Patient",
        "age": 30,
        "gender": "Female",
        "village_or_location": "Village A",
        "contact_number": "+919999999999",
        "source_facility": "PHC_01",
        "destination_facility": "DH_01",
        "urgency": "URGENT",
        "reason": "Severe anemia requiring specialist care",
        "status": "CREATED",
    }
    response = client.post("/api/v1/referrals", json=payload, headers=headers)
    assert response.status_code == 201
    assert response.json()["referral_id"] == "RC-AUTH-TEST-001"


def test_phc_cannot_create_for_other_facility(client: TestClient):
    headers = get_auth_header(client, "user_phc1")
    payload = {
        "referral_id": "RC-AUTH-TEST-002",
        "patient_name": "Test Patient 2",
        "age": 25,
        "gender": "Male",
        "source_facility": "PHC_02",  # Different facility!
        "destination_facility": "DH_01",
        "urgency": "ROUTINE",
        "reason": "Routine checkup",
        "status": "CREATED",
    }
    response = client.post("/api/v1/referrals", json=payload, headers=headers)
    assert response.status_code == 403


def test_facility_isolation_list(client: TestClient):
    # PHC 1 creates referral to DH 1
    h_phc1 = get_auth_header(client, "user_phc1")
    client.post("/api/v1/referrals", json={
        "referral_id": "RC-AUTH-PHC1",
        "patient_name": "Patient PHC1",
        "age": 40,
        "gender": "Male",
        "source_facility": "PHC_01",
        "destination_facility": "DH_01",
        "urgency": "ROUTINE",
        "reason": "Followup",
        "status": "CREATED",
    }, headers=h_phc1)

    # PHC 2 creates referral to DH 2
    h_phc2 = get_auth_header(client, "user_phc2")
    client.post("/api/v1/referrals", json={
        "referral_id": "RC-AUTH-PHC2",
        "patient_name": "Patient PHC2",
        "age": 50,
        "gender": "Female",
        "source_facility": "PHC_02",
        "destination_facility": "DH_02",
        "urgency": "ROUTINE",
        "reason": "Followup",
        "status": "CREATED",
    }, headers=h_phc2)

    # Check PHC 1 list: only sees PHC 1 referral
    res_phc1 = client.get("/api/v1/referrals", headers=h_phc1)
    ids_phc1 = [r["referral_id"] for r in res_phc1.json()["items"]]
    assert "RC-AUTH-PHC1" in ids_phc1
    assert "RC-AUTH-PHC2" not in ids_phc1

    # Check DH 1 list: sees referral sent to DH 1
    h_dh1 = get_auth_header(client, "user_dh1")
    res_dh1 = client.get("/api/v1/referrals", headers=h_dh1)
    ids_dh1 = [r["referral_id"] for r in res_dh1.json()["items"]]
    assert "RC-AUTH-PHC1" in ids_dh1
    assert "RC-AUTH-PHC2" not in ids_dh1


def test_hospital_status_update_authorization(client: TestClient):
    # PHC 1 creates referral for DH 1
    h_phc1 = get_auth_header(client, "user_phc1")
    client.post("/api/v1/referrals", json={
        "referral_id": "RC-STATUS-TEST-01",
        "patient_name": "Patient Status",
        "age": 35,
        "gender": "Female",
        "source_facility": "PHC_01",
        "destination_facility": "DH_01",
        "urgency": "ROUTINE",
        "reason": "Cardiology consult",
        "status": "CREATED",
    }, headers=h_phc1)

    # DH 1 (destination hospital) updates status -> 200 OK
    h_dh1 = get_auth_header(client, "user_dh1")
    resp1 = client.patch("/api/v1/referrals/RC-STATUS-TEST-01/status", json={"status": "RECEIVED"}, headers=h_dh1)
    assert resp1.status_code == 200
    assert resp1.json()["status"] == "RECEIVED"

    # DH 2 (unrelated hospital) attempts to update status -> 403 Forbidden
    h_dh2 = get_auth_header(client, "user_dh2")
    resp2 = client.patch("/api/v1/referrals/RC-STATUS-TEST-01/status", json={"status": "COMPLETED"}, headers=h_dh2)
    assert resp2.status_code == 403
