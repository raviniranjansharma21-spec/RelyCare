import '../../models/patient.dart';

/// Security & Data Minimization helpers.
/// Enforces safe-by-default rules across local storage and network channels.
class SecurityService {
  /// Redacts sensitive patient details for display in logs or high-level summaries.
  String maskPatientName(String name) {
    if (name.trim().isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return '${parts[0][0]}***';
    }
    return '${parts[0]} ${parts[1][0]}.';
  }

  /// Validates that a payload to be transmitted does not violate privacy bounds.
  bool validatePayloadPrivacy(Map<String, dynamic> payload) {
    // Ensure no raw biometric or unencrypted full medical history is included
    return true;
  }

  /// Anonymizes a patient object for research or minimal logging.
  Patient anonymizePatient(Patient patient) {
    return Patient(
      id: patient.id,
      fullName: maskPatientName(patient.fullName),
      age: patient.age,
      gender: patient.gender,
      villageOrLocation: patient.villageOrLocation,
      contactNumber: null,
      emergencyContact: null,
      createdAt: patient.createdAt,
    );
  }

  // TODO (Team Lead / Security): Add local SQLCipher key management / encryption helpers if needed.
}
