import 'package:flutter/material.dart';
import '../repositories/sync_repository.dart';

/// State management for synchronization progress and offline pending queue.
class SyncProvider extends ChangeNotifier {
  final SyncRepository _syncRepository;

  int _pendingCount = 0;
  bool _isSyncing = false;
  String? _lastSyncTime;
  String? _syncError;

  SyncProvider({required SyncRepository syncRepository}) : _syncRepository = syncRepository;

  int get pendingCount => _pendingCount;
  bool get isSyncing => _isSyncing;
  String? get lastSyncTime => _lastSyncTime;
  String? get syncError => _syncError;

  /// Refreshes the count of items in the offline queue.
  Future<void> refreshPendingCount() async {
    try {
      _pendingCount = await _syncRepository.getPendingQueueCount();
      notifyListeners();
    } catch (_) {}
  }

  /// Triggers a manual sync pass.
  Future<void> triggerSync() async {
    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      final count = await _syncRepository.triggerSync();
      _pendingCount = await _syncRepository.getPendingQueueCount();
      _lastSyncTime = DateTime.now().toIso8601String();
      _syncError = null;
      debugPrint('Successfully synced $count items');
    } catch (e) {
      _syncError = 'Sync failed: $e';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // TODO: Add automatic trigger on connectivity resumption.
}
