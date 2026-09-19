import 'package:flutter/material.dart';
import '../../models/referral.dart';
import '../../models/patient.dart';
import '../../models/referral_status.dart';
import '../../widgets/referral_card.dart';
import '../../app/routes.dart';

/// Screen displaying the list of all local and synchronized referrals.
class ReferralsScreen extends StatefulWidget {
  const ReferralsScreen({super.key});

  @override
  State<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends State<ReferralsScreen> {
  // Demo mock list for prototype layout
  final List<Referral> _demoReferrals = [
    Referral(
      id: 'ref-001',
      referralToken: 'RC-A7X92',
      patientId: 'pat-101',
      patient: Patient(
        id: 'pat-101',
        fullName: 'Ramesh Kumar',
        age: 45,
        gender: 'Male',
        villageOrLocation: 'Sundarpur Village',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      sourceFacilityId: 'PHC-104',
      destinationFacilityId: 'DH-02',
      referralReason: 'Severe chest pain, suspected ACS, ECG changes observed',
      urgency: ReferralUrgency.emergency,
      status: ReferralStatus.queued,
      syncState: SyncState.pendingSync,
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    Referral(
      id: 'ref-002',
      referralToken: 'RC-B9K14',
      patientId: 'pat-102',
      patient: Patient(
        id: 'pat-102',
        fullName: 'Sunita Devi',
        age: 28,
        gender: 'Female',
        villageOrLocation: 'Kalyanpur',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      sourceFacilityId: 'PHC-104',
      destinationFacilityId: 'DH-02',
      referralReason: 'High risk pregnancy, severe pre-eclampsia signs',
      urgency: ReferralUrgency.urgent,
      status: ReferralStatus.synced,
      syncState: SyncState.synced,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referrals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              // TODO: Implement status filtering modal
            },
          ),
        ],
      ),
      body: _demoReferrals.isEmpty
          ? const Center(child: Text('No referrals found'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _demoReferrals.length,
              itemBuilder: (context, index) {
                final referral = _demoReferrals[index];
                return ReferralCard(
                  referral: referral,
                  onTap: () {
                    // Navigate to details
                    Navigator.pushNamed(
                      context,
                      AppRoutes.referralDetails,
                      arguments: referral,
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New Referral'),
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createReferral),
      ),
    );
  }
}
