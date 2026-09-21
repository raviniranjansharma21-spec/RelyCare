import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

/// Screen displaying logged-in facility / staff profile and app configurations.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facility & Staff Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              final role = context.read<AuthProvider>().currentRole;
              if (role == UserRole.hospitalStaff) {
                context.go('/hospital-dashboard');
              } else if (role == UserRole.patient) {
                context.go('/user-tracking');
              } else {
                context.go('/phc-dashboard');
              }
            }
          },
        ),
      ),
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
                context.read<AuthProvider>().logout();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
