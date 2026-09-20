// ignore_for_file: prefer_initializing_formals
import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/identity_match.dart';
import '../services/matching/matching_service.dart';

/// State management for patient identity matching and human verification.
class IdentityMatchingProvider extends ChangeNotifier {
  final MatchingService _matchingService;

  List<IdentityMatch> _candidateMatches = [];
  IdentityMatch? _selectedMatch;
  bool _isLoading = false;
  String? _errorMessage;

  IdentityMatchingProvider({required MatchingService matchingService})
      : _matchingService = matchingService;

  List<IdentityMatch> get candidateMatches => _candidateMatches;
  IdentityMatch? get selectedMatch => _selectedMatch;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Finds match candidates for an incoming patient.
  Future<void> findMatches(Patient incomingPatient, List<Patient> existingPatients) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final matches = <IdentityMatch>[];
      for (final candidate in existingPatients) {
        final match = await _matchingService.matchCandidate(
          incoming: incomingPatient,
          candidate: candidate,
        );
        matches.add(match);
      }

      // Sort descending by confidence score
      matches.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
      _candidateMatches = matches;
      if (_candidateMatches.isNotEmpty) {
        _selectedMatch = _candidateMatches.first;
      }
    } catch (e) {
      _errorMessage = 'Matching computation failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sets user-verified match state.
  void confirmHumanVerification(IdentityMatch match, String clinicianUserId) {
    // Mark as verified by human clinician
    final index = _candidateMatches.indexOf(match);
    if (index != -1) {
      _candidateMatches[index] = IdentityMatch(
        candidatePatient: match.candidatePatient,
        confidenceScore: match.confidenceScore,
        confidenceLevel: match.confidenceLevel,
        fieldMatchScores: match.fieldMatchScores,
        isHumanVerified: true,
        verifiedByUserId: clinicianUserId,
        verifiedAt: DateTime.now(),
      );
      _selectedMatch = _candidateMatches[index];
      notifyListeners();
    }
  }

  void selectCandidate(IdentityMatch match) {
    _selectedMatch = match;
    notifyListeners();
  }
}
