import 'referral_status.dart';

/// Represents a state transition or audit event in a referral's timeline.
class ReferralEvent {
  final String id;
  final String referralId;
  final ReferralStatus status;
  final String description;
  final String updatedByUserId;
  final String facilityId;
  final DateTime timestamp;

  const ReferralEvent({
    required this.id,
    required this.referralId,
    required this.status,
    required this.description,
    required this.updatedByUserId,
    required this.facilityId,
    required this.timestamp,
  });

  // TODO: Add toMap() / fromMap() for local SQLite timeline storage.
}
