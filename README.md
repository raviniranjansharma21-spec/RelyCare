# RelyCare

### Offline-First Referral Continuity for Primary Healthcare

> **The network may fail. The referral shouldn't.**

RelyCare is an offline-first healthcare referral continuity platform designed to help referrals move reliably from **Primary Health Centres (PHCs)** to **District Hospitals**, even when internet connectivity is unreliable.

The system focuses on a simple but critical problem:

**A referral is not successful when a doctor clicks "Send".  
A referral is successful when the patient continues care at the next facility.**

---

## 🚨 The Problem

Healthcare referrals often cross multiple facilities, but the communication layer between them can be fragile.

A typical referral journey can break because of:

- 📶 Unreliable or unavailable internet connectivity
- 📄 Fragmented referral information
- 🔄 Delayed synchronization between facilities
- 👤 Patient identity variations between records
- 🏥 Lack of visibility at the receiving hospital
- 🔐 Need for secure, facility-level access control

When a referral is created at a PHC but the receiving hospital does not reliably receive or identify it, **continuity of care is affected**.

RelyCare is designed to address this gap.

---

# 💡 Our Solution

RelyCare provides an **offline-first referral continuity layer** between healthcare facilities.

Instead of depending entirely on an active internet connection:

```text
                    INTERNET AVAILABLE
                           │
                           ▼
┌──────────────┐    ┌───────────────┐    ┌───────────────┐
│     PHC      │───▶│  Sync Layer   │───▶│    Hospital   │
│              │    │               │    │               │
│ Create       │    │ Push / Pull   │    │ Receive       │
│ Referral     │    │ Synchronize   │    │ Review        │
└──────────────┘    └───────────────┘    └───────────────┘

                    INTERNET UNAVAILABLE
                           │
                           ▼

              ┌────────────────────────┐
              │ Local Device Storage   │
              │                        │
              │ Referral persists      │
              │ SyncQueue tracks work  │
              │ Retry when connected   │
              └────────────────────────┘

The core design principles are:

1. Offline First

The referral is persisted locally before relying on network synchronization.

2. Safe by Default

Authentication, authorization, facility isolation, and duplicate protection are built into the backend.

3. Human Verified

Patient identity matching provides supporting evidence rather than silently making a final identity decision.

🔄 Referral Lifecycle

RelyCare models the referral as a continuity workflow rather than a single API request.

Created
   ↓
Sent / Synced
   ↓
Received
   ↓
Patient Arrived
   ↓
Under Treatment
   ↓
Completed
🏥 Core Workflow
PHC Side

A PHC medical officer/staff member can:

Authenticate securely
Create a patient referral
Select the destination facility
Set referral urgency
Persist the referral locally
Queue it for synchronization
Synchronize it when connectivity is available
🏥 District Hospital Side

The receiving facility can:

Authenticate as hospital staff
View authorized incoming referrals
Retrieve referral information
Review patient information
Review identity-matching evidence
Continue the referral workflow
👤 Patient Identity Matching

One of the challenges in healthcare continuity is that the same patient may appear differently across records.

For example:
PHC Record
Rahul Sharmma
Age: 42

        ↓

RelyCare Matching

Name similarity: 92%
Age: Exact match

        ↓

Hospital Record
Rahul Sharma
Age: 42

RelyCare is designed to provide matching evidence for human verification rather than silently treating a similarity score as proof of identity.

This follows our principle:

Human verified, not blindly automated.

📴 Offline-First Architecture

The application is designed around local persistence and synchronization.

┌──────────────────────────────┐
│       Flutter Mobile App    │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│       Drift / SQLite         │
│                              │
│ Patients                     │
│ Referrals                    │
│ Referral Events              │
│ Sync Queue                   │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│        Sync Service          │
│                              │
│ Push → Pull                  │
│ Retry handling               │
│ Queue management             │
└──────────────┬───────────────┘
               │
               │ HTTPS / API
               ▼
┌──────────────────────────────┐
│          FastAPI             │
│                              │
│ Authentication               │
│ RBAC                         │
│ Facility authorization       │
│ Referral APIs                │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│         PostgreSQL           │
│                              │
│ Central referral data        │
│ Users & facilities           │
│ Persistent server records    │
└──────────────────────────────┘

🧱 Technology Stack
Mobile Application
Flutter
Dart
Drift
SQLite
Secure Storage
Backend
Python
FastAPI
SQLAlchemy
Alembic
JWT Authentication
bcrypt password hashing
Database
SQLite — local/offline persistence
PostgreSQL — central backend database
Development & Testing
Android device testing
Flutter integration testing
FastAPI backend testing
PostgreSQL verification
Git & GitHub
Code review workflow
🔐 Security & Authorization

RelyCare is designed with facility-level access control rather than treating every authenticated user as having access to all referrals.

Authentication

The backend uses:

JWT-based authentication
Password hashing with bcrypt
Secure token storage on the mobile client
Protected API endpoints
Authorization

Current backend roles:
PHC_STAFF
HOSPITAL_STAFF
A separate DOCTOR backend role is not required.

Doctors operating at PHCs use the PHC_STAFF role, while doctors/receiving staff at district hospitals use the HOSPITAL_STAFF role.

Facility Isolation

Example:
PHC Staff
    ↓
PHC-TEST referrals

Hospital Staff
    ↓
DH-TEST referrals
Cross-facility unauthorized operations are rejected by the backend.

Additional protections
Unauthorized requests → 401
Forbidden facility operations → 403
Duplicate referral identifiers → 409
Login rate limiting
Tampered/invalid JWT rejection
Existing referral data preserved during migrations

📱 Offline Data Model

The local database contains the main offline entities required for referral continuity.
Patients
   │
   ├── Referrals
   │       │
   │       └── Referral Events
   │
   └── Sync Queue
Local persistence enables:
Referral creation without network availability
Cold-start persistence
Pending synchronization
Retry handling
Idempotent synchronization behavior

The local database remains important even when PostgreSQL is available because the application is designed to operate under unreliable connectivity.

🔄 Synchronization

RelyCare uses a synchronization flow based on:

LOCAL DEVICE
     │
     │ PUSH
     ▼
FASTAPI
     │
     ▼
POSTGRESQL
     │
     │ PULL
     ▼
LOCAL DEVICE
📡 SMS Fallback

A compact SMS fallback architecture is part of the RelyCare design for environments where data connectivity is unavailable.

Example conceptual payload:
RelyCare Referral
REF: RC-2026-000142
PHC: PHC-MUM
PAT: Rahul S
AGE: 42
DST: DIST-HOSP-01
The SMS design intentionally minimizes the amount of information transmitted.

Current status

The current MVP contains the SMS service architecture/mock integration.

Real telecom/SMS provider integration is planned for the next deployment stage.

The prototype does not claim production telecom delivery.
🚀 Future Roadmap
Phase 1 — MVP
Offline-first mobile application
Local referral persistence
Synchronization
PHC and hospital workflows
Authentication and authorization
Identity matching workflow
Phase 2 — Pilot Deployment
Real PHC/hospital pilot
Production cloud deployment
Real SMS/telecom integration
Monitoring and observability
Operational feedback
Phase 3 — Scale
Multiple healthcare facilities
Multi-region deployment
Analytics
Referral performance monitoring
Facility-level dashboards
Production-grade notification infrastructure
🎯 Why RelyCare?

RelyCare is not trying to replace doctors.

It is not trying to replace hospitals.

It addresses the continuity layer between them.

The system focuses on a simple question:

When a patient leaves one healthcare facility, how do we make sure the referral continues with them?

RelyCare combines:
Offline-first storage

        +
Reliable synchronization
        +
Secure authorization
        +
Identity matching assistance
        +
Human verification
        =
Referral Continuity

🧠 Design Principles
Offline First

Connectivity should not determine whether a referral can be recorded.

Safe by Default

Sensitive healthcare workflows require authentication and authorization.

Human Verified

Automation should assist healthcare workers, not silently make high-impact identity decisions.

Minimum Necessary Data

Fallback communication should avoid unnecessarily transmitting sensitive clinical information.

Idempotent Synchronization

Retrying synchronization should not create duplicate referrals.
