import 'package:flutter/material.dart';
import '../models/referral.dart';
import '../models/referral_status.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/date_utils.dart';
import 'referral_status_chip.dart';

/// Summary card for displaying a referral item in list views.
class ReferralCard extends StatelessWidget {
  final Referral referral;
  final VoidCallback? onTap;

  const ReferralCard({
    super.key,
    required this.referral,
    this.onTap,
  });

  Color _getUrgencyColor(ReferralUrgency urgency) {
    switch (urgency) {
      case ReferralUrgency.routine:
        return AppColors.urgencyLow;
      case ReferralUrgency.urgent:
        return AppColors.urgencyMedium;
      case ReferralUrgency.emergency:
        return AppColors.urgencyEmergency;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      referral.referralToken,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  ReferralStatusChip(status: referral.status),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                referral.patient?.fullName ?? 'Patient: ${referral.patientId}',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 4),
              Text(
                'Reason: ${referral.referralReason}',
                style: AppTextStyles.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getUrgencyColor(referral.urgency),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        referral.urgency.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getUrgencyColor(referral.urgency),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    AppDateUtils.formatTimeAgo(referral.createdAt),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
