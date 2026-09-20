import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../app/routes.dart';

/// Screen displaying logged-in facility / staff profile and app configurations.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Facility & Staff Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text('Dr. Ananya Sharma', style: AppTextStyles.heading2),
            Text('Medical Officer • Rampur PHC', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 24),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.apartment, color: AppColors.primary),
                    title: const Text('Facility Code'),
                    subtitle: const Text('PHC-104'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: AppColors.primary),
                    title: const Text('District / Zone'),
                    subtitle: const Text('East District, Block B'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone_android, color: AppColors.primary),
                    title: const Text('SMS Fallback Number'),
                    subtitle: const Text('+91 9876543210'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ListTile(
              tileColor: Colors.red.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Switch Facility / Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
