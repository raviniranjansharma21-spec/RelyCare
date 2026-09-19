import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Reusable banner/app bar indicator showing whether the device is Online or Offline.
class ConnectivityIndicator extends StatelessWidget {
  final bool isOnline;
  final VoidCallback? onTap;

  const ConnectivityIndicator({
    super.key,
    required this.isOnline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? AppColors.onlineGreen : AppColors.offlineOrange;
    final text = isOnline ? 'Online' : 'Offline Mode (Local Queue Active)';
    final icon = isOnline ? Icons.wifi : Icons.wifi_off_rounded;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
