import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/referral.dart';
import '../../models/referral_status.dart';
import '../../widgets/primary_button.dart';
import '../../core/utils/validators.dart';
import '../../app/app_dependencies.dart';

/// Screen for PHC clinicians to create and submit a new patient referral offline.
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
  final _sourceFacilityController = TextEditingController(text: 'PHC-Rampur-104');
  String _destinationFacility = 'District Hospital - Rampur Central';
  final _reasonController = TextEditingController();
  ReferralUrgency _urgency = ReferralUrgency.routine;
  final _notesController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _sourceFacilityController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitReferral() async {
    if (!_formKey.currentState!.validate()) return;

    // Prevent double submissions
    if (_isSubmitting) return;

    final provider = context.referralProvider;
    if (provider.isCreating) return;

    setState(() => _isSubmitting = true);

    final age = int.tryParse(_ageController.text.trim()) ?? 0;

    final createdReferral = await provider.createReferral(
      patientName: _nameController.text.trim(),
      patientAge: age,
      patientGender: _gender,
      patientPhone: _contactController.text.trim().isNotEmpty
          ? _contactController.text.trim()
          : null,
      patientLocation: _locationController.text.trim(),
      sourceFacility: _sourceFacilityController.text.trim(),
      destinationFacility: _destinationFacility,
      reason: _reasonController.text.trim(),
      clinicalNotes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (createdReferral != null) {
      _showCreationSuccessDialog(createdReferral);
    } else {
      final error = provider.errorMessage ?? 'Failed to create referral locally';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.urgencyHigh,
        ),
      );
    }
  }

  void _showCreationSuccessDialog(Referral referral) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: AppColors.onlineGreen, size: 28),
              SizedBox(width: 10),
              Text('Referral Saved Offline', style: AppTextStyles.heading2),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'The referral has been securely saved to local SQLite storage and queued for background sync.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Referral ID:', style: AppTextStyles.bodySmall),
                          Text(
                            referral.referralToken,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Patient:', style: AppTextStyles.bodySmall),
                          Text(
                            referral.patient?.fullName ?? _nameController.text,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Local Status:', style: AppTextStyles.bodySmall),
                          Text('CREATED (Saved Locally)', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Sync Queue:', style: AppTextStyles.bodySmall),
                          Text(
                            'PENDING (Waiting for network)',
                            style: TextStyle(
                              color: AppColors.offlineOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            PrimaryButton(
              label: 'Done & Return',
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                Navigator.pop(context); // Return from Create Referral screen
              },
            ),
          ],
        );
      },
    );
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
                      initialValue: _gender,
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
                controller: _sourceFacilityController,
                decoration: const InputDecoration(labelText: 'Source Facility *'),
                validator: (v) => Validators.validateRequired(v, 'Source Facility'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _destinationFacility,
                decoration: const InputDecoration(labelText: 'Destination Facility *'),
                items: const [
                  DropdownMenuItem(
                    value: 'District Hospital - Rampur Central',
                    child: Text('District Hospital - Rampur Central'),
                  ),
                  DropdownMenuItem(
                    value: 'Sub-District Hospital - North',
                    child: Text('Sub-District Hospital - North'),
                  ),
                  DropdownMenuItem(
                    value: 'Community Health Centre - East',
                    child: Text('Community Health Centre - East'),
                  ),
                ],
                onChanged: (v) => setState(() => _destinationFacility = v!),
              ),
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
                initialValue: _urgency,
                decoration: const InputDecoration(labelText: 'Urgency Tier'),
                items: ReferralUrgency.values.map((u) {
                  return DropdownMenuItem(value: u, child: Text(u.displayName));
                }).toList(),
                onChanged: (v) => setState(() => _urgency = v!),
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
