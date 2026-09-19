import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/referral_status.dart';
import '../../widgets/primary_button.dart';
import '../../core/utils/validators.dart';

/// Screen for PHC clinicians to create and submit a new patient referral.
class CreateReferralScreen extends StatefulWidget {
  const CreateReferralScreen({super.key});

  @override
  State<CreateReferralScreen> createState() => _CreateReferralScreenState();
}

class _CreateReferralScreenState extends State<CreateReferralScreen> {
  final _formKey = GlobalKey<FormState>();

  // Patient Fields
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'Male';
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();

  // Referral Fields
  final _reasonController = TextEditingController();
  ReferralUrgency _urgency = ReferralUrgency.routine;
  String _destinationFacility = 'District Hospital - Rampur Central';
  final _notesController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitReferral() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // TODO (Frontend / Referral Provider):
    // 1. Build Patient and Referral entity objects
    // 2. Dispatch to ReferralProvider.createReferral()
    // 3. Show local save / sync toast notification
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Referral created and saved locally!'),
          backgroundColor: AppColors.onlineGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Referral (PHC)')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Patient Demographics', style: AppTextStyles.heading2),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Patient Full Name *'),
                validator: (v) => Validators.validateRequired(v, 'Patient Name'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Age *'),
                      validator: Validators.validateAge,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(value: 'Female', child: Text('Female')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Village / Ward / Location *'),
                validator: (v) => Validators.validateRequired(v, 'Location'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Contact Number (Optional)'),
                validator: Validators.validatePhoneNumber,
              ),
              const SizedBox(height: 24),

              const Text('Referral Details', style: AppTextStyles.heading2),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Referral / Chief Complaint *',
                ),
                validator: (v) => Validators.validateRequired(v, 'Referral Reason'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ReferralUrgency>(
                value: _urgency,
                decoration: const InputDecoration(labelText: 'Urgency Tier'),
                items: ReferralUrgency.values.map((u) {
                  return DropdownMenuItem(value: u, child: Text(u.displayName));
                }).toList(),
                onChanged: (v) => setState(() => _urgency = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _destinationFacility,
                decoration: const InputDecoration(labelText: 'Destination Facility'),
                items: const [
                  DropdownMenuItem(
                    value: 'District Hospital - Rampur Central',
                    child: Text('District Hospital - Rampur Central'),
                  ),
                  DropdownMenuItem(
                    value: 'Sub-District Hospital - North',
                    child: Text('Sub-District Hospital - North'),
                  ),
                ],
                onChanged: (v) => setState(() => _destinationFacility = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Clinical Notes Summary (Stored securely)',
                  hintText: 'Preliminary findings, vital signs, administered first aid...',
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Save & Dispatch Referral',
                isLoading: _isSubmitting,
                onPressed: _submitReferral,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
