RelyCare
Offline-first healthcare referral continuity system with SMS fallback and identity matching.

RelyCare is a connectivity-resilient referral management platform designed for Primary Health Centres (PHCs) and District Hospitals operating in low-connectivity environments. The system ensures that patient referrals remain traceable and transferable even when internet connectivity fails, paper records are lost, or patient identity information is inconsistent between facilities.

Table of Contents
Problem

Solution

Architecture

Core Features

Technical Stack

Project Structure

Data Model

API Endpoints

Backend Setup

Frontend Setup

Testing

Data Flow & Privacy

Security

Documentation

Contributing

Problem
In rural healthcare settings, the referral pathway from PHC to District Hospital frequently breaks due to:

Failure Point	Consequence
Paper referral lost/damaged	Clinical context lost; receiving doctor starts from scratch
No internet at PHC	Digital referral systems become non-functional
Intermittent connectivity	Standard cloud-dependent apps fail
Inconsistent patient identity	Duplicate records; fragmented patient history
No delivery confirmation	Referring facility has no visibility into referral outcome
Multi-facility journeys	Referral chain breaks across PHC → District → Specialist
The fundamental issue: creating a referral does not guarantee the referral reaches the next level of care.

Solution
RelyCare addresses these failure points through:

Offline-first referral creation — Referrals are saved locally before any network operation is attempted.

Connectivity-aware sync engine — Three network states (Online, Weak, Offline) with priority-based transmission.

SMS fallback — Compact routing metadata transmitted when internet is unavailable.

Identity reconciliation — Fuzzy matching with human verification to handle inconsistent patient records.

Referral lifecycle tracking — Full state machine with failure detection and escalation.

Core principle: A referral should never become invisible simply because the paper was lost, the network disappeared, or the patient's name was recorded differently.

Architecture
text
┌─────────────────────────────────────────────────────────────────┐
│                         PHC FACILITY                            │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────┐  │
│  │  Flutter UI │───▶│ Local SQLite│───▶│   Sync Queue        │  │
│  │             │    │   /Drift    │    │   (Priority-based)  │  │
│  └─────────────┘    └─────────────┘    └──────────┬──────────┘  │
└────────────────────────────────────────────────────┼────────────┘
                                                     │
                    ┌────────────────────────────────┼────────────────────────────────┐
                    │                                │                                │
                    ▼                                ▼                                ▼
            ┌───────────────┐              ┌───────────────┐              ┌───────────────┐
            │   Internet    │              │  SMS Fallback │              │  Store &      │
            │   Available   │              │  (Compact     │              │  Forward      │
            │               │              │   Reference)  │              │  (Delayed)    │
            └───────┬───────┘              └───────┬───────┘              └───────┬───────┘
                    │                              │                              │
                    └──────────────────────────────┼──────────────────────────────┘
                                                   │
                                                   ▼
                                    ┌─────────────────────────┐
                                    │    FastAPI Backend      │
                                    │    - Referral APIs      │
                                    │    - Sync endpoints     │
                                    │    - Authentication     │
                                    └───────────┬─────────────┘
                                                │
                                                ▼
                                    ┌─────────────────────────┐
                                    │      PostgreSQL         │
                                    │    (Central Store)      │
                                    └───────────┬─────────────┘
                                                │
                                                ▼
                                    ┌─────────────────────────┐
                                    │  Identity Matching      │
                                    │  Engine (Fuzzy Match)   │
                                    └───────────┬─────────────┘
                                                │
                              ┌─────────────────┼─────────────────┐
                              │                 │                 │
                              ▼                 ▼                 ▼
                        ┌───────────┐    ┌───────────┐    ┌───────────┐
                        │   HIGH    │    │  MEDIUM   │    │    LOW    │
                        │ CONFIDENCE│    │CONFIDENCE │    │CONFIDENCE │
                        │           │    │           │    │           │
                        │  Suggest  │    │  Human    │    │   Create  │
                        │   Match   │    │Verification│    │New Record │
                        └───────────┘    └───────────┘    └───────────┘
                                                │
                                                ▼
                                    ┌─────────────────────────┐
                                    │   DISTRICT HOSPITAL     │
                                    │   - Referral Dashboard  │
                                    │   - Identity Resolution │
                                    │   - Status Management   │
                                    └─────────────────────────┘
