/// Status lifecycle of a medical referral in RelayCare.
enum ReferralStatus {
  created,
  queued,
  synced,
  sent,
  received,
  patientArrived,
  underTreatment,
  completed,
}

/// Extension helper to get human-readable labels and string serialization.
extension ReferralStatusExtension on ReferralStatus {
  String get displayName {
    switch (this) {
      case ReferralStatus.created:
        return 'Created';
      case ReferralStatus.queued:
        return 'Queued (Offline)';
      case ReferralStatus.synced:
        return 'Synced';
      case ReferralStatus.sent:
        return 'Sent';
      case ReferralStatus.received:
        return 'Received';
      case ReferralStatus.patientArrived:
        return 'Patient Arrived';
      case ReferralStatus.underTreatment:
        return 'Under Treatment';
      case ReferralStatus.completed:
        return 'Completed';
    }
  }

  String get code {
    switch (this) {
      case ReferralStatus.created:
        return 'CREATED';
      case ReferralStatus.queued:
        return 'QUEUED';
      case ReferralStatus.synced:
        return 'SYNCED';
      case ReferralStatus.sent:
        return 'SENT';
      case ReferralStatus.received:
        return 'RECEIVED';
      case ReferralStatus.patientArrived:
        return 'PATIENT_ARRIVED';
      case ReferralStatus.underTreatment:
        return 'UNDER_TREATMENT';
      case ReferralStatus.completed:
        return 'COMPLETED';
    }
  }

  static ReferralStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CREATED':
        return ReferralStatus.created;
      case 'QUEUED':
        return ReferralStatus.queued;
      case 'SYNCED':
        return ReferralStatus.synced;
      case 'SENT':
        return ReferralStatus.sent;
      case 'RECEIVED':
        return ReferralStatus.received;
      case 'PATIENT_ARRIVED':
        return ReferralStatus.patientArrived;
      case 'UNDER_TREATMENT':
        return ReferralStatus.underTreatment;
      case 'COMPLETED':
        return ReferralStatus.completed;
      default:
        return ReferralStatus.created;
    }
  }
}

/// Urgency tier of a referral.
enum ReferralUrgency {
  routine,
  urgent,
  emergency,
}

extension ReferralUrgencyExtension on ReferralUrgency {
  String get displayName {
    switch (this) {
      case ReferralUrgency.routine:
        return 'Routine';
      case ReferralUrgency.urgent:
        return 'Urgent';
      case ReferralUrgency.emergency:
        return 'Emergency';
    }
  }
}
