import '../services/local_storage/local_storage_service.dart';
import '../services/sync/sync_service.dart';

/// Repository responsible for sync queue operations, retry triggers, and queue metrics.
class SyncRepository {
  final LocalStorageService localStorage;
  final SyncService syncService;

  SyncRepository({
    required this.localStorage,
    required this.syncService,
  });

  /// Gets the count of records currently waiting in the offline queue with status PENDING.
  Future<int> getPendingQueueCount() async {
    final pending = await localStorage.getPendingSyncItems();
    return pending.length;
  }

  /// Gets the count of records in the offline queue with status FAILED.
  Future<int> getFailedQueueCount() async {
    final failed = await localStorage.getFailedSyncItems();
    return failed.length;
  }

  /// Triggers a synchronization pass for eligible pending/failed queue items.
  Future<int> triggerSync() async {
    return await syncService.syncPendingReferrals();
  }

  /// Triggers a retry pass specifically for retryable failed queue items.
  Future<int> retryFailed() async {
    return await syncService.retryFailedItems();
  }
}
