import '../models/referral.dart';
import '../models/referral_status.dart';
import '../services/local_storage/local_storage_service.dart';
import '../services/api/api_service.dart';
import '../services/connectivity/connectivity_service.dart';
import '../services/sms/sms_service.dart';
import '../core/utils/logger.dart';

/// Repository managing referral creation, updates, querying, and offline/online routing.
class ReferralRepository {
  final LocalStorageService _localStorage;
  final ApiService _apiService;
  final ConnectivityService _connectivityService;
  final SmsService _smsService;

  ReferralRepository({
    required LocalStorageService localStorage,
    required ApiService apiService,
    required ConnectivityService connectivityService,
    required SmsService smsService,
  })  : _localStorage = localStorage,
        _apiService = apiService,
        _connectivityService = connectivityService,
        _smsService = smsService;

  /// Creates a new referral adhering to the offline-first flow.
  Future<Referral> createReferral(Referral referral) async {
    // Step 1: Always save locally first (Safe by Default)
    await _localStorage.saveReferral(referral);
    AppLogger.info('Saved referral ${referral.referralToken} locally', 'ReferralRepository');

    // Step 2: Check internet connectivity
    final isOnline = await _connectivityService.checkConnectivity();

    if (isOnline) {
      try {
        // Step 3a: Online -> Post to FastAPI backend
        final syncedReferral = await _apiService.createReferral(referral);
        await _localStorage.updateReferralSyncState(referral.id, SyncState.synced);
        return syncedReferral;
      } catch (e) {
        AppLogger.warning('API sync failed, falling back to local queue', 'ReferralRepository');
        await _localStorage.updateReferralSyncState(referral.id, SyncState.pendingSync);
      }
    } else {
      // Step 3b: Offline -> Queue for later and trigger SMS fallback
      AppLogger.info('Offline: Queueing referral & sending SMS fallback', 'ReferralRepository');
      await _localStorage.updateReferralSyncState(referral.id, SyncState.pendingSync);
      
      // Send minimal privacy-safe SMS token
      // TODO: Provide recipient destination facility SMS number
      await _smsService.sendFallbackSms(
        recipientPhoneNumber: '+919876543210',
        referral: referral,
      );
    }

    return referral;
  }

  /// Retrieves all referrals (from local storage + remote sync).
  Future<List<Referral>> getAllReferrals() async {
    return await _localStorage.getAllReferrals();
  }

  /// Retrieves a single referral by ID.
  Future<Referral?> getReferralById(String id) async {
    return await _localStorage.getReferralById(id);
  }

  /// Updates status (e.g. PATIENT_ARRIVED, UNDER_TREATMENT, COMPLETED).
  Future<void> updateStatus(String referralId, ReferralStatus status) async {
    // TODO: Update local SQLite record and queue/send status update to backend.
  }
}
