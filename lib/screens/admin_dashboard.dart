import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets/ygca_drawer.dart';
import 'widgets/ygca_bottom_nav.dart';
import '../theme/theme_controller.dart';

import 'student_list_screen.dart';
import 'performance_report_screen.dart';
import 'notification_screen.dart';
import 'reports_dashboard_screen.dart';
import 'attendance_module_screen.dart';
import 'fee_module_screen.dart';
import 'coach_module_screen.dart';
import 'schedule_module_screen.dart';
import 'coach_salary_analytics_screen.dart';
import 'communication_center_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF250000);
  static const Color gold = Color(0xFFD4AF37);

  static const String logoAsset = 'assets/images/ygca_logo.jpg';

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _open(Widget screen) {
    _scaffoldKey.currentState?.closeDrawer();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Color _bg(bool isDark) {
    return isDark ? const Color(0xFF070707) : const Color(0xFFFAFAFA);
  }

  Color _card(bool isDark) {
    return isDark ? const Color(0xFF111111) : Colors.white;
  }

  Color _primaryText(bool isDark) {
    return isDark ? Colors.white : const Color(0xFF111827);
  }

  Color _secondaryText(bool isDark) {
    return isDark ? Colors.white60 : const Color(0xFF64748B);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: _bg(isDark),
          drawer: YgcaDrawer(
            role: 'Admin',
            navItems: [
              YgcaNavItem(
                icon: Icons.home_rounded,
                label: 'Dashboard',
                onTap: () => _scaffoldKey.currentState?.closeDrawer(),
              ),
              YgcaNavItem(
                icon: Icons.sports_rounded,
                label: 'Coach Module',
                onTap: () => _open(CoachModuleScreen()),
              ),
              YgcaNavItem(
                icon: Icons.payments_rounded,
                label: 'Fee Module',
                onTap: () => _open(FeeModuleScreen()),
              ),
              YgcaNavItem(
                icon: Icons.calendar_month_rounded,
                label: 'Schedule Module',
                onTap: () => _open(const ScheduleModuleScreen()),
              ),
              YgcaNavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Performance Reports',
                onTap: () => _open(const PerformanceReportScreen()),
              ),
              YgcaNavItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Coach Salary Analytics',
                onTap: () => _open(const CoachSalaryAnalyticsScreen()),
              ),
              YgcaNavItem(
                icon: Icons.notifications_rounded,
                label: 'Notifications',
                onTap: () => _open(const NotificationScreen()),
              ),
              YgcaNavItem(
                icon: Icons.campaign_rounded,
                label: 'Communication Center',
                onTap: () => _open(const CommunicationCenterScreen()),
              ),
            ],
            onLogout: _logout,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                children: [
                  _topBar(isDark),
                  _heroCard(isDark),
                  const SizedBox(height: 20),

                  _sectionTitle(
                    title: "ACADEMY OVERVIEW",
                    isDark: isDark,
                    showViewAll: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.25,
                      children: [
                        _overviewCard(
                          isDark: isDark,
                          icon: Icons.groups_rounded,
                          title: "Total Students",
                          value: "248",
                          subtitle: "Registered players",
                          color: red,
                        ),
                        _overviewCard(
                          isDark: isDark,
                          icon: Icons.verified_rounded,
                          title: "Attendance",
                          value: "75%",
                          subtitle: "Today average",
                          color: Colors.green,
                        ),
                        _overviewCard(
                          isDark: isDark,
                          icon: Icons.receipt_long_rounded,
                          title: "Pending Fees",
                          value: "₹2.45L",
                          subtitle: "28 students",
                          color: Colors.orange,
                        ),
                        _overviewCard(
                          isDark: isDark,
                          icon: Icons.calendar_month_rounded,
                          title: "Sessions",
                          value: "6",
                          subtitle: "This week",
                          color: Colors.purpleAccent,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),
                  _sectionTitle(
                    title: "QUICK ACTIONS",
                    isDark: isDark,
                    showViewAll: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.82,
                      children: [
                        _quickActionCard(
                          isDark: isDark,
                          icon: Icons.person_add_alt_1_rounded,
                          title: "Student\nApproval",
                          color: Colors.green,
                          onTap: () => _open(const StudentListScreen()),
                        ),
                        _quickActionCard(
                          isDark: isDark,
                          icon: Icons.sports_rounded,
                          title: "Coach\nCenter",
                          color: Colors.redAccent,
                          onTap: () => _open(CoachModuleScreen()),
                        ),
                        _quickActionCard(
                          isDark: isDark,
                          icon: Icons.fact_check_rounded,
                          title: "Mark\nAttendance",
                          color: Colors.blue,
                          onTap: () => _open(const AttendanceModuleScreen()),
                        ),
                        _quickActionCard(
                          isDark: isDark,
                          icon: Icons.account_balance_wallet_rounded,
                          title: "Fees\n& Dues",
                          color: Colors.orange,
                          onTap: () => _open(FeeModuleScreen()),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
          bottomNavigationBar: YgcaBottomNav(
            currentIndex: 0,
            items: [
              YgcaBottomNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                onTap: () {},
              ),
              YgcaBottomNavItem(
                icon: Icons.people_rounded,
                label: 'Students',
                onTap: () => _open(const StudentListScreen()),
              ),
              YgcaBottomNavItem(
                icon: Icons.fact_check_rounded,
                label: 'Attendance',
                onTap: () => _open(const AttendanceModuleScreen()),
              ),
              YgcaBottomNavItem(
                icon: Icons.analytics_rounded,
                label: 'Reports',
                onTap: () => _open(const ReportsDashboardScreen()),
              ),
              YgcaBottomNavItem(
                icon: Icons.more_horiz_rounded,
                label: 'More',
                onTap: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _topBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Row(
        children: [
          _circleButton(
            isDark: isDark,
            icon: Icons.menu_rounded,
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: 14),
          Image.asset(
            logoAsset,
            width: 58,
            height: 58,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "YGCA",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Admin Control Center",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _circleButton(
                isDark: isDark,
                icon: Icons.notifications_none_rounded,
                onTap: () => _open(const NotificationScreen()),
              ),
              Positioned(
                right: 3,
                top: 2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          _circleButton(
            isDark: isDark,
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            onTap: ThemeController.toggleTheme,
          ),
          const SizedBox(width: 8),
          _circleButton(
            isDark: isDark,
            icon: Icons.logout_rounded,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111111) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: red.withOpacity(isDark ? 0.34 : 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? red.withOpacity(0.13)
                  : Colors.black.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : maroon,
          size: 25,
        ),
      ),
    );
  }

  Widget _heroCard(bool isDark) {
    return Container(
      height: 285,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF090909) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: red.withOpacity(isDark ? 0.60 : 0.75),
          width: 1.15,
        ),
        boxShadow: [
          BoxShadow(
            color: red.withOpacity(isDark ? 0.22 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.78 : 0.16,
              child: Image.asset(
                'assets/images/home_hero_bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Colors.black.withOpacity(0.96),
                          Colors.black.withOpacity(0.82),
                          red.withOpacity(0.30),
                        ]
                      : [
                          Colors.white.withOpacity(0.98),
                          Colors.white.withOpacity(0.90),
                          red.withOpacity(0.06),
                        ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),

          Positioned(
            right: 0,
            top: 20,
            bottom: 0,
            child: Opacity(
              opacity: isDark ? 0.38 : 0.12,
              child: Icon(
                Icons.sports_cricket_rounded,
                size: 205,
                color: red,
              ),
            ),
          ),

          Positioned.fill(
            child: CustomPaint(
              painter: _HeroTechBorderPainter(
                color: red.withOpacity(isDark ? 0.95 : 0.70),
              ),
            ),
          ),

          Positioned(
            left: 20,
            top: 57,
            child: SizedBox(
              width: 138,
              height: 138,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 138,
                    height: 138,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: red.withOpacity(0.38),
                        width: 1,
                      ),
                    ),
                  ),
                  Container(
                    width: 118,
                    height: 118,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: red.withOpacity(0.34),
                        width: 1,
                      ),
                    ),
                  ),
                  Container(
                    width: 98,
                    height: 98,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: red.withOpacity(0.65),
                        width: 1.4,
                      ),
                    ),
                  ),
                  Image.asset(
                    logoAsset,
                    width: 98,
                    height: 98,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 170,
            top: 58,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "GOOD MORNING,",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? gold : red,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "ADMIN",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 42,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "CONTROL DASHBOARD",
                    style: TextStyle(
                      color: red,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 62,
                  height: 3,
                  color: isDark ? gold : red,
                ),
                const SizedBox(height: 16),
                Text(
                  "Manage students, coaches,\nattendance and academy growth.",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF374151),
                    fontSize: 13.5,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 170,
            right: 22,
            bottom: 36,
            child: Row(
              children: [
                Expanded(
                  child: _heroChip(
                    isDark: isDark,
                    icon: Icons.groups_rounded,
                    text: "4 Roles",
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _heroChip(
                    isDark: isDark,
                    icon: Icons.grid_view_rounded,
                    text: "10 Modules",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip({
    required bool isDark,
    required IconData icon,
    required String text,
  }) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white70,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: red.withOpacity(isDark ? 0.55 : 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: red.withOpacity(0.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: red, size: 20),
          const SizedBox(width: 9),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    required bool isDark,
    required bool showViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? gold : const Color(0xFF111827),
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: red.withOpacity(isDark ? 0.58 : 0.55),
            ),
          ),
          if (showViewAll) ...[
            const SizedBox(width: 10),
            Text(
              "View all",
              style: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: red,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }

  Widget _overviewCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF121212),
                  const Color(0xFF171717),
                  color.withOpacity(0.12),
                ]
              : [
                  Colors.white,
                  Colors.white,
                  color.withOpacity(0.04),
                ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? red.withOpacity(0.32) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark ? color.withOpacity(0.08) : Colors.black.withOpacity(0.05),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(isDark ? 0.15 : 0.10),
              border: Border.all(color: color.withOpacity(0.35)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontSize: 25,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
        decoration: BoxDecoration(
          color: _card(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? red.withOpacity(0.30) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isDark ? red.withOpacity(0.08) : Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 35),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _primaryText(isDark),
                fontSize: 12.5,
                height: 1.25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroTechBorderPainter extends CustomPainter {
  final Color color;

  _HeroTechBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const corner = 34.0;
    const gap = 18.0;

    // Top-left corner
    canvas.drawLine(const Offset(22, 22), const Offset(78, 22), paint);
    canvas.drawLine(const Offset(22, 22), const Offset(22, 78), paint);
    canvas.drawLine(const Offset(35, 35), const Offset(78, 35), paint);
    canvas.drawLine(const Offset(35, 35), const Offset(35, 78), paint);
    canvas.drawCircle(const Offset(88, 22), 3, dotPaint);

    // Top-right corner
    canvas.drawLine(Offset(size.width - 22, 22), Offset(size.width - 78, 22), paint);
    canvas.drawLine(Offset(size.width - 22, 22), Offset(size.width - 22, 78), paint);
    canvas.drawLine(Offset(size.width - 35, 35), Offset(size.width - 78, 35), paint);
    canvas.drawLine(Offset(size.width - 35, 35), Offset(size.width - 35, 78), paint);
    canvas.drawCircle(Offset(size.width - 88, 22), 3, dotPaint);

    // Bottom-left corner
    canvas.drawLine(Offset(22, size.height - 22), Offset(78, size.height - 22), paint);
    canvas.drawLine(Offset(22, size.height - 22), Offset(22, size.height - 78), paint);
    canvas.drawLine(Offset(35, size.height - 35), Offset(78, size.height - 35), paint);
    canvas.drawLine(Offset(35, size.height - 35), Offset(35, size.height - 78), paint);
    canvas.drawCircle(Offset(88, size.height - 22), 3, dotPaint);

    // Bottom-right corner
    canvas.drawLine(
      Offset(size.width - 22, size.height - 22),
      Offset(size.width - 78, size.height - 22),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - 22, size.height - 22),
      Offset(size.width - 22, size.height - 78),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - 35, size.height - 35),
      Offset(size.width - 78, size.height - 35),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - 35, size.height - 35),
      Offset(size.width - 35, size.height - 78),
      paint,
    );
    canvas.drawCircle(Offset(size.width - 88, size.height - 22), 3, dotPaint);

    // Soft outer border
    final borderPaint = Paint()
      ..color = color.withOpacity(0.22)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(gap, gap, size.width - gap * 2, size.height - gap * 2),
      const Radius.circular(corner),
    );

    canvas.drawRRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}