import 'package:flutter/material.dart';
import '../../models/referral.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../widgets/referral_status_chip.dart';
import '../../widgets/patient_info_card.dart';
import '../../widgets/primary_button.dart';

/// Screen displaying the complete journey, medical notes, and status transitions of a referral.
class ReferralDetailsScreen extends StatelessWidget {
  final Referral? referral;

  const ReferralDetailsScreen({super.key, this.referral});

  @override
  Widget build(BuildContext context) {
    // In real flow, obtain referral from ModalRoute arguments if null
    final currentReferral = referral ??
        (ModalRoute.of(context)?.settings.arguments as Referral?);

    if (currentReferral == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Referral Details')),
        body: const Center(child: Text('Referral details not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Referral: ${currentReferral.referralToken}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Token Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status Timeline', style: AppTextStyles.heading2),
                ReferralStatusChip(status: currentReferral.status),
              ],
            ),
            const SizedBox(height: 16),

            // Patient Demographic Card
            if (currentReferral.patient != null) ...[
              const Text('Patient Information', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              PatientInfoCard(patient: currentReferral.patient!),
              const SizedBox(height: 16),
            ],

            // Clinical Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Referral Reason & Notes', style: AppTextStyles.heading3),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(currentReferral.referralReason, style: AppTextStyles.bodyLarge),
                    const SizedBox(height: 12),
                    Text(
                      'Created: ${AppDateUtils.formatDateTime(currentReferral.createdAt)}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Status Update Actions for Receiving Hospital
            const Text('Update Referral Journey', style: AppTextStyles.heading2),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Mark Patient Arrived',
              icon: Icons.how_to_reg_rounded,
              backgroundColor: AppColors.secondary,
              onPressed: () {
                // TODO: Dispatch update to ReferralProvider
              },
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Mark Treatment Completed',
              icon: Icons.check_circle_outline,
              backgroundColor: AppColors.onlineGreen,
              onPressed: () {
                // TODO: Dispatch complete to ReferralProvider
              },
            ),
          ],
        ),
      ),
    );
  }
}
