# RelyCare - Folder & File Guide

A beginner-friendly guide to the structure of the RelayCare codebase.

---

## High-Level Folder Directory

| Directory | Purpose | Key Responsibilities |
|---|---|---|
| `lib/app/` | Application Configuration | App entry widgets, global routes, environment configs. |
| `lib/core/` | Core Utilities & Theme | Constants, color palettes, typography, helpers, error types. |
| `lib/models/` | Data Models | Domain entities (Patient, Referral, Facilities, Events). |
| `lib/screens/` | UI Screens | Full-screen UI pages (Dashboard, Create Referral, Matching). |
| `lib/widgets/` | Reusable UI Components | Common buttons, status chips, cards, indicators. |
| `lib/providers/` | State Management | ChangeNotifier classes holding UI state and logic. |
| `lib/repositories/` | Data Repositories | Data access orchestrators (Local DB vs API vs Sync Queue). |
| `lib/services/` | Technical Services | Low-level operations (SQLite, Connectivity, SMS, FastAPI, Matching). |

---

## Detailed File Breakdown

### 1. `lib/app/`
- **`app.dart`**: Root `MaterialApp` widget configuring global theme, title, and routes.
- **`routes.dart`**: Central navigation route names and route table.
- **`app_config.dart`**: Environment variables, mock toggle flags, backend host URLs.

### 2. `lib/core/`
- **`constants/app_constants.dart`**: General application strings, defaults, and timeouts.
- **`constants/api_constants.dart`**: FastAPI endpoints and base URLs.
- **`constants/storage_constants.dart`**: SQLite table names and local key-value keys.
- **`theme/app_theme.dart`**: Material 3 light/dark ThemeData definitions.
- **`theme/app_colors.dart`**: Color palette (primary teal/blue, urgency colors, status colors).
- **`theme/app_text_styles.dart`**: Standard text themes and typography.
- **`utils/validators.dart`**: Form input validators (phone, age, patient name, etc.).
- **`utils/date_utils.dart`**: Timestamp formatting and relative date helpers.
- **`utils/logger.dart`**: Safe logging utility for debug/release modes.
- **`errors/app_exceptions.dart`**: Custom typed exceptions (`NetworkException`, `StorageException`, etc.).

### 3. `lib/models/`
- **`patient.dart`**: Patient entity (name, age, gender, location, contact, emergency contact).
- **`referral.dart`**: Core referral record (token, patient ID, facilities, reason, urgency, status, syncState).
- **`referral_status.dart`**: Status enum (`CREATED`, `QUEUED`, `SYNCED`, `SENT`, `RECEIVED`, `PATIENT_ARRIVED`, `UNDER_TREATMENT`, `COMPLETED`).
- **`referral_event.dart`**: Audit trail record for referral timeline transitions.
- **`healthcare_facility.dart`**: Facility entity (PHC, District Hospital, Community Health Center).
- **`identity_match.dart`**: Match result model (candidate patient, similarity scores, confidence badge, verification status).

### 4. `lib/screens/`
- **`splash/splash_screen.dart`**: App startup screen, initialization, and auto-routing.
- **`onboarding/onboarding_screen.dart`**: Walkthrough explaining the offline referral workflow.
- **`login/login_screen.dart`**: Role/Facility selection and authentication prototype.
- **`dashboard/dashboard_screen.dart`**: Main overview showing active referrals, stats, connectivity state, and quick actions.
- **`create_referral/create_referral_screen.dart`**: Form for PHC clinicians to create a new referral.
- **`referrals/referrals_screen.dart`**: List and filter all local & synced referrals.
- **`referrals/referral_details_screen.dart`**: Detailed timeline and medical journey of a selected referral.
- **`identity_matching/identity_matching_screen.dart`**: Comparison UI for matching incoming referrals with existing hospital records.
- **`sync/sync_status_screen.dart`**: Offline queue status, manual sync triggers, and conflict history.
- **`profile/profile_screen.dart`**: Logged-in clinician/facility information and settings.

### 5. `lib/widgets/`
- **`referral_card.dart`**: Card widget for displaying referral summary in lists.
- **`referral_status_chip.dart`**: Colored badge representing current referral status.
- **`connectivity_indicator.dart`**: App bar / banner widget showing Online / Offline status.
- **`sync_status_indicator.dart`**: Icon / badge displaying sync status and pending count.
- **`confidence_badge.dart`**: Visual indicator for identity match confidence level.
- **`patient_info_card.dart`**: Compact patient demographic summary card.
- **`primary_button.dart`**: Standardized primary action button with loading states.

### 6. `lib/services/`
- **`local_storage/local_storage_service.dart`**: Interface and implementation for local persistence (SQLite / Drift).
- **`connectivity/connectivity_service.dart`**: Real-time network listener and connectivity checks.
- **`sync/sync_service.dart`**: Synchronization engine managing the offline outgoing/incoming queues.
- **`sms/sms_service.dart`**: SMS fallback formatting (minimal tokens only, NO plain clinical notes).
- **`matching/matching_service.dart`**: Client-side fuzzy matching helper and backend matcher connector.
- **`api/api_service.dart`**: HTTP client communicating with the FastAPI backend.
- **`security/security_service.dart`**: Security policies, anonymization, and local data protection helpers.

### 7. `lib/repositories/`
- **`referral_repository.dart`**: Manages CRUD for referrals, routing between local DB and API.
- **`patient_repository.dart`**: Manages patient records and local caching.
- **`sync_repository.dart`**: Manages queued mutations and synchronization status tracking.

### 8. `lib/providers/`
- **`referral_provider.dart`**: State for list of referrals, creation form state, and details.
- **`connectivity_provider.dart`**: State for current online/offline mode.
- **`sync_provider.dart`**: State for pending sync queue, sync progress, and errors.
- **`identity_matching_provider.dart`**: State for candidate matches, selected match, and human verification confirmation.
