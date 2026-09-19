import 'package:flutter/material.dart';
import '../models/referral_status.dart';
import '../core/theme/app_colors.dart';

/// Reusable chip displaying the current referral lifecycle status.
class ReferralStatusChip extends StatelessWidget {
  final ReferralStatus status;

  const ReferralStatusChip({
    super.key,
    required this.status,
  });

  Color _getStatusColor() {
    switch (status) {
      case ReferralStatus.created:
        return Colors.grey.shade700;
      case ReferralStatus.queued:
        return AppColors.offlineOrange;
      case ReferralStatus.synced:
      case ReferralStatus.sent:
        return AppColors.syncBlue;
      case ReferralStatus.received:
        return AppColors.primary;
      case ReferralStatus.patientArrived:
      case ReferralStatus.underTreatment:
        return Colors.indigo;
      case ReferralStatus.completed:
        return AppColors.onlineGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
