from fastapi.testclient import TestClient


def test_root_health_endpoint(client: TestClient):
    """Test A1: GET /health returns status ok."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert "version" in data


def test_versioned_health_endpoint(client: TestClient):
    """Test A2: GET /api/v1/health returns versioned status ok."""
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["version"] == "1.0.0"
