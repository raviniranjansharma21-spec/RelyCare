import '../local_storage/local_storage_service.dart';
import '../api/api_service.dart';
import '../connectivity/connectivity_service.dart';
import '../../core/utils/logger.dart';

/// Service responsible for managing offline queue synchronization with the FastAPI backend.
class SyncService {
  final LocalStorageService _localStorage;
  final ApiService _apiService;
  final ConnectivityService _connectivityService;

  ApiService get apiService => _apiService;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  SyncService({
    required this._localStorage,
    required this._apiService,
    required this._connectivityService,
  });

  /// Triggers full synchronization of all pending offline records.
  Future<int> syncPendingReferrals() async {
    final isOnline = await _connectivityService.checkConnectivity();
    if (!isOnline) {
      AppLogger.warning('Cannot sync: Device is offline', 'SyncService');
      return 0;
    }

    if (_isSyncing) {
      AppLogger.info('Sync already in progress', 'SyncService');
      return 0;
    }

    _isSyncing = true;
    int syncedCount = 0;

    try {
      final pendingReferrals = await _localStorage.getPendingSyncReferrals();
      AppLogger.info('Found ${pendingReferrals.length} pending referrals to sync', 'SyncService');

      for (final _ in pendingReferrals) {
        // TODO (Sync Specialist): Call API to upload referral, then update local sync state
        // await _apiService.uploadReferral(referral);
        // await _localStorage.updateReferralSyncState(referral.id, SyncState.synced);
        syncedCount++;
      }
    } catch (e, stack) {
      AppLogger.error('Sync failed', e, stack, 'SyncService');
    } finally {
      _isSyncing = false;
    }

    return syncedCount;
  }

  // TODO: Add periodic background synchronization timer.
}
