import '../../models/patient.dart';
import '../../models/identity_match.dart';
import '../../core/constants/app_constants.dart';

/// Patient identity matching service.
/// Compares incoming referral demographic information with existing patient records.
class MatchingService {
  /// Computes a fuzzy similarity score between an incoming referral patient profile
  /// and an existing candidate patient.
  Future<IdentityMatch> matchCandidate({
    required Patient incoming,
    required Patient candidate,
  }) async {
    // 1. Name Similarity (Placeholder ratio calculation)
    final double nameScore = _calculateStringSimilarity(
      incoming.fullName.toLowerCase(),
      candidate.fullName.toLowerCase(),
    );

    // 2. Age Match (Exact match = 1.0, difference penalty)
    final int ageDiff = (incoming.age - candidate.age).abs();
    final double ageScore = ageDiff == 0
        ? 1.0
        : ageDiff <= 2
            ? 0.8
            : ageDiff <= 5
                ? 0.5
                : 0.0;

    // 3. Gender Match
    final double genderScore =
        incoming.gender.toLowerCase() == candidate.gender.toLowerCase() ? 1.0 : 0.0;

    // 4. Location / Village Similarity
    final double locationScore = _calculateStringSimilarity(
      incoming.villageOrLocation.toLowerCase(),
      candidate.villageOrLocation.toLowerCase(),
    );

    // Weighted Overall Score
    // Weights: Name (40%), Location (25%), Age (20%), Gender (15%)
    final double overallScore =
        (nameScore * 0.40) + (locationScore * 0.25) + (ageScore * 0.20) + (genderScore * 0.15);

    // Confidence Level Categorization
    final MatchConfidence confidenceLevel;
    if (overallScore >= AppConstants.highConfidenceThreshold) {
      confidenceLevel = MatchConfidence.high;
    } else if (overallScore >= AppConstants.mediumConfidenceThreshold) {
      confidenceLevel = MatchConfidence.medium;
    } else {
      confidenceLevel = MatchConfidence.low;
    }

    return IdentityMatch(
      candidatePatient: candidate,
      confidenceScore: overallScore,
      confidenceLevel: confidenceLevel,
      fieldMatchScores: {
        'name': nameScore,
        'age': ageScore,
        'gender': genderScore,
        'location': locationScore,
      },
    );
  }

  /// Simple character-based similarity helper (Placeholder for Levenshtein / RapidFuzz).
  double _calculateStringSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    
    // Quick token containment check
    if (s1.contains(s2) || s2.contains(s1)) return 0.85;

    // TODO (AI/ML Specialist): Connect to backend RapidFuzz service or implement Levenshtein distance algorithm.
    return 0.5;
  }
}
