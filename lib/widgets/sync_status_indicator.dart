import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Reusable indicator displaying offline sync status and pending queue count.
class SyncStatusIndicator extends StatelessWidget {
  final int pendingCount;
  final bool isSyncing;
  final VoidCallback? onSyncPressed;

  const SyncStatusIndicator({
    super.key,
    required this.pendingCount,
    this.isSyncing = false,
    this.onSyncPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isSyncing) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.sync_rounded),
          if (pendingCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.offlineOrange,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  pendingCount > 9 ? '9+' : '$pendingCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      tooltip: pendingCount > 0
          ? '$pendingCount pending items in offline queue'
          : 'All items synced',
      onPressed: onSyncPressed,
    );
  }
}
