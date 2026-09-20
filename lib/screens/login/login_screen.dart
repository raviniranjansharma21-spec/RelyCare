import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../../app/routes.dart';

/// Prototype login and facility selection screen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _selectedRole = 'PHC Clinician';
  final _facilityIdController = TextEditingController(text: 'PHC-Rampur-104');

  @override
  void dispose() {
    _facilityIdController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // TODO (Frontend / Auth): Save selected facility profile and navigate to dashboard
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.medical_services_rounded, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text('Welcome to RelyCare', style: AppTextStyles.heading1),
              const SizedBox(height: 8),
              const Text(
                'Select your facility role to begin managing digital referrals.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 32),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(labelText: 'Staff Role'),
                items: const [
                  DropdownMenuItem(
                    value: 'PHC Clinician',
                    child: Text('PHC Doctor / Health Worker'),
                  ),
                  DropdownMenuItem(
                    value: 'District Hospital Staff',
                    child: Text('District Hospital Triage / Doctor'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _facilityIdController,
                decoration: const InputDecoration(
                  labelText: 'Facility Code / Name',
                  prefixIcon: Icon(Icons.apartment_rounded),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Enter RelayCare',
                onPressed: _handleLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
