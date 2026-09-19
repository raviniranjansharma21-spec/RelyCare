import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/patient.dart';
import '../../models/identity_match.dart';
import '../../widgets/confidence_badge.dart';
import '../../widgets/primary_button.dart';

/// Screen displaying incoming referral demographic matching against hospital records.
/// High confidence -> suggests match.
/// Low confidence -> enforces explicit human verification.
class IdentityMatchingScreen extends StatefulWidget {
  const IdentityMatchingScreen({super.key});

  @override
  State<IdentityMatchingScreen> createState() => _IdentityMatchingScreenState();
}

class _IdentityMatchingScreenState extends State<IdentityMatchingScreen> {
  // Demo Incoming Patient
  final Patient _incomingPatient = Patient(
    id: 'inc-01',
    fullName: 'Ramesh K',
    age: 45,
    gender: 'Male',
    villageOrLocation: 'Sundarpur',
    createdAt: DateTime.now(),
  );

  // Demo Existing Candidate in Hospital DB
  final IdentityMatch _demoMatch = IdentityMatch(
    candidatePatient: Patient(
      id: 'hosp-pat-982',
      fullName: 'Ramesh Kumar',
      age: 45,
      gender: 'Male',
      villageOrLocation: 'Sundarpur Village, Ward 4',
      contactNumber: '+91 9876543210',
      createdAt: DateTime(2025, 3, 10),
    ),
    confidenceScore: 0.91,
    confidenceLevel: MatchConfidence.high,
    fieldMatchScores: {
      'name': 0.88,
      'age': 1.0,
      'gender': 1.0,
      'location': 0.85,
    },
  );

  bool _isVerified = false;

  void _verifyMatch() {
    setState(() => _isVerified = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Identity match verified by clinician!'),
        backgroundColor: AppColors.onlineGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Identity Matching')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Match Evaluation', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            const Text(
              'Comparing incoming referral demographics with hospital master records to resolve patient identity without centralized IDs.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Confidence Badge
            ConfidenceBadge(
              score: _demoMatch.confidenceScore,
              confidenceLevel: _demoMatch.confidenceLevel,
            ),
            const SizedBox(height: 16),

            // Side-by-side or stacked comparison
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Comparison Summary', style: AppTextStyles.heading3),
                    const Divider(),
                    _buildComparisonRow(
                      'Field',
                      'Incoming Referral',
                      'Hospital Database Record',
                      isHeader: true,
                    ),
                    const Divider(),
                    _buildComparisonRow(
                      'Name',
                      _incomingPatient.fullName,
                      _demoMatch.candidatePatient.fullName,
                      matchRatio: _demoMatch.fieldMatchScores['name'],
                    ),
                    _buildComparisonRow(
                      'Age',
                      '${_incomingPatient.age} yrs',
                      '${_demoMatch.candidatePatient.age} yrs',
                      matchRatio: _demoMatch.fieldMatchScores['age'],
                    ),
                    _buildComparisonRow(
                      'Gender',
                      _incomingPatient.gender,
                      _demoMatch.candidatePatient.gender,
                      matchRatio: _demoMatch.fieldMatchScores['gender'],
                    ),
                    _buildComparisonRow(
                      'Location',
                      _incomingPatient.villageOrLocation,
                      _demoMatch.candidatePatient.villageOrLocation,
                      matchRatio: _demoMatch.fieldMatchScores['location'],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Verification Action
            if (!_isVerified) ...[
              PrimaryButton(
                label: 'Confirm Match (Human Verified)',
                icon: Icons.verified_user_rounded,
                backgroundColor: AppColors.primary,
                onPressed: _verifyMatch,
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () {
                  // TODO: Reject match and create new patient profile
                },
                child: const Text('Reject Match & Register as New Patient'),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.onlineGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.onlineGreen),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle, color: AppColors.onlineGreen),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Verified & Bound to Record: DH-PAT-982',
                        style: TextStyle(
                          color: AppColors.onlineGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(
    String label,
    String incoming,
    String existing, {
    bool isHeader = false,
    double? matchRatio,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: isHeader
                  ? const TextStyle(fontWeight: FontWeight.bold)
                  : AppTextStyles.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              incoming,
              style: isHeader
                  ? const TextStyle(fontWeight: FontWeight.bold)
                  : AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              existing,
              style: isHeader
                  ? const TextStyle(fontWeight: FontWeight.bold)
                  : AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
