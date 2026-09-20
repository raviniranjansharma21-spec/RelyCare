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
        App->>LocalDB: 5a. Check existing SMS delivery status in SQLite
        alt SMS Not Yet Sent
            App->>SMS: 5b. Send minimal SMS Fallback (Mock Gateway)
            SMS-->>App: 5c. Delivery Result (Success / Failure)
            App->>LocalDB: 5d. Record SMS_SENT or SMS_FAILED event (Sync status remains unaffected)
        end
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
3. **Connectivity Evaluation:** App checks network state via `ConnectivityService`.
4. **Online Path:** If online, sends JSON payload to backend and updates referral status to `SYNCED`.
5. **Offline Path & SMS Fallback:**
   - If offline, queues the record in local SQLite sync queue (`PENDING`).
   - Evaluates SMS fallback readiness: verifies local record existence and checks duplicate protection to prevent multiple SMS dispatches.
   - Generates compact, privacy-safe SMS payload (`REF`, `PHC`, `PAT`, `AGE`, `DST`).
   - Dispatches via `SmsService` (using `MockSmsService` gateway in Phase 6).
   - On success, records `SMS_SENT` event in SQLite. On failure, records `SMS_FAILED` event in SQLite.
   - **Crucial Separation:** SMS success or failure never modifies the HTTP `syncStatus` or deletes the local referral.
6. **Receiving Facility Intake:** District Hospital receives the referral notification (via backend sync when network is restored, or initial SMS triage).
7. **Identity Matching:** System runs matching algorithm against existing hospital records.
8. **Confidence Tiering:**
   - **High Confidence:** App presents candidate with match explanation.
   - **Low/Ambiguous Confidence:** App highlights discrepancies and requires explicit human clinician verification.
9. **Referral Acceptance & Treatment:** Hospital clinician admits patient, updates clinical progression, and completes referral.
10. **Two-way Sync:** Final status is synchronized back across the network when connection is active.

