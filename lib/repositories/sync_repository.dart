// ignore_for_file: prefer_initializing_formals
import '../services/local_storage/local_storage_service.dart';
import '../services/sync/sync_service.dart';

/// Repository responsible for sync queue operations and sync history.
class SyncRepository {
  final LocalStorageService _localStorage;
  final SyncService _syncService;

  SyncRepository({
    required LocalStorageService localStorage,
    required SyncService syncService,
  })  : _localStorage = localStorage,
        _syncService = syncService;

  /// Gets the count of records currently waiting in the offline queue.
  Future<int> getPendingQueueCount() async {
    final pending = await _localStorage.getPendingSyncReferrals();
    return pending.length;
  }

  /// Triggers a manual sync pass.
  Future<int> triggerSync() async {
    return await _syncService.syncPendingReferrals();
  }

  // TODO: Add methods to inspect sync failures and conflict logs.
}
