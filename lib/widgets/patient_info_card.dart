import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Reusable demographic card displaying patient details.
class PatientInfoCard extends StatelessWidget {
  final Patient patient;
  final Widget? trailing;

  const PatientInfoCard({
    super.key,
    required this.patient,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                patient.fullName.isNotEmpty ? patient.fullName[0].toUpperCase() : 'P',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient.fullName, style: AppTextStyles.heading3),
                  const SizedBox(height: 4),
                  Text(
                    '${patient.age} yrs • ${patient.gender} • ${patient.villageOrLocation}',
                    style: AppTextStyles.bodyMedium,
                  ),
                  if (patient.contactNumber != null && patient.contactNumber!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(patient.contactNumber!, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
