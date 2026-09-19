# lib/screens/

## Purpose
Contains all full-page UI screens of the application. 

Screens are responsible strictly for user interface rendering and capturing interactions. They must delegate all business logic and data manipulation to `Providers` and `Repositories`.

## Subdirectories & Screens
- `splash/`: Initial boot screen and authentication check.
- `onboarding/`: Educational introduction to RelyCare's offline referral system.
- `login/`: Role and facility sign-in prototype.
- `dashboard/`: Main overview displaying stats, active referrals, and sync state.
- `create_referral/`: Form for clinicians to initiate a new referral.
- `referrals/`: Referral list view (`referrals_screen.dart`) and detailed timeline view (`referral_details_screen.dart`).
- `identity_matching/`: Patient identity comparison and verification interface.
- `sync/`: Offline queue monitor, sync status, and manual trigger controls.
- `profile/`: Facility and clinician settings page.