Dual-Database Strategy:

Database	Role	Location
SQLite (Drift)	Local persistence for offline-first operation	Client device (mobile/desktop)
PostgreSQL	Centralized server-side persistence after synchronization	Server
Core Features
1. Offline-First Referral Creation
No internet required for referral creation

Referrals saved to local SQLite immediately

Automatic queue management

Referral survives app restart and device reboot

2. Connectivity-Aware Sync Engine
State	Behavior
ONLINE	Full synchronization; immediate transmission
WEAK	Priority-based transmission; critical referrals first
OFFLINE	Local storage; queue for later transmission
Priority Queue Logic:

text
Emergency (HIGH) → transmitted first
Urgent (MEDIUM)  → transmitted second
Routine (LOW)    → transmitted last
3. SMS Fallback
When internet is unavailable but cellular signal exists, RelyCare generates a compact, privacy-safe SMS payload containing only essential routing metadata:

text
RelyCare Referral
REF: RC-2026-000142
PHC: PHC-MUM
PAT: Rahul S
AGE: 42
DST: DIST-HOSP-01
Strict limitation: SMS is an unencrypted channel. Medical diagnoses, detailed clinical notes, HIV/reproductive health indicators, and full personal identifiers are never transmitted via SMS. SMS serves purely to alert receiving facilities of an inbound referral. The complete medical file synchronizes via encrypted HTTPS API when connectivity is restored.

4. Identity Reconciliation Engine
Handles patient identity matching across facilities with inconsistent data.

Matching Signals:

Signal	Weight (Configurable)
Name similarity	35%
Phone number	20%
Age compatibility	15%
Location/Village	10%
Referral context	10%
Gender	5%
Guardian name	5%
Name Normalization:

Fuzzy string matching

Transliteration support (Devanagari → Latin)

Abbreviation expansion (K. → Kumar)

Phonetic similarity

Decision Thresholds:

Confidence	Action
High (≥ 85%)	Suggest match with confirmation prompt
Medium	Require mandatory human verification
Low	Create new record
Critical design decision: The system never automatically merges patient records. Human verification is mandatory for all identity linking.

5. Referral Lifecycle Tracking
text
CREATED → QUEUED → SYNCED → SENT → RECEIVED → PATIENT_ARRIVED → UNDER_TREATMENT → COMPLETED
Failure path:

text
FAILED_DELIVERY → RETRY → SMS_FALLBACK → ESCALATION
6. Failure Detection & Escalation
Timeout detection for unacknowledged referrals

Automatic retry with exponential backoff

PHC alerts when referral status is unknown

Emergency referral escalation

Technical Stack
Layer	Technology	Rationale
Frontend	Flutter + Dart	Cross-platform; single codebase for PHC/Hospital
Local Storage	SQLite / Drift	Reliable offline persistence
Backend	FastAPI + Python	High-performance async REST APIs
Central Database	PostgreSQL	ACID compliance; relational integrity
Identity Matching	Python + RapidFuzz	Fuzzy string matching; customizable scoring
Authentication	JWT	Stateless; role-based access
SMS	Simulated Gateway / Provider API	Interface designed for SMS provider integration
Project Structure
text
relay/
├── frontend/                    # Flutter application
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app/
│   │   │   ├── app.dart         # Root MaterialApp widget
│   │   │   ├── routes.dart      # Central navigation routes
│   │   │   └── app_config.dart  # Environment variables, mock flags
│   │   ├── core/
│   │   │   ├── constants/       # App, API, storage constants
│   │   │   ├── theme/           # Material 3 theme, colors, typography
│   │   │   ├── utils/           # Validators, date utils, logger
│   │   │   └── errors/          # Custom typed exceptions
│   │   ├── models/              # Domain entities
│   │   │   ├── patient.dart
│   │   │   ├── referral.dart
│   │   │   ├── referral_status.dart
│   │   │   ├── referral_event.dart
│   │   │   ├── healthcare_facility.dart
│   │   │   └── identity_match.dart
│   │   ├── screens/             # Full-screen UI pages
│   │   │   ├── splash/
│   │   │   ├── onboarding/
│   │   │   ├── login/
│   │   │   ├── dashboard/
│   │   │   ├── create_referral/
│   │   │   ├── referrals/
│   │   │   ├── identity_matching/
│   │   │   ├── sync/
│   │   │   └── profile/
│   │   ├── services/            # Low-level technical services
│   │   │   ├── local_storage/   # SQLite / Drift operations
│   │   │   ├── sync/            # Sync queue, connectivity
│   │   │   ├── sms/             # SMS fallback service
│   │   │   ├── connectivity/    # Network state detection
│   │   │   └── matching/        # Identity matching logic
│   │   ├── repositories/        # Data access orchestrators
│   │   ├── providers/           # State management (ChangeNotifier)
│   │   └── widgets/             # Reusable UI components
│   └── pubspec.yaml
│
├── backend/                     # FastAPI application
│   ├── app/
│   │   ├── main.py
│   │   ├── api/
│   │   │   ├── auth.py
│   │   │   ├── referrals.py
│   │   │   ├── sync.py
│   │   │   ├── matching.py
│   │   │   ├── facilities.py
│   │   │   └── admin.py
│   │   ├── models/
│   │   ├── schemas/
│   │   ├── services/
│   │   │   ├── matching/
│   │   │   ├── sync/
│   │   │   └── sms/
│   │   └── repositories/
│   ├── requirements.txt
│   └── Dockerfile
│
├── database/
│   ├── migrations/
│   └── seeds/
│
├── docs/
│   ├── ARCHITECTURE.md
│   ├── DATA_FLOW.md
│   ├── FOLDER_GUIDE.md
│   ├── REFERRAL_FLOW.md
│   ├── TEAM_WORKFLOW.md
│   └── TODO.md
│
└── README.md
Data Model
Core Entities
USER

