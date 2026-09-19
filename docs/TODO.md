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

### Phase 4: Backend Integration & FastAPI
- [ ] Implement FastAPI endpoints for referral ingestion and status polling
- [ ] Setup PostgreSQL database schema on backend
- [ ] Implement `ApiService` HTTP REST client calls
- [ ] Connect `SyncService` to upload queued referrals when online

### Phase 5: SMS Fallback Prototype
- [ ] Implement minimal token encoder/decoder in `SmsService`
- [ ] Add SMS transmission simulation/gateway hook
- [ ] Validate that zero plain clinical text is included in SMS payloads

### Phase 6: Identity Matching & Human Verification
- [ ] Implement fuzzy matching algorithms (Levenshtein / RapidFuzz) in `MatchingService`
- [ ] Build multi-factor confidence scoring (Name, Age, Gender, Village)
- [ ] Implement UI match comparison view with confidence badges
- [ ] Add explicit human verification dialog and confirmation flow

### Phase 7: Referral Tracking & Dashboard Polish
- [ ] Build timeline view in `ReferralDetailsScreen`
- [ ] Implement referral status transitions (`PATIENT_ARRIVED`, `UNDER_TREATMENT`, `COMPLETED`)
- [ ] Polish dashboard analytics metrics and filters
- [ ] Add demo synthetic data generator for testing

### Phase 8: Security, Testing & Demo Readiness
- [ ] Audit local data storage for privacy compliance
- [ ] Run end-to-end simulation (Offline referral creation → SMS fallback → Online sync → Matching → Acceptance)
- [ ] Final UI/UX polish for hackathon presentation
