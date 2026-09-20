# RelyCare - FastAPI Backend Service

This directory contains the server-side REST API backend for the **RelyCare** offline-first healthcare referral continuity system.

---

## 1. Architectural Foundations: Dual-Database Strategy

RelyCare uses both **SQLite** and **PostgreSQL** in complementary roles:

- **SQLite (Drift):** *"Local persistence for offline-first operation."*
  Runs directly on the healthcare worker's client device (mobile/desktop). Referrals and patient records are saved immediately to local SQLite even without network connectivity, ensuring zero data loss and instantaneous UI responsiveness.
- **FastAPI:** *"API layer between Flutter clients and PostgreSQL."*
  Exposes high-performance, validated, asynchronous REST endpoints for ingesting referrals, providing health checks, and updating referral lifecycles.
- **PostgreSQL:** *"Centralized server-side persistence after synchronization."*
  The single source of truth across all Primary Health Centres (PHCs) and District Hospitals once local changes are synchronized over HTTPS.

```
DEVICE (PHC Client)               SERVER (FastAPI & PostgreSQL)

  Flutter App                         FastAPI Backend
       ↓                                    ↓
 Local SQLite (Drift)               Pydantic Validation
       ↓                                    ↓
 Local Sync Queue ─── HTTPS REST ────→ Central PostgreSQL
```

---

## 2. API Endpoints

All referral endpoints are versioned under `/api/v1/`.

| Method | Endpoint | Description | Status Codes |
|---|---|---|---|
| `GET` | `/health` | Lightweight service health check | `200 OK` |
| `GET` | `/api/v1/health` | Versioned health check with environment details | `200 OK` |
| `POST` | `/api/v1/referrals` | Ingest synchronized referral from client | `201 Created`, `409 Conflict`, `422 Unprocessable` |
| `GET` | `/api/v1/referrals/{referral_id}` | Retrieve referral details by referral ID | `200 OK`, `404 Not Found` |
| `PATCH` | `/api/v1/referrals/{referral_id}/status` | Update referral lifecycle status | `200 OK`, `404 Not Found`, `422 Unprocessable` |
| `GET` | `/api/v1/referrals` | Paginated list of referrals with optional status filter | `200 OK` |

Interactive Swagger documentation is available at:
`http://localhost:8000/api/v1/docs`

---

## 3. Local Setup & Running the Server

### Prerequisites
- Python 3.11+
- PostgreSQL (or local SQLite for testing)

### Step 1: Create and Activate Virtual Environment
```bash
# In the backend/ directory
python -m venv .venv

# Windows (PowerShell)
.\.venv\Scripts\Activate.ps1

# Linux / macOS
source .venv/bin/activate
```

### Step 2: Install Dependencies
```bash
pip install -r requirements.txt
```

### Step 3: Configure Environment Variables
Copy `.env.example` to `.env` and adjust the PostgreSQL connection string:
```bash
cp .env.example .env
```

Example `.env`:
```env
PROJECT_NAME=RelyCare Backend API
API_V1_STR=/api/v1
ENVIRONMENT=development
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/relycare_db
BACKEND_CORS_ORIGINS=["http://localhost", "http://localhost:3000", "http://localhost:8000"]
```

### Step 4: Start the Development Server
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

---

## 4. Running Backend Tests

Backend tests use an isolated in-memory test database and do not interfere with developer PostgreSQL instances:

```bash
# In backend/ directory with .venv active:
pytest -v
```

All test cases verify:
- Health endpoints (`/health`, `/api/v1/health`)
- Ingestion of referrals with full validation (`POST /api/v1/referrals`)
- Duplicate `referral_id` rejection with `409 Conflict`
- Status transitions (`PATCH /api/v1/referrals/{id}/status`)
- Missing referral `404 Not Found` handling
- Unhandled server error sanitation (no credential or trace leaks)
- Response schema timestamp conformance

---

## 5. Security & Design Considerations

- **Data Sanitization:** Input payloads are strictly validated using Pydantic models. Malformed strings or invalid age numbers are rejected with `422 Unprocessable Entity`.
- **Credential Protection:** Database credentials are never logged or exposed in client responses.
- **Independence from SMS:** SMS fallback (Phase 6) operates out-of-band and does not replace or interfere with HTTPS sync.
- **Future Enhancements:**
  - **Authentication / RBAC:** JWT authentication and role-based access control (PHC Clinician vs. District Hospital Staff) will be introduced in a subsequent phase.
  - **Fuzzy Identity Matching:** Demographic similarity scoring (RapidFuzz) is developed separately by a designated teammate and will consume these standardized API endpoints.