text
user_id (PK)
name
role (PHC_DOCTOR, PHC_WORKER, HOSPITAL_DOCTOR, HOSPITAL_ADMIN)
facility_id (FK)
phone
password_hash
created_at
FACILITY

text
facility_id (PK)
name
type (PHC, DISTRICT_HOSPITAL, SPECIALIST)
location
district
contact
PATIENT

text
patient_id (PK)
name
age
gender
phone
village
guardian_name
created_at
REFERRAL

text
referral_id (PK)
patient_id (FK)
source_facility_id (FK)
destination_facility_id (FK)
reason
symptoms
observations
tests_performed
medicines_given
priority (EMERGENCY, URGENT, ROUTINE)
status
sync_state
created_at
updated_at
REFERRAL_EVENT

text
event_id (PK)
referral_id (FK)
status
actor_id (FK)
timestamp
remarks
IDENTITY_MATCH

text
match_id (PK)
referral_id (FK)
candidate_patient_id (FK)
name_score
age_score
phone_score
location_score
gender_score
context_score
overall_score
verification_status
verified_by (FK)
verified_at
SYNC_QUEUE (Local)

text
id (PK)
entity_type
entity_id
operation
payload
status (PENDING, SYNCING, SUCCESS, FAILED)
retry_count
created_at
last_attempt
API Endpoints
All referral endpoints are versioned under /api/v1/.

Method	Endpoint	Description	Status Codes
GET	/health	Lightweight service health check	200 OK
GET	/api/v1/health	Versioned health check with environment details	200 OK
POST	/api/v1/referrals	Ingest synchronized referral from client	201 Created, 409 Conflict, 422 Unprocessable
GET	/api/v1/referrals/{referral_id}	Retrieve referral details by referral ID	200 OK, 404 Not Found
PATCH	/api/v1/referrals/{referral_id}/status	Update referral lifecycle status	200 OK, 404 Not Found, 422 Unprocessable
GET	/api/v1/referrals	Paginated list of referrals with optional status filter	200 OK
Interactive Swagger documentation is available at: http://localhost:8000/api/v1/docs

Backend Setup
Prerequisites
Python 3.11+

PostgreSQL (or local SQLite for testing)

Step 1: Create and Activate Virtual Environment
bash
# In the backend/ directory
python -m venv .venv

# Windows (PowerShell)
.\.venv\Scripts\Activate.ps1

# Linux / macOS
source .venv/bin/activate
Step 2: Install Dependencies
bash
pip install -r requirements.txt
Step 3: Configure Environment Variables
bash
cp .env.example .env
Edit .env:

