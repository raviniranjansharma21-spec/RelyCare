import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// High-Fidelity PHC Dashboard Screen for RelyCare.
/// Matches the exact design specifications: Curved Blue Header,
/// Pill Online Badge, 3 Stats Cards, "+ Create Referral" Action Button,
/// Left-Accented Referral Cards, and Custom Bottom Navigation Bar.
class PHCDashboardScreen extends StatefulWidget {
  const PHCDashboardScreen({super.key});

  @override
  State<PHCDashboardScreen> createState() => _PHCDashboardScreenState();
}

class _PHCDashboardScreenState extends State<PHCDashboardScreen> {
  int _currentNavIndex = 0;
  bool _isOnline = true;

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
            // ================= TOP CURVED HEADER + BADGE =================
            _buildHeader(size),

            const SizedBox(height: 28),

            // ================= 3 STATS CARDS ROW =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.description_outlined,
                      iconColor: const Color(0xFF0284C7),
                      iconBgColor: const Color(0xFFE0F2FE),
                      value: '12',
                      label: 'Total...',
                      valueColor: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.sync_rounded,
                      iconColor: const Color(0xFF2563EB),
                      iconBgColor: const Color(0xFFEFF6FF),
                      value: '4',
                      label: 'Pending Sync',
                      valueColor: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: const Color(0xFF16A34A),
                      iconBgColor: const Color(0xFFF0FDF4),
                      value: '7',
                      label: 'Completed',
                      valueColor: const Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= CREATE REFERRAL BUTTON =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Create Referral flow opening...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 22, color: Colors.white),
                  label: Text(
                    'Create Referral',
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

            // ================= RECENT REFERRALS SECTION HEADER =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Referrals',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Navigating to All Referrals...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Text(
                      'View all',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ================= RECENT REFERRALS LIST =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildReferralCard(
                    name: 'Rahul Sharma',
                    facility: 'District Hospital',
                    time: 'Today, 10:30 AM',
                    status: 'SENT',
                    statusBgColor: const Color(0xFFEEF2FF),
                    statusTextColor: const Color(0xFF4F46E5),
                    accentBorderColor: const Color(0xFF3B82F6),
                  ),
                  const SizedBox(height: 12),
                  _buildReferralCard(
                    name: 'Sunita Devi',
                    facility: 'Civil Hospital',
                    time: 'Yesterday, 4:15 PM',
                    status: 'PENDING',
                    statusBgColor: const Color(0xFFF1F5F9),
                    statusTextColor: const Color(0xFF475569),
                    accentBorderColor: null,
                  ),
                  const SizedBox(height: 12),
                  _buildReferralCard(
                    name: 'Amit Patel',
                    facility: 'General Hospital',
                    time: '24 Oct, 11:00 AM',
                    status: 'COMPLETED',
                    statusBgColor: const Color(0xFFF0FDF4),
                    statusTextColor: const Color(0xFF16A34A),
                    accentBorderColor: const Color(0xFF16A34A),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Curved Blue Header with Brand, Notification Bell, Doctor Greeting, and Floating Status Pill
  Widget _buildHeader(Size size) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Blue Header Container
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),

                // Top Row: RelyCare Logo & Name + Notification Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const _HeaderHeartbeatIcon(),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'RelyCare',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),

                    // Notification Bell with Red Dot
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No new notifications.'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
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

                const SizedBox(height: 20),

                // Greeting: Good Morning, Dr. Sharma
                Text(
                  'Good Morning, Dr. Sharma',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),

                // Location: PHC Mumbai
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'PHC Mumbai',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),

        // Overlapping Pill Connectivity Badge
        Positioned(
          bottom: -16,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isOnline = !_isOnline;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isOnline ? 'Switched to Online mode.' : 'Switched to Offline mode.'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isOnline ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _isOnline ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isOnline ? 'Online' : 'Offline',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _isOnline ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Individual Stat Card Widget
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: valueColor,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Individual Referral Card with optional left accent border strip
  Widget _buildReferralCard({
    required String name,
    required String facility,
    required String time,
    required String status,
    required Color statusBgColor,
    required Color statusTextColor,
    Color? accentBorderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Optional Left Colored Accent Strip
              if (accentBorderColor != null)
                Container(
                  width: 5,
                  color: accentBorderColor,
                ),

              // Content Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top Row: Patient Name + Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: statusTextColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Facility Destination + Time
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 15,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            facility,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Text(
                              '•',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          Text(
                            time,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF64748B),
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

  /// Custom Bottom Navigation Bar matching the 4 tabs and highlight dot
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
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Home',
                showDot: true,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.folder_outlined,
                label: 'Referrals',
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

/// Header Heartbeat Wave custom painter for top-left app icon
class _HeaderHeartbeatIcon extends StatelessWidget {
  const _HeaderHeartbeatIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 14),
      painter: _HeaderHeartbeatPainter(),
    );
  }
}

class _HeaderHeartbeatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(0, h * 0.5);
    path.lineTo(w * 0.28, h * 0.5);
    path.lineTo(w * 0.42, h * 0.1);
    path.lineTo(w * 0.58, h * 0.9);
    path.lineTo(w * 0.72, h * 0.35);
    path.lineTo(w * 0.82, h * 0.5);
    path.lineTo(w, h * 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
