import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';

/// Screen displaying offline queue status, network status, and sync triggers.
class SyncStatusScreen extends StatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  State<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends State<SyncStatusScreen> {
  bool _isOnline = false; // Simulation toggle for offline queue demonstration
  bool _isSyncing = false;
  int _pendingCount = 2;

  void _triggerSync() async {
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isSyncing = false;
        if (_isOnline) {
          _pendingCount = 0;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isOnline
                ? 'Sync completed successfully!'
                : 'Device is offline. Items remain safely queued.',
          ),
          backgroundColor: _isOnline ? AppColors.onlineGreen : AppColors.offlineOrange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync & Connectivity')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isOnline ? Icons.wifi : Icons.wifi_off_rounded,
                          size: 32,
                          color: _isOnline ? AppColors.onlineGreen : AppColors.offlineOrange,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isOnline ? 'Network Online' : 'Operating in Offline Mode',
                                style: AppTextStyles.heading3,
                              ),
                              Text(
                                _isOnline
                                    ? 'Connected to FastAPI backend'
                                    : 'Local database active. SMS fallback enabled.',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Simulate Online / Offline'),
                      subtitle: const Text('Demo toggle for hackathon presentation'),
                      value: _isOnline,
                      onChanged: (v) => setState(() => _isOnline = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pending Queue Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Offline Queue', style: AppTextStyles.heading3),
                    const SizedBox(height: 8),
                    Text(
                      '$_pendingCount referrals waiting for upload',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Sync Now',
                      icon: Icons.sync,
                      isLoading: _isSyncing,
                      onPressed: _triggerSync,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