text
PROJECT_NAME=RelyCare Backend API
API_V1_STR=/api/v1
ENVIRONMENT=development
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/relycare_db
BACKEND_CORS_ORIGINS=["http://localhost", "http://localhost:3000", "http://localhost:8000"]
Step 4: Start the Development Server
bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
Frontend Setup
Prerequisites
Flutter SDK (latest stable)

Dart SDK

Steps
bash
# Clone the repository
git clone https://github.com/utkarshpan/RelyCare.git
cd RelyCare

# Install dependencies
flutter pub get

# Run the application
flutter run
Testing
Backend Tests
Backend tests use an isolated in-memory test database and do not interfere with developer PostgreSQL instances:

bash
# In backend/ directory with .venv active:
pytest -v
Test coverage includes:

Health endpoints (/health, /api/v1/health)

Ingestion of referrals with full validation (POST /api/v1/referrals)

Duplicate referral_id rejection with 409 Conflict

Status transitions (PATCH /api/v1/referrals/{referral_id}/status)

Retrieval by referral ID

Paginated listing with status filters

Flutter Tests
bash
flutter test
Data Flow & Privacy
End-to-End Data Pipeline
text
Patient Demographics → Referral Record → Local SQLite DB
                                                    ↓
                                          Connectivity Check
                                         /                  \
                                    Online                  Offline
                                       ↓                       ↓
                              Backend REST API          Local Sync Queue
                                  / HTTPS                       ↓
                                       ↓                SMS Fallback Gateway
                              Central PostgreSQL              ↓
                                       ↓                (Optional)
                              District Hospital Client
                                       ↓
                              Identity Matching Engine
                                       ↓
                              Confidence Threshold
                              /                  \
                        High                     Low
                         ↓                        ↓
              Suggested Match +           Mandatory Human
                Confirmation                  Verification
                         ↓                        ↓
                         └──────────┬─────────────┘
                                    ↓
                         Active Treatment & Status Updates
SMS Privacy Rules
Strict limitation: Plain SMS is an unencrypted, insecure telecom channel.

Never transmitted via SMS:

Medical diagnoses

Detailed clinical notes

HIV/reproductive health indicators

Full personal identifiers

Symptoms, treatments, prescribed medications

Permitted data in SMS fallback payload (minimum data principle):

Referral Identifier / Token (REF: RC-2026-000142)

Originating PHC Facility Code (PHC: PHC-MUM)

Sanitized Patient Name (PAT: Rahul S — First name + initial only)

Patient Age (AGE: 42)

Destination Facility Code (DST: DIST-HOSP-01)

Out-of-band delivery: SMS serves purely to alert receiving facilities of an inbound referral. The complete medical file synchronizes via encrypted HTTPS API when connectivity is restored.

Centralized HTTPS API Data Flow
When client devices are connected to the network, the Flutter SyncService batches and uploads queued referral operations to FastAPI via HTTPS:

Payload Serialization: Referral models in SQLite are serialized into validated JSON matching ReferralCreate Pydantic schema.

REST Ingestion: Sent to POST /api/v1/referrals.

Duplicate Detection: Server checks for matching referral_id. Duplicate attempts safely return 409 Conflict without data corruption.

PostgreSQL Commit: Server commits record to centralized PostgreSQL referrals table and returns 201 Created with ISO timestamps.

Local Sync State Transition: Only upon receiving successful HTTP response does the client transition local SQLite record to SYNCED.

Security
Authentication & Authorization
JWT-based authentication

Role-based access control (RBAC)

Facility-scoped data access

Data Protection
HTTPS for all network communication

Local SQLite storage for offline data

Minimal data in SMS fallback (routing metadata only)

Audit Trail
All actions logged:

Who created referral

Who viewed referral

Who modified referral

Who verified identity match

Timestamps for all events

Integrity
Hash-based referral fingerprint

Detection of unexpected modifications

Documentation
The docs/ directory contains detailed technical documentation:

Document	Description
ARCHITECTURE.md	System architecture and component design
DATA_FLOW.md	End-to-end data pipeline, privacy rules, and SMS constraints
REFERRAL_FLOW.md	Complete referral lifecycle with sequence diagrams
FOLDER_GUIDE.md	Codebase structure and file responsibilities
TEAM_WORKFLOW.md	Development workflow and branching strategy
TODO.md	Planned features and known issues
