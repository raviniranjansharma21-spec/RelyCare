import '../local_storage/local_storage_service.dart';
import '../local_storage/app_database.dart';
import '../api/api_service.dart';
import '../connectivity/connectivity_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

/// Orchestration service responsible for processing the offline sync queue,
/// handling sync failures, and managing retries up to [maxRetries].
class SyncService {
  final LocalStorageService localStorage;
  final ApiService apiService;
  final ConnectivityService connectivityService;
  final int maxRetries;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  SyncService({
    required this.localStorage,
    required this.apiService,
    required this.connectivityService,
    this.maxRetries = AppConstants.maxSyncRetries,
  });

  /// Synchronizes all eligible sync queue items (PENDING or FAILED with retryCount < maxRetries).
  ///
  /// Flow:
  /// 1. Verifies connectivity is ONLINE. If OFFLINE, returns 0 without modifying queue or retry counts.
  /// 2. Ensures no concurrent sync execution via [_isSyncing] guard.
  /// 3. Reads eligible queue items in FIFO order.
  /// 4. Transitions each item to SYNCING before attempting API submission.
  /// 5. On API success: marks queue item SUCCESS and referral syncStatus to SYNCED.
  /// 6. On API failure: marks queue item FAILED, increments its individual retryCount, and updates lastAttempt.
  Future<int> syncPendingReferrals() async {
    final isOnline = await connectivityService.checkConnectivity();
    if (!isOnline) {
      AppLogger.warning('Cannot sync: Device is offline', 'SyncService');
      return 0;
    }

    if (_isSyncing) {
      AppLogger.info('Sync already in progress, skipping concurrent trigger', 'SyncService');
      return 0;
    }

    _isSyncing = true;
    try {
      final eligibleItems = await localStorage.getEligibleSyncItems(maxRetries);
      if (eligibleItems.isEmpty) {
        AppLogger.info('Sync queue is empty or all failed items reached max retries', 'SyncService');
        return 0;
      }

      return await _processQueueItems(eligibleItems);
    } catch (e, stack) {
      AppLogger.error('Unexpected error during sync pass', e, stack, 'SyncService');
      return 0;
    } finally {
      _isSyncing = false;
    }
  }

  /// Manually retries only failed queue items that have not exceeded [maxRetries].
  Future<int> retryFailedItems() async {
    final isOnline = await connectivityService.checkConnectivity();
    if (!isOnline) {
      AppLogger.warning('Cannot retry: Device is offline', 'SyncService');
      return 0;
    }

    if (_isSyncing) {
      AppLogger.info('Sync/Retry already in progress, skipping concurrent trigger', 'SyncService');
      return 0;
    }

    _isSyncing = true;
    try {
      final retryableItems = await localStorage.getRetryableFailedItems(maxRetries);
      if (retryableItems.isEmpty) {
        AppLogger.info('No retryable failed items found', 'SyncService');
        return 0;
      }

      return await _processQueueItems(retryableItems);
    } catch (e, stack) {
      AppLogger.error('Unexpected error during retry pass', e, stack, 'SyncService');
      return 0;
    } finally {
      _isSyncing = false;
    }
  }

  /// Internal sequential processor for a list of sync queue items.
  Future<int> _processQueueItems(List<SyncQueueData> queueItems) async {
    int syncedCount = 0;

    AppLogger.info(
      'Processing ${queueItems.length} items in sync queue (Max retries: $maxRetries)',
      'SyncService',
    );

    for (final queueItem in queueItems) {
      // Mark item as SYNCING before calling API
      await localStorage.markSyncing(queueItem.id);

      try {
        final referral = await localStorage.getDomainReferralById(queueItem.entityId);
        if (referral == null) {
          AppLogger.warning(
            'Referral ${queueItem.entityId} not found locally for queue item #${queueItem.id}',
            'SyncService',
          );
          await localStorage.markSyncFailed(queueItem.id, resetToPending: false);
          continue;
        }

        // Attempt API synchronization
        await apiService.createReferral(referral);

        // On success: mark queue item SUCCESS and local referral SYNCED
        await localStorage.markSyncSuccess(queueItem.id);
        await localStorage.updateReferralSyncStatus(referral.referralToken, 'SYNCED');

        syncedCount++;
        AppLogger.info(
          'Successfully synced referral ${referral.referralToken} (Queue #${queueItem.id})',
          'SyncService',
        );
      } catch (e, stack) {
        AppLogger.error(
          'Failed to sync queue item #${queueItem.id} (${queueItem.entityId}): $e',
          e,
          stack,
          'SyncService',
        );
        // On failure: mark FAILED and increment retryCount (without deleting data or marking referral synced)
        await localStorage.markSyncFailed(queueItem.id, resetToPending: false);
      }
    }

    return syncedCount;
  }
}
