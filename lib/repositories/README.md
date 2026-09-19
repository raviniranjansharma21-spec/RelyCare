# lib/repositories/

## Purpose
The data access layer. Repositories coordinate between local database services and backend API services, providing a clean domain data API to Providers.

## Files
- `referral_repository.dart`: Coordinates referral fetching, creation, status updates, and offline caching.
- `patient_repository.dart`: Manages patient demographic queries and local records.
- `sync_repository.dart`: Manages queued operations and synchronisation state records.
