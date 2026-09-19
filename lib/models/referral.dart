import 'referral_status.dart';
import 'patient.dart';
import 'healthcare_facility.dart';

/// Sync state indicator for local database records.
enum SyncState {
  pendingSync,
  synced,
  syncFailed,
}

/// Core domain model representing a healthcare referral.
class Referral {
  final String id;
  final String referralToken; // Short unique reference, e.g. "RC-A7X92"
  final String patientId;
  final Patient? patient; // Optional eagerly loaded patient demographic
  final String sourceFacilityId;
  final HealthcareFacility? sourceFacility;
  final String destinationFacilityId;
  final HealthcareFacility? destinationFacility;
  final String referralReason;
  final ReferralUrgency urgency;
  final String? clinicalNotesSummary;
  final ReferralStatus status;
  final SyncState syncState;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Referral({
    required this.id,
    required this.referralToken,
    required this.patientId,
    this.patient,
    required this.sourceFacilityId,
    this.sourceFacility,
    required this.destinationFacilityId,
    this.destinationFacility,
    required this.referralReason,
    required this.urgency,
    this.clinicalNotesSummary,
    required this.status,
    required this.syncState,
    required this.createdAt,
    required this.updatedAt,
  });

  // TODO: Add toMap() / fromMap() serialization for SQLite.
  // TODO: Add toJson() / fromJson() serialization for FastAPI.
  // TODO: Add copyWith() for updating referral status and syncState.
}
