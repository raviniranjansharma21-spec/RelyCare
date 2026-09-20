# RelyCare - Implementation Roadmap & Checklist

This checklist tracks tasks across the 8 project phases.

---

## Implementation Roadmap

### Phase 1: Architecture & UI Scaffolding
- [x] Create directory tree and folder structure
- [x] Create documentation & architectural specifications
- [ ] Implement design system, colors, and typography in `lib/core/theme/`
- [ ] Setup app entry point, `RelyCareApp`, and route navigation
- [ ] Build basic static UI mockups for all 10 screens in `lib/screens/`
- [ ] Implement reusable widgets in `lib/widgets/`

### Phase 2: Domain Models & Local Persistence
- [ ] Complete serialization (`toMap`/`fromMap`/`toJson`/`fromJson`) in `lib/models/`
- [ ] Implement SQLite schema and CRUD operations in `LocalStorageService`
- [ ] Connect `PatientRepository` and `ReferralRepository` to local database
- [ ] Validate "Create Referral" form and save to local SQLite

### Phase 3: Connectivity & Offline Queue Engine
- [ ] Implement network status monitoring in `ConnectivityService`
- [ ] Implement offline mutation queue table in SQLite
- [ ] Create sync state transitions (`CREATED` → `QUEUED` → `SYNCED`)
- [ ] Build UI sync status indicator and offline banners

### Phase 7: FastAPI Backend Foundation & REST API
- [x] Create dedicated `backend/` directory with clean layered architecture
- [x] Implement FastAPI endpoints for referral ingestion (`POST /api/v1/referrals`), status updates (`PATCH /api/v1/referrals/{id}/status`), and retrieval (`GET /api/v1/referrals/{id}`)
- [x] Implement PostgreSQL database schema with SQLAlchemy `ReferralModel`
- [x] Implement Pydantic validation schemas (`ReferralCreate`, `ReferralResponse`, `ReferralStatusUpdate`)
- [x] Handle duplicate referrals with `409 Conflict`
- [x] Sanitize error handling to prevent credential leaks on 500 errors
- [x] Write backend unit/integration tests (`test_health.py`, `test_referrals.py`) passing with pytest


### Phase 5: Sync Failure & Retry Strategy
- [x] Implement exponential backoff & jitter calculation (`ExponentialBackoffCalculator`)
- [x] Implement retry attempt tracking and `nextRetryAt` scheduling in `SyncQueueDao`
- [x] Distinguish between transient errors (`SocketException`, `TimeoutException`) and permanent errors (4xx client errors)
- [x] Add automated scheduled retry loop for pending sync queue items
- [x] Provide manual retry trigger (`syncNow` / `retryFailed`)
- [x] Comprehensive unit & integration testing for sync failure and retry

### Phase 6: SMS Fallback for Offline Referrals
- [x] Define `SmsService` abstract interface and `SmsResult` result model
- [x] Implement `MockSmsService` gateway simulation with configurable failure hooks
- [x] Enforce Minimum-Data Principle with deterministic format (`REF`, `PHC`, `PAT`, `AGE`, `DST`)
- [x] Sanitize patient names (first name + initial) to prevent privacy leaks
- [x] Implement SMS fallback in `ReferralRepository` & `ReferralProvider`
- [x] Add duplicate protection in SQLite event log (`SMS_SENT`)
- [x] Support manual retry with `forceRetry` without affecting HTTP `syncStatus`
- [x] Unit test suite (`test/phase6_sms_fallback_test.dart`) verifying all fallback and isolation rules

### Phase 7: Identity Matching & Human Verification
- [ ] Implement fuzzy matching algorithms (Levenshtein / RapidFuzz) in `MatchingService`
- [ ] Build multi-factor confidence scoring (Name, Age, Gender, Village)
- [ ] Implement UI match comparison view with confidence badges
- [ ] Add explicit human verification dialog and confirmation flow

### Phase 8: Referral Tracking & Dashboard Polish
- [ ] Build timeline view in `ReferralDetailsScreen`
- [ ] Implement referral status transitions (`PATIENT_ARRIVED`, `UNDER_TREATMENT`, `COMPLETED`)
- [ ] Polish dashboard analytics metrics and filters
- [ ] Add demo synthetic data generator for testing

