import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets/ygca_drawer.dart';
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

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Color _bg(bool isDark) {
    return isDark ? const Color(0xFF070707) : const Color(0xFFFAFAFA);
  }

  Color _card(bool isDark) {
    return isDark ? const Color(0xFF111111) : Colors.white;
  }

  Color _border(bool isDark) {
    return isDark ? const Color(0xFF3A1515) : const Color(0xFFE2E8F0);
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
          backgroundColor: _bg(isDark),
          drawer: YgcaDrawer(
            role: 'Admin',
            navItems: [
              YgcaNavItem(
                icon: Icons.home_rounded,
                label: 'Dashboard',
                onTap: () {},
              ),
              YgcaNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Reports Dashboard',
                onTap: () => _open(context, const ReportsDashboardScreen()),
              ),
              YgcaNavItem(
                icon: Icons.people_rounded,
                label: 'Students',
                onTap: () => _open(context, const StudentListScreen()),
              ),
              YgcaNavItem(
                icon: Icons.check_circle_rounded,
                label: 'Attendance Module',
                onTap: () => _open(context, const AttendanceModuleScreen()),
              ),
              YgcaNavItem(
                icon: Icons.sports_rounded,
                label: 'Coach Module',
                onTap: () => _open(context, CoachModuleScreen()),
              ),
              YgcaNavItem(
                icon: Icons.payments_rounded,
                label: 'Fee Module',
                onTap: () => _open(context, FeeModuleScreen()),
              ),
              YgcaNavItem(
                icon: Icons.calendar_month_rounded,
                label: 'Schedule Module',
                onTap: () => _open(context, const ScheduleModuleScreen()),
              ),
              YgcaNavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Performance Reports',
                onTap: () => _open(context, const PerformanceReportScreen()),
              ),
              YgcaNavItem(
                icon: Icons.payments,
                label: 'Coach Salary Analytics',
                onTap: () => _open(
                  context,
                  const CoachSalaryAnalyticsScreen(),
                ),
              ),
              YgcaNavItem(
                icon: Icons.notifications_rounded,
                label: 'Notifications',
                onTap: () => _open(context, const NotificationScreen()),
              ),
              YgcaNavItem(
                icon: Icons.campaign,
                label: 'Communication Center',
                onTap: () => _open(context, const CommunicationCenterScreen()),
              ),
            ],
            onLogout: () => _logout(context),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _topBar(context, isDark),
                  _heroBanner(isDark),
                  const SizedBox(height: 18),
                  _sectionTitle("ACADEMY OVERVIEW", isDark),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.05,
                      children: [
                        _overviewCard(
                          isDark: isDark,
                          icon: Icons.groups_rounded,
                          title: "Total Students",
                          value: "248",
                          subtitle: "Registered players",
                          color: Colors.blueAccent,
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
                  const SizedBox(height: 20),
                  _sectionTitle("QUICK ACTIONS", isDark),
                  SizedBox(
                    height: 116,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _quickAction(
                          context,
                          isDark,
                          Icons.how_to_reg_rounded,
                          "Student\nApproval",
                          Colors.green,
                          () => _open(context, const StudentListScreen()),
                        ),
                        _quickAction(
                          context,
                          isDark,
                          Icons.sports_rounded,
                          "Coach\nCenter",
                          Colors.deepOrange,
                          () => _open(context, CoachModuleScreen()),
                        ),
                        _quickAction(
                          context,
                          isDark,
                          Icons.fact_check_rounded,
                          "Mark\nAttendance",
                          Colors.blue,
                          () => _open(context, const AttendanceModuleScreen()),
                        ),
                        _quickAction(
                          context,
                          isDark,
                          Icons.campaign_rounded,
                          "Send\nNotice",
                          Colors.purple,
                          () => _open(
                            context,
                            const CommunicationCenterScreen(),
                          ),
                        ),
                        _quickAction(
                          context,
                          isDark,
                          Icons.analytics_rounded,
                          "Reports\nAnalytics",
                          Colors.amber,
                          () => _open(context, const ReportsDashboardScreen()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _sectionTitle("MODULE ACCESS", isDark),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.38,
                      children: [
                        _moduleCard(
                          context,
                          isDark,
                          Icons.dashboard_rounded,
                          "Reports Dashboard",
                          "Academy insights",
                          Colors.red,
                          () => _open(context, const ReportsDashboardScreen()),
                        ),
                        _moduleCard(
                          context,
                          isDark,
                          Icons.people_alt_rounded,
                          "Students",
                          "Manage players",
                          Colors.orange,
                          () => _open(context, const StudentListScreen()),
                        ),
                        _moduleCard(
                          context,
                          isDark,
                          Icons.check_circle_rounded,
                          "Attendance",
                          "Track sessions",
                          Colors.green,
                          () => _open(context, const AttendanceModuleScreen()),
                        ),
                        _moduleCard(
                          context,
                          isDark,
                          Icons.sports_cricket_rounded,
                          "Coach Module",
                          "Coach approval",
                          Colors.purple,
                          () => _open(context, CoachModuleScreen()),
                        ),
                        _moduleCard(
                          context,
                          isDark,
                          Icons.payments_rounded,
                          "Fee Module",
                          "Fees & dues",
                          Colors.blue,
                          () => _open(context, FeeModuleScreen()),
                        ),
                        _moduleCard(
                          context,
                          isDark,
                          Icons.calendar_month_rounded,
                          "Schedule",
                          "Batches & sessions",
                          Colors.teal,
                          () => _open(context, const ScheduleModuleScreen()),
                        ),
                        _moduleCard(
                          context,
                          isDark,
                          Icons.bar_chart_rounded,
                          "Performance",
                          "Player reports",
                          Colors.indigo,
                          () => _open(context, const PerformanceReportScreen()),
                        ),
                        _moduleCard(
                          context,
                          isDark,
                          Icons.account_balance_wallet_rounded,
                          "Coach Salary",
                          "Salary analytics",
                          Colors.greenAccent,
                          () => _open(
                            context,
                            const CoachSalaryAnalyticsScreen(),
                          ),
                        ),
                        _moduleCard(
                          context,
                          isDark,
                          Icons.notifications_active_rounded,
                          "Notifications",
                          "Alerts & updates",
                          Colors.redAccent,
                          () => _open(context, const NotificationScreen()),
                        ),
                        _moduleCard(
                          context,
                          isDark,
                          Icons.campaign_rounded,
                          "Communication",
                          "Announcements",
                          Colors.deepPurpleAccent,
                          () => _open(
                            context,
                            const CommunicationCenterScreen(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _todaySessionCard(isDark),
                  const SizedBox(height: 18),
                  _recentActivity(isDark),
                  const SizedBox(height: 24),
                  _footer(isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _topBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Row(
        children: [
          Builder(
            builder: (drawerContext) {
              return _circleButton(
                isDark: isDark,
                icon: Icons.menu_rounded,
                onTap: () => Scaffold.of(drawerContext).openDrawer(),
              );
            },
          ),
          const SizedBox(width: 12),
          Image.asset(
            'assets/images/ygca_logo.jpg',
            width: 46,
            height: 46,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "YGCA",
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  "Admin Control Center",
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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
                onTap: () => _open(context, const NotificationScreen()),
              ),
              Positioned(
                right: 3,
                top: 2,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeMode,
            builder: (context, mode, _) {
              final dark = mode == ThemeMode.dark;

              return _circleButton(
                isDark: isDark,
                icon: dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                onTap: ThemeController.toggleTheme,
              );
            },
          ),
          const SizedBox(width: 8),
          _circleButton(
            isDark: isDark,
            icon: Icons.logout_rounded,
            onTap: () => _logout(context),
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
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111111) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _border(isDark)),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? red.withOpacity(0.12)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : maroon,
          size: 21,
        ),
      ),
    );
  }

  Widget _heroBanner(bool isDark) {
    return Container(
      height: 220,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? red.withOpacity(0.55) : gold.withOpacity(0.9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? red.withOpacity(0.22)
                : maroon.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_hero_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Colors.black.withOpacity(0.90),
                          darkMaroon.withOpacity(0.88),
                          red.withOpacity(0.35),
                        ]
                      : [
                          maroon.withOpacity(0.92),
                          maroon.withOpacity(0.70),
                          Colors.black.withOpacity(0.25),
                        ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Positioned(
            right: -22,
            bottom: -22,
            child: Icon(
              Icons.sports_cricket_rounded,
              color: Colors.white.withOpacity(0.08),
              size: 150,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.42),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: red.withOpacity(0.55)),
                  ),
                  child: Image.asset(
                    'assets/images/ygca_logo.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "GOOD MORNING,",
                          style: TextStyle(
                            color: gold,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                        const Text(
                          "ADMIN",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            height: 0.95,
                          ),
                        ),
                        Text(
                          "CONTROL DASHBOARD",
                          style: TextStyle(
                            color: gold,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Manage students, coaches,\nattendance and academy growth.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _heroChip("4 Roles"),
                            const SizedBox(width: 8),
                            _heroChip("10 Modules"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.75)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: gold,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? gold : maroon,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              color: isDark ? red.withOpacity(0.45) : gold.withOpacity(0.9),
            ),
          ),
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
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF151515),
                  const Color(0xFF1A0808),
                  color.withOpacity(0.16),
                ]
              : [
                  Colors.white,
                  const Color(0xFFFFFBF2),
                  color.withOpacity(0.08),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? red.withOpacity(0.30) : gold.withOpacity(0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? color.withOpacity(0.12)
                : Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 135,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.18),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickAction(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 105,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _card(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border(isDark)),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.16),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _primaryText(isDark),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moduleCard(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _card(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? red.withOpacity(0.25) : _border(isDark),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.30)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.22),
                    red.withOpacity(0.10),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: color.withOpacity(0.40)),
              ),
              child: Icon(icon, color: color, size: 23),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _primaryText(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _secondaryText(isDark),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white38 : Colors.black38,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _todaySessionCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF180808),
                  const Color(0xFF0F0F0F),
                  red.withOpacity(0.18),
                ]
              : [
                  Colors.white,
                  const Color(0xFFFFFBF2),
                  gold.withOpacity(0.18),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? red.withOpacity(0.35) : gold.withOpacity(0.7),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: red.withOpacity(0.18),
            child: Icon(Icons.event_available_rounded, color: gold, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Main Session",
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Saturday: 7:00 AM - 9:00 AM",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "20 / 24 Present • YGCA Ground",
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: gold, width: 4),
            ),
            child: Text(
              "83%",
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentActivity(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded, color: gold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Recent Activity",
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                "View All",
                style: TextStyle(
                  color: red,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _activityItem(
            isDark,
            Icons.check_circle_rounded,
            "Attendance marked for Saturday batch",
            "1h ago",
            Colors.green,
          ),
          _activityItem(
            isDark,
            Icons.person_add_alt_1_rounded,
            "New student waiting for approval",
            "2h ago",
            Colors.orange,
          ),
          _activityItem(
            isDark,
            Icons.sports_rounded,
            "Coach approval flow updated",
            "Today",
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _activityItem(
    bool isDark,
    IconData icon,
    String text,
    String time,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.035) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.16),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _primaryText(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: TextStyle(
              color: _secondaryText(isDark),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  maroon,
                  darkMaroon,
                  Colors.black,
                ]
              : [
                  maroon,
                  red.withOpacity(0.85),
                  darkMaroon,
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gold.withOpacity(0.7), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: red.withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: gold, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Excellence in Cricket Training",
                      style: TextStyle(
                        color: gold,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Building champions with passion, discipline and success.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _footerItem(Icons.favorite_rounded, "Passion"),
              _footerItem(Icons.star_rounded, "Discipline"),
              _footerItem(Icons.emoji_events_rounded, "Success"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerItem(IconData icon, String title) {
    return Column(
      children: [
        Icon(icon, color: gold, size: 25),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}