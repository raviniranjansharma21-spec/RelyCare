import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// High-Fidelity Referral Details & Tracking Timeline Screen.
/// Displays referral triage status, patient details with urgency banner,
/// interactive vertical lifecycle timeline with GSM sync indicators, and status update actions.
class ReferralDetailsScreen extends StatefulWidget {
  const ReferralDetailsScreen({super.key});

  @override
  State<ReferralDetailsScreen> createState() => _ReferralDetailsScreenState();
}

class _ReferralDetailsScreenState extends State<ReferralDetailsScreen> {
  int _currentNavIndex = 1; // Highlight 'Incoming'

  void _handleUpdateStatus() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Status update dialog opening: Select next milestone (e.g. Patient Arrived)...',
        ),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= TOP CURVED HEADER =================
            _buildHeader(size),

            const SizedBox(height: 16),

            // ================= 1. CURRENT STATUS CARD =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildCurrentStatusCard(),
            ),

            const SizedBox(height: 14),

            // ================= 2. PATIENT INFORMATION CARD =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildPatientInfoCard(),
            ),

            const SizedBox(height: 14),

            // ================= 3. REFERRAL TIMELINE CARD =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildTimelineCard(),
            ),

            const SizedBox(height: 20),

            // ================= 4. UPDATE STATUS BUTTON =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _handleUpdateStatus,
                  icon: const Icon(
                    Icons.edit_note_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Update Status',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Top Curved Blue Header with Title and Referral ID
  Widget _buildHeader(Size size) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 26),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),

            // Top Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/hospital-dashboard');
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),

                // Center RelyCare Pill Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_box_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'RelyCare',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Notification Bell with Badge
                Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 22),

            // Title: Referral Details
            Text(
              'Referral Details',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),

            // Subtitle: ID
            Text(
              'ID: RC-2026-000142',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: 0.1,
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// 1. Current Status Card with Red Left Accent Strip
  Widget _buildCurrentStatusCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Red Left Accent Border Strip
              Container(width: 5, color: const Color(0xFFDC2626)),

              // Content Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Row: CURRENT STATUS + High Priority Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CURRENT STATUS',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFDC2626),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'High Priority',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Large Colored RECEIVED Pill Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF047857),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'RECEIVED',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Destination Row (with Expanded & overflow handling)
                      Row(
                        children: [
                          const Icon(
                            Icons.apartment_outlined,
                            size: 17,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF475569),
                                ),
                                children: const [
                                  TextSpan(text: 'Destination: '),
                                  TextSpan(
                                    text: 'District Hospital',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Assigned Unit Row (with Expanded & overflow handling)
                      Row(
                        children: [
                          const Icon(
                            Icons.medical_services_outlined,
                            size: 17,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF475569),
                                ),
                                children: const [
                                  TextSpan(text: 'Assigned Unit: '),
                                  TextSpan(
                                    text: 'Emergency Triage / Cardiology',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 2. Patient Information Card with Reason for Referral Banner
  Widget _buildPatientInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: PATIENT INFORMATION + ID Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PATIENT INFORMATION',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              const Icon(
                Icons.assignment_ind_outlined,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Patient Name
          Text(
            'Rahul Sharma',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),

          // Demographics Row
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF475569),
              ),
              children: const [
                TextSpan(text: 'Age: '),
                TextSpan(
                  text: '42',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextSpan(text: ' • Gender: '),
                TextSpan(
                  text: 'Male',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextSpan(text: ' • UHID: '),
                TextSpan(
                  text: 'DH-884920',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Reason for Referral Label
          Text(
            'Reason for Referral',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),

          // Soft Red Reason Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFECDD3), width: 1),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: Color(0xFFDC2626),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Chest pain + breathlessness',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Referred by Doctor Note
          Row(
            children: [
              const Icon(
                Icons.medical_information_outlined,
                size: 16,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: const Color(0xFF64748B),
                    ),
                    children: const [
                      TextSpan(text: 'Referred by: '),
                      TextSpan(
                        text: 'Dr. A. Kulkarni',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      TextSpan(text: ' (PHC Palghar)'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 3. Referral Timeline Card with Vertical Connected Progress Dots
  Widget _buildTimelineCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row: REFERRAL TIMELINE + Live GSM Sync Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REFERRAL TIMELINE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Live GSM Sync',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Timeline Node 1: Created
          _buildTimelineNode(
            title: 'Created',
            time: '10:30 AM',
            subtitle: 'Referral initiated by PHC Palghar',
            isCompleted: true,
            isLatest: false,
            lineColor: const Color(0xFF10B981),
            showBottomLine: true,
          ),

          // Timeline Node 2: Saved Offline
          _buildTimelineNode(
            title: 'Saved Offline',
            time: '10:31 AM',
            subtitle: 'Cached in local SQLite store',
            isCompleted: true,
            isLatest: false,
            lineColor: const Color(0xFF10B981),
            showBottomLine: true,
          ),

          // Timeline Node 3: SMS Fallback Sent
          _buildTimelineNode(
            title: 'SMS Fallback Sent',
            time: '10:45 AM',
            subtitle: 'Encrypted data packet dispatched via GSM',
            isCompleted: true,
            isLatest: false,
            lineColor: const Color(0xFF10B981),
            showBottomLine: true,
          ),

          // Timeline Node 4: Hospital Received (LATEST)
          _buildTimelineNode(
            title: 'Hospital Received',
            time: '11:10 AM',
            subtitle: 'District Hospital triage workstation confirmed',
            isCompleted: true,
            isLatest: true,
            lineColor: const Color(0xFFE2E8F0),
            showBottomLine: true,
          ),

          // Timeline Node 5: Patient Arrived (Pending)
          _buildTimelineNode(
            title: 'Patient Arrived',
            pendingText: '(Pending)',
            subtitle: 'Awaiting physical arrival at check-in',
            isCompleted: false,
            isLatest: false,
            lineColor: const Color(0xFFE2E8F0),
            showBottomLine: true,
          ),

          // Timeline Node 6: Under Treatment (Pending)
          _buildTimelineNode(
            title: 'Under Treatment',
            pendingText: '(Pending)',
            subtitle: 'Assigned to medical specialist',
            isCompleted: false,
            isLatest: false,
            lineColor: const Color(0xFFE2E8F0),
            showBottomLine: true,
          ),

          // Timeline Node 7: Completed (Pending)
          _buildTimelineNode(
            title: 'Completed',
            pendingText: '(Pending)',
            subtitle: 'Outcome report and PHC counter-referral',
            isCompleted: false,
            isLatest: false,
            lineColor: Colors.transparent,
            showBottomLine: false,
          ),
        ],
      ),
    );
  }

  /// Individual Vertical Timeline Item with Connected Indicator Lines
  Widget _buildTimelineNode({
    required String title,
    String? time,
    String? pendingText,
    required String subtitle,
    required bool isCompleted,
    required bool isLatest,
    required Color lineColor,
    required bool showBottomLine,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Dot & Vertical Line
          Column(
            children: [
              // Dot Indicator
              if (isCompleted)
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                )
              else
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

              // Connecting Line
              if (showBottomLine)
                Expanded(child: Container(width: 2, color: lineColor)),
            ],
          ),

          const SizedBox(width: 12),

          // Right Column: Content Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: isCompleted
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isCompleted
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ),
                            if (pendingText != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                pendingText,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                            if (isLatest) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'LATEST',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF15803D),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (time != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: isLatest
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isLatest
                                ? const Color(0xFF15803D)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Subtitle
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Custom Bottom Navigation Bar matching Hospital Dashboard (Highlight 'Incoming')
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(index: 0, icon: Icons.home_rounded, label: 'Home'),
              _buildNavItem(
                index: 1,
                icon: Icons.move_to_inbox_outlined,
                label: 'Incoming',
                showDot: true,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.sync_rounded,
                label: 'Sync',
                badgeCount: 4,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_outline_rounded,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    bool showDot = false,
    int? badgeCount,
  }) {
    final isSelected = _currentNavIndex == index;
    final activeColor = AppColors.primary;
    final inactiveColor = const Color(0xFF64748B);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _currentNavIndex = index;
        });
        if (index == 0) {
          context.go('/hospital-dashboard');
        }
      },
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? activeColor : inactiveColor,
                ),
                if (badgeCount != null)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 2),
            if (isSelected && showDot)
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
