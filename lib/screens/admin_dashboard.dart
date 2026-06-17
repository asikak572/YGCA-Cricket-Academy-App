import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets/ygca_dashboard_app_bar.dart';
import 'widgets/ygca_drawer.dart';

import 'student_list_screen.dart';
import 'performance_report_screen.dart';
import 'notification_screen.dart';
import 'reports_dashboard_screen.dart';
import 'attendance_module_screen.dart';
import 'fee_module_screen.dart';
import 'coach_module_screen.dart';
import 'schedule_module_screen.dart';
import 'coach_salary_analytics_screen.dart';
import 'sms_notification_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: YgcaDashboardAppBar(
        role: 'ADMIN',
        showProfileAvatar: true,
        notificationCount: 3,
        onNotificationTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        ),
        onLogout: () => _logout(context),
      ),
      drawer: YgcaDrawer(
        role: 'Admin',
        navItems: [
          YgcaNavItem(icon: Icons.home_rounded, label: 'Dashboard', onTap: () {}),
          YgcaNavItem(
            icon: Icons.dashboard_rounded,
            label: 'Reports Dashboard',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportsDashboardScreen()),
            ),
          ),
          YgcaNavItem(
            icon: Icons.people_rounded,
            label: 'Students',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudentListScreen()),
            ),
          ),
          YgcaNavItem(
            icon: Icons.check_circle_rounded,
            label: 'Attendance Module',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AttendanceModuleScreen()),
            ),
          ),
          YgcaNavItem(
            icon: Icons.sports_rounded,
            label: 'Coach Module',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CoachModuleScreen()),
            ),
          ),
          YgcaNavItem(
            icon: Icons.payments_rounded,
            label: 'Fee Module',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FeeModuleScreen()),
            ),
          ),
          YgcaNavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Schedule Module',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScheduleModuleScreen()),
            ),
          ),
          YgcaNavItem(
            icon: Icons.bar_chart_rounded,
            label: 'Performance Reports',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PerformanceReportScreen()),
            ),
          ),
          YgcaNavItem(
            icon: Icons.payments,
            label: 'Coach Salary Analytics',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CoachSalaryAnalyticsScreen(),
              ),
            ),
          ),
          YgcaNavItem(
            icon: Icons.notifications_rounded,
            label: 'Notifications',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            ),
          ),
          YgcaNavItem(
            icon: Icons.sms_rounded,
            label: 'SMS Notifications',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SmsNotificationScreen()),
            ),
          ),
        ],
        onLogout: () => _logout(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _heroBanner(),
            const SizedBox(height: 18),
            _sectionTitle("OVERVIEW"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.22,
                children: [
                  _overviewCard(Icons.groups, "Total Students", "248", "View all"),
                  _overviewCard(Icons.check_circle, "Attendance", "186", "75% Today"),
                  _overviewCard(Icons.receipt, "Pending Fees", "₹2.45L", "28 Students"),
                  _overviewCard(Icons.calendar_month, "Sessions", "6", "2 Cancelled"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle("MODULE ACCESS"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.65,
                children: [
                  _menuCard(
                    context,
                    Icons.dashboard,
                    "Reports Dashboard",
                    Colors.red,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportsDashboardScreen(),
                        ),
                      );
                    },
                  ),
                  _menuCard(
                    context,
                    Icons.people,
                    "Students",
                    Colors.orange,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudentListScreen(),
                        ),
                      );
                    },
                  ),
                  _menuCard(
                    context,
                    Icons.check_circle,
                    "Attendance Module",
                    Colors.green,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AttendanceModuleScreen(),
                        ),
                      );
                    },
                  ),
                  _menuCard(
                    context,
                    Icons.sports,
                    "Coach Module",
                    Colors.purple,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CoachModuleScreen(),
                        ),
                      );
                    },
                  ),
                  _menuCard(
                    context,
                    Icons.payments,
                    "Fee Module",
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FeeModuleScreen(),
                        ),
                      );
                    },
                  ),
                  _menuCard(
                    context,
                    Icons.calendar_month,
                    "Schedule Module",
                    Colors.teal,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ScheduleModuleScreen(),
                        ),
                      );
                    },
                  ),
                  _menuCard(
                    context,
                    Icons.bar_chart,
                    "Performance Reports",
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PerformanceReportScreen(),
                        ),
                      );
                    },
                  ),
                  _menuCard(
                    context,
                    Icons.payments,
                    "Coach Salary Analytics",
                    Colors.green,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CoachSalaryAnalyticsScreen(),
                        ),
                      );
                    },
                  ),
                  _menuCard(
                    context,
                    Icons.notifications,
                    "Notifications",
                    Colors.red,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  _menuCard(
                    context,
                    Icons.sms,
                    "SMS Notifications",
                    Colors.deepOrange,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SmsNotificationScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _footer(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _heroBanner() {
    return Container(
      height: 210,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        border: Border.all(color: gold, width: 1),
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
                  colors: [
                    darkMaroon.withOpacity(0.96),
                    maroon.withOpacity(0.65),
                    Colors.black.withOpacity(0.45),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/ygca_logo.jpg',
                  width: 88,
                  height: 88,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "WELCOME BACK,",
                          style: TextStyle(
                            color: gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const Text(
                          "ADMIN",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 29,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        Text(
                          "DASHBOARD",
                          style: TextStyle(
                            color: gold,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Manage your academy\nlike a champion",
                          style: TextStyle(color: Colors.white, fontSize: 12),
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: maroon,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 42, height: 2, color: gold),
        ],
      ),
    );
  }

  Widget _overviewCard(
    IconData icon,
    String title,
    String value,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: maroon,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _footer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: maroon,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gold, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.20),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: gold, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Excellence in Cricket Training",
                      style: TextStyle(
                        color: gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Building Champions Since 2022",
                      style: TextStyle(color: Colors.white, fontSize: 12),
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
              _footerItem(Icons.favorite_border, "Passion"),
              _footerItem(Icons.star_border, "Discipline"),
              _footerItem(Icons.emoji_events_outlined, "Success"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerItem(IconData icon, String title) {
    return Column(
      children: [
        Icon(icon, color: gold, size: 26),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}