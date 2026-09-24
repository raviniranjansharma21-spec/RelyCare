# RelyCare - System Architecture

## Overview

RelayCare is an offline-first digital referral tracking system designed for low-connectivity healthcare environments. This document outlines the architectural patterns and layered separation of concerns used across the codebase.

---

## Architectural Pattern: Layered Clean Architecture

RelayCare uses a layered architecture to keep UI, state management, business logic, data access, and infrastructure separate and decoupled.

```mermaid
graph TD
    Screen["Screens (UI Layer)<br/>lib/screens/ & lib/widgets/"]
    Provider["Providers (State Management)<br/>lib/providers/"]
    Repository["Repositories (Data Access Layer)<br/>lib/repositories/"]
    Service["Services (Infrastructure / Tech Ops)<br/>lib/services/"]
    DataSource["Data Sources<br/>SQLite Local DB / FastAPI Backend / SMS Gateway"]

    Screen -->|User Actions & UI State| Provider
    Provider -->|Calls Business Operations| Repository
    Repository -->|Decides Local vs Remote| Service
    Service -->|Executes Tech Operations| DataSource
```

### Flow Breakdown

1. **Screens & Widgets (`lib/screens/`, `lib/widgets/`)**
   - Present UI components to the user.
   - Listen to state changes from Providers.
   - Dispatch user actions to Providers.
   - Contain **no** direct database or network calls.

2. **Providers (`lib/providers/`)**
   - Manage application state and UI view states (using `ChangeNotifier`).
   - Coordinate actions with Repositories.
   - Expose clean state objects and status flags (loading, success, error) to the UI.

3. **Repositories (`lib/repositories/`)**
   - Act as the single source of truth for domain data.
   - Decide whether to fetch/write to the local database, network API, or sync queue.
   - Abstract away storage mechanics from state management.

4. **Services (`lib/services/`)**
   - Perform technical and hardware/network operations (e.g., SQLite operations, HTTP requests, SMS formatting & mock delivery, identity matching algorithms, network connectivity monitoring).
   - `SmsService` / `MockSmsService`: Implements pluggable SMS fallback abstraction. Formats compact, privacy-safe payloads and provides mock telecom dispatch for zero-connectivity scenarios without touching UI or backend REST logic.
   - Contain **no** UI-specific code.

---

## SMS Fallback Architecture (Phase 6)

```mermaid
graph TD
    ReferralProvider["ReferralProvider<br/>(State Management)"]
    ReferralRepository["ReferralRepository<br/>(Business Logic & Validation)"]
    LocalStorageService["LocalStorageService<br/>(Drift / SQLite DB)"]
    SmsService["SmsService Abstraction<br/>(lib/services/sms/sms_service.dart)"]
    MockSmsGateway["MockSmsService Gateway<br/>(Simulated Telecom Transport)"]

    ReferralProvider -->|sendSmsFallback| ReferralRepository
    ReferralRepository -->|1. Confirm Local Existence| LocalStorageService
    ReferralRepository -->|2. Check Duplicate SMS State| LocalStorageService
    ReferralRepository -->|3. Generate Privacy Payload & Send| SmsService
    SmsService -->|4. Simulated Dispatch| MockSmsGateway
    ReferralRepository -->|5. Record SMS_SENT / SMS_FAILED Event| LocalStorageService
```

### Core SMS Principles:
1. **Separation of Channels:** SMS delivery is an out-of-band notification fallback. Successful or failed SMS delivery never modifies the HTTP `syncStatus` of a referral (`PENDING`, `SYNCED`, `FAILED`).
2. **Duplicate Protection:** Prevents duplicate successful SMS sends for the same referral unless explicitly forced via manual retry (`forceRetry: true`).
3. **Pluggable Abstraction:** All dispatch logic goes through abstract `SmsService`, allowing production telecom adapters (e.g., Twilio, AWS SNS, GSM modem) to be swapped in without modifying repositories or providers.
4. **Resilient Local Persistence:** SMS failure never rolls back or deletes the underlying SQLite referral record.

---

## Backend & Centralized Storage Architecture (Phase 7)

```mermaid
graph LR
    subgraph ClientDevice ["Client Device (PHC / Clinic)"]
        FlutterApp["Flutter Mobile / Web"]
        DriftDB[("Local SQLite (Drift)<br/>'Local persistence for offline operation'")]
        SyncQueue["Local Sync Queue (Bounded Retry)"]
        FlutterApp --> DriftDB
        DriftDB --> SyncQueue
    end

    subgraph ServerInfra ["Centralized Server Infrastructure"]
        FastAPIServer["FastAPI REST Backend<br/>'API layer between Flutter & PostgreSQL'"]
        PostgresDB[("Central PostgreSQL DB<br/>'Centralized server-side persistence'")]
        FastAPIServer --> PostgresDB
    end

    SyncQueue -->|HTTPS REST Sync<br/>POST /api/v1/referrals| FastAPIServer
```

### Dual-Database Model Rationale
- **SQLite (Drift):** *"Local persistence for offline-first operation."* Guarantees zero latency and instantaneous local storage even in disconnected rural clinics.
- **FastAPI:** *"API layer between Flutter clients and PostgreSQL."* Provides asynchronous REST endpoints with Pydantic payload validation, duplicate detection, and sanitized error handling.
- **PostgreSQL:** *"Centralized server-side persistence after synchronization."* Stores the authoritative state across the entire referral network.

---

## Why This Architecture?

1. **Separation of Concerns:** Each teammate can work on a distinct layer (e.g., UI, Database, API, Matching, SMS) without stepping on each other's toes.
2. **Offline-First Readiness:** The repository layer seamlessly hides whether data came from SQLite or FastAPI backend.
3. **Safe by Default:** Clinical data flow and SMS payload restrictions are strictly enforced at the service and repository boundaries.
4. **Beginner-Friendly & Testable:** Clear boundaries make it straightforward to unit test services/repositories and mock dependencies.


