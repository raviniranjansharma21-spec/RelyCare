# RelyCare - Team Workflow & Role Mapping

This document outlines how different team members can collaborate effectively across the codebase during the hackathon.

---

## Role Assignment Map

| Role | Primary Directory Responsibilities | Key Tasks & Focus |
|---|---|---|
| **Team Lead / Product + Cybersecurity** | `lib/app/`<br/>`lib/core/errors/`<br/>`lib/services/security/`<br/>`docs/` | • App architecture oversight<br/>• Local security and data minimization review<br/>• Integration and final verification<br/>• Demo coordination |
| **Frontend Developer** | `lib/screens/`<br/>`lib/widgets/`<br/>`lib/core/theme/` | • Build polished UI screens<br/>• Implement responsive widgets<br/>• Hook UI inputs to Providers<br/>• Create smooth animations and feedback states |
| **Backend Developer** | `lib/services/api/`<br/>`lib/repositories/`<br/>`FastAPI Server (external)` | • Implement FastAPI REST endpoints<br/>• Implement `ApiService` HTTP calls<br/>• Setup PostgreSQL schema<br/>• Ensure backend response formats match Dart models |
| **Database / Offline Specialist** | `lib/models/`<br/>`lib/services/local_storage/`<br/>`lib/repositories/` | • Design local SQLite / Drift database schema<br/>• Implement `LocalStorageService`<br/>• Handle local CRUD and indexing<br/>• Ensure data persistence across app restarts |
| **AI/ML / Identity Matching Specialist** | `lib/services/matching/`<br/>`lib/providers/identity_matching_provider.dart`<br/>`lib/screens/identity_matching/` | • Implement similarity scoring (name, age, gender, location)<br/>• Integrate backend RapidFuzz service<br/>• Set confidence threshold logic<br/>• Implement human verification workflow |
| **Sync / Connectivity & SMS Specialist** | `lib/services/connectivity/`<br/>`lib/services/sync/`<br/>`lib/services/sms/`<br/>`lib/providers/sync_provider.dart` | • Network availability listener<br/>• Offline mutation queue management<br/>• Conflict resolution & sync triggers<br/>• SMS fallback token encoding/decoding |

---

## Collaboration Guidelines

1. **Contract First:** Agree on models in `lib/models/` before implementing screens and services.
2. **Mocking First:** Use mock data inside repositories while backend/database modules are being built.
3. **No Direct Service Calls in UI:** Screens must only communicate with `Providers` or `Repositories`.
4. **Clean Git Branching:** Each role should work on their respective folders on dedicated feature branches (e.g., `feature/ui-screens`, `feature/offline-sync`, `feature/matching-service`).
