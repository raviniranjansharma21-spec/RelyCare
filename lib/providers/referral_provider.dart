import 'package:flutter/material.dart';
import '../models/referral.dart';
import '../models/referral_status.dart';
import '../repositories/referral_repository.dart';
import '../services/local_storage/app_database.dart';
import '../services/sms/sms_service.dart';

/// State management for referral lists, detail views, offline creation, and SMS fallback.
class ReferralProvider extends ChangeNotifier {
  final ReferralRepository referralRepository;

  List<Referral> _referrals = [];
  bool _isLoading = false;
  bool _isCreating = false;
  bool _isSendingSms = false;
  String? _errorMessage;
  Referral? _selectedReferral;
  Referral? _lastCreatedReferral;

  ReferralProvider({required this.referralRepository});

  List<Referral> get referrals => _referrals;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  bool get isSendingSms => _isSendingSms;
  String? get errorMessage => _errorMessage;
  Referral? get selectedReferral => _selectedReferral;
  Referral? get lastCreatedReferral => _lastCreatedReferral;

  /// Loads all referrals from local SQLite storage.
  Future<void> loadReferrals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _referrals = await referralRepository.getAllReferrals();
    } catch (e) {
      _errorMessage = 'Failed to load referrals: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new referral offline with duplicate submission protection.
  Future<Referral?> createReferral({
    required String patientName,
    required int patientAge,
    required String patientGender,
    String? patientPhone,
    String? patientLocation,
    required String sourceFacility,
    required String destinationFacility,
    required String reason,
    String? clinicalNotes,
    String? customReferralId,
    String? createdByStaff,
  }) async {
    // Prevent duplicate simultaneous submissions
    if (_isCreating) {
      return null;
    }

    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newReferral = await referralRepository.createReferralOffline(
        patientName: patientName,
        patientAge: patientAge,
        patientGender: patientGender,
        patientPhone: patientPhone,
        patientLocation: patientLocation,
        sourceFacility: sourceFacility,
        destinationFacility: destinationFacility,
        reason: reason,
        clinicalNotes: clinicalNotes,
        customReferralId: customReferralId,
        createdByStaff: createdByStaff,
      );

      _referrals.insert(0, newReferral);
      _lastCreatedReferral = newReferral;
      _isCreating = false;
      notifyListeners();
      return newReferral;
    } catch (e) {
      _errorMessage = 'Failed to create referral: $e';
      _isCreating = false;
      notifyListeners();
      return null;
    }
  }

  /// Dispatches an SMS fallback message for a locally stored referral.
  Future<SmsResult?> sendSmsFallback(
    String referralToken, {
    required String recipientPhoneNumber,
    bool forceRetry = false,
  }) async {
    if (_isSendingSms) return null;

    _isSendingSms = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await referralRepository.sendSmsFallback(
        referralToken,
        recipientPhoneNumber: recipientPhoneNumber,
        forceRetry: forceRetry,
      );
      return result;
    } catch (e) {
      _errorMessage = 'SMS fallback failed: $e';
      return null;
    } finally {
      _isSendingSms = false;
      notifyListeners();
    }
  }

  /// Retrieves the SMS delivery status of a referral.
  Future<SmsDeliveryStatus> getSmsDeliveryStatus(String referralToken) async {
    return await referralRepository.getSmsStatus(referralToken);
  }

  /// Retrieves events timeline for a referral.
  Future<List<ReferralEventData>> getReferralEvents(String referralId) async {
    return await referralRepository.getReferralEvents(referralId);
  }

  /// Updates status of an existing referral.
  Future<void> updateReferralStatus(String id, ReferralStatus newStatus) async {
    try {
      await referralRepository.updateStatus(id, newStatus);
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
}
