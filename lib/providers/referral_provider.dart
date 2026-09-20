import 'package:flutter/material.dart';
import '../models/referral.dart';
import '../models/referral_status.dart';
import '../repositories/referral_repository.dart';

/// State management for referral lists, detail views, and referral creation.
class ReferralProvider extends ChangeNotifier {
  final ReferralRepository _referralRepository;

  List<Referral> _referrals = [];
  bool _isLoading = false;
  String? _errorMessage;
  Referral? _selectedReferral;

  ReferralProvider({required this._referralRepository});

  List<Referral> get referrals => _referrals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Referral? get selectedReferral => _selectedReferral;

  /// Loads all referrals.
  Future<void> loadReferrals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _referrals = await _referralRepository.getAllReferrals();
    } catch (e) {
      _errorMessage = 'Failed to load referrals: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new referral.
  Future<bool> createReferral(Referral referral) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newReferral = await _referralRepository.createReferral(referral);
      _referrals.insert(0, newReferral);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create referral: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates status of an existing referral.
  Future<void> updateReferralStatus(String id, ReferralStatus newStatus) async {
    try {
      await _referralRepository.updateStatus(id, newStatus);
      await loadReferrals();
    } catch (e) {
      _errorMessage = 'Failed to update status: $e';
      notifyListeners();
    }
  }

  void selectReferral(Referral referral) {
    _selectedReferral = referral;
    notifyListeners();
  }

  // TODO: Add search and status filtering helpers.
}
