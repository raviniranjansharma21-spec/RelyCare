# lib/models/

## Purpose
Defines the core data structures and domain models used throughout RelyCare.

## Files
- `patient.dart`: Basic patient demographic entity.
- `referral.dart`: Main referral record model containing tokens, facilities, reason, urgency, and sync metadata.
- `referral_status.dart`: Enum defining referral lifecycle stages (`CREATED`, `QUEUED`, `SYNCED`, `SENT`, `RECEIVED`, `PATIENT_ARRIVED`, `UNDER_TREATMENT`, `COMPLETED`).
- `referral_event.dart`: Audit log entries for status changes and transitions.
- `healthcare_facility.dart`: Details of Primary Health Centres and District Hospitals.
- `identity_match.dart`: Candidate match representation with confidence levels and verification flags.
