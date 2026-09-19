# lib/services/

## Purpose
Contains low-level technical services and infrastructure implementations. Services are purely operational and must not contain any UI code.

## Subdirectories & Files
- `local_storage/local_storage_service.dart`: SQLite / Drift local persistence engine.
- `connectivity/connectivity_service.dart`: Network status detection and stream listener.
- `sync/sync_service.dart`: Offline queue orchestrator and sync dispatcher.
- `sms/sms_service.dart`: Minimal SMS fallback encoder/gateway abstraction.
- `matching/matching_service.dart`: Fuzzy matching algorithms and scoring engine.
- `api/api_service.dart`: REST client talking to the FastAPI backend.
- `security/security_service.dart`: Data minimization, sanitization, and local security helpers.
