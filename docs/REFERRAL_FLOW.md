# RelyCare - Referral Lifecycle & End-to-End Flow

This document details the step-by-step lifecycle of a healthcare referral within RelyCare, spanning from the Primary Health Centre (PHC) to the District Hospital.

---

## Complete Referral Flowchart

```mermaid
sequenceDiagram
    autonumber
    actor Doctor as PHC Doctor / Nurse
    participant App as RelayCare App (PHC)
    participant LocalDB as Local SQLite
    participant SyncService as Sync & Queue Engine
    participant Backend as FastAPI Backend
    participant SMS as SMS Gateway
    participant HospitalApp as RelayCare App (Hospital)
    actor ReceivingStaff as District Hospital Staff

    Doctor->>App: 1. Create Referral (Patient Demographics, Reason, Urgency)
    App->>LocalDB: 2. Save Referral locally (Status: CREATED)
    App->>SyncService: 3. Trigger sync check
    alt Internet is Available
        SyncService->>Backend: 4a. Sync referral payload over HTTPS
        Backend-->>SyncService: Status: SYNCED
    else Internet is Offline
        SyncService->>LocalDB: 4b. Mark for Offline Queue (Status: QUEUED)
        SyncService->>SMS: 5. Send minimal SMS Fallback token (No sensitive clinical data)
    end

    Backend->>HospitalApp: 6. Push / Poll incoming referral
    HospitalApp->>HospitalApp: 7. Trigger Identity Matching (Fuzzy match on demographic fields)
    
    alt Confidence Score is High (e.g. >= 85%)
        HospitalApp->>ReceivingStaff: 8a. Suggest patient match with confirmation prompt
    else Confidence Score is Low / Ambiguous
        HospitalApp->>ReceivingStaff: 8b. Require mandatory Human Verification
    end

    ReceivingStaff->>HospitalApp: 9. Accept referral & bind patient
    ReceivingStaff->>HospitalApp: 10. Mark Patient Arrived
    ReceivingStaff->>HospitalApp: 11. Start Treatment (Status: UNDER_TREATMENT)
    ReceivingStaff->>HospitalApp: 12. Complete Referral (Status: COMPLETED)
    HospitalApp->>Backend: 13. Sync completion state back to PHC
```

---

## Detailed Step Description

1. **PHC Creation:** Clinician inputs basic patient demographic details, reason for referral, urgency tier, and destination facility.
2. **Local Persistence:** Data is committed to local SQLite storage first, ensuring zero data loss if the app closes or the device loses power.
3. **Connectivity Evaluation:** App checks network state.
4. **Online Path:** If online, sends JSON payload to FastAPI backend and updates status to `SYNCED`.
5. **Offline Path & SMS Fallback:** If offline, queues the record in local queue and triggers SMS fallback with a lightweight anonymized token (`RC-REF-XXXX`).
6. **Receiving Facility Intake:** District Hospital views incoming referrals in their dashboard.
7. **Identity Matching:** System runs matching algorithm (name fuzzy distance, age bounds, gender, village/location) against existing hospital records.
8. **Confidence Tiering:**
   - **High Confidence:** App presents candidate with match explanation.
   - **Low/Ambiguous Confidence:** App highlights discrepancies and requires explicit human clinician verification.
9. **Referral Acceptance & Treatment:** Hospital clinician admits patient, updates clinical progression, and completes referral.
10. **Two-way Sync:** Final status is synchronized back across the network when connection is active.
