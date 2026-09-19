import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/connectivity_indicator.dart';
import '../../widgets/sync_status_indicator.dart';
import '../../widgets/primary_button.dart';
import '../../app/routes.dart';

/// Main dashboard displaying active referrals, sync status, and quick actions.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Prototype placeholders
  final bool _isOnline = true;
  final int _pendingSyncCount = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RelyCare Dashboard'),
        actions: [
          SyncStatusIndicator(
            pendingCount: _pendingSyncCount,
            onSyncPressed: () {
              Navigator.pushNamed(context, AppRoutes.syncStatus);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connectivity Banner
            ConnectivityIndicator(
              isOnline: _isOnline,
              onTap: () => Navigator.pushNamed(context, AppRoutes.syncStatus),
            ),
            const SizedBox(height: 16),

            // Facility Quick Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.local_hospital),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Rampur Primary Health Centre', style: AppTextStyles.heading3),
                          Text('Facility Code: PHC-104 • District: East', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Metrics Overview
            Row(
              children: [
                _buildStatCard('Active Referrals', '12', AppColors.primary),
                const SizedBox(width: 12),
                _buildStatCard('Pending Sync', '$_pendingSyncCount', AppColors.offlineOrange),
                const SizedBox(width: 12),
                _buildStatCard('Completed', '28', AppColors.onlineGreen),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text('Quick Actions', style: AppTextStyles.heading2),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Create New Referral (PHC)',
              icon: Icons.add_circle_outline,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.createReferral),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: AppColors.primary),
              ),
              icon: const Icon(Icons.list_alt_rounded, color: AppColors.primary),
              label: const Text('View All Referrals', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.referrals),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: AppColors.secondary),
              ),
              icon: const Icon(Icons.fingerprint_rounded, color: AppColors.secondary),
              label: const Text('Patient Identity Matching', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.identityMatching),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
