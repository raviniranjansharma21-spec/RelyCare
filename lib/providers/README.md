# lib/providers/

## Purpose
State management layer. Providers hold UI state, handle business actions initiated by screens, and notify listeners when data changes.

## Files
- `referral_provider.dart`: Holds referral list state, creation form state, active filters, and detail views.
- `connectivity_provider.dart`: Tracks online vs offline state in real-time.
- `sync_provider.dart`: Manages sync progress, pending queue counts, and retry actions.
- `identity_matching_provider.dart`: Manages candidate match lists, selected matches, and human verification confirmation.
