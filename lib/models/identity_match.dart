import 'patient.dart';

/// Confidence tier for patient matching.
enum MatchConfidence {
  high, // Suggested match with strong certainty (>= 85%)
  medium, // Moderate match (60-84%), requires clinician review
  low, // Weak/Ambiguous match (< 60%), strictly requires human verification
}

/// Represents the result of matching an incoming referral demographic against existing hospital records.
class IdentityMatch {
  final Patient candidatePatient;
  final double confidenceScore; // Value between 0.0 and 1.0
  final MatchConfidence confidenceLevel;
  final Map<String, double> fieldMatchScores; // e.g. {"name": 0.92, "age": 1.0, "location": 0.8}
  final bool isHumanVerified;
  final String? verifiedByUserId;
  final DateTime? verifiedAt;

  const IdentityMatch({
    required this.candidatePatient,
    required this.confidenceScore,
    required this.confidenceLevel,
    required this.fieldMatchScores,
    this.isHumanVerified = false,
    this.verifiedByUserId,
    this.verifiedAt,
  });

  // TODO: Add helper methods to format match score as percentage string.
  // TODO: Add copyWith() for recording human verification decisions.
}
