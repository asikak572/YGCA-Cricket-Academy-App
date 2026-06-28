import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';

import 'leave_request_screen.dart';
import 'notification_screen.dart';
import 'widgets/ygca_drawer.dart';
import 'widgets/ygca_bottom_nav.dart';

import 'coach_attendance_module_screen.dart';
import 'coach_student_module_screen.dart';
import 'coach_performance_module_screen.dart';
import 'coach_schedule_module_screen.dart';
import 'edit_profile_screen.dart';

class CoachDashboard extends StatefulWidget {
  const CoachDashboard({super.key});

  @override
  State<CoachDashboard> createState() => _CoachDashboardState();
}

class _CoachDashboardState extends State<CoachDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color gold = Color(0xFFD4AF37);

  static const String logoAsset = 'assets/images/ygca_logo.jpg';

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  void _open(Widget screen) {
    _scaffoldKey.currentState?.closeDrawer();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  String _safeText(
    Map<String, dynamic> data,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  String _assignedBatchesText(Map<String, dynamic> data) {
    final raw = data['assignedBatches'];

    if (raw is List && raw.isNotEmpty) {
      final batches = raw
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (batches.isNotEmpty) {
        return batches.join(', ');
      }
    }

    return _safeText(data, ['batch', 'assignedBatch'], 'Batch not assigned');
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
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: _bg(isDark),
          drawer: YgcaDrawer(
  role: 'Coach',
  username: 'Coach User',
  onLogout: _logout,
),
          body: SafeArea(
            bottom: false,
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Column(
                    children: [
                      _topBar(isDark),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Something went wrong",
                            style: TextStyle(color: _primaryText(isDark)),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      _topBar(isDark),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Column(
                    children: [
                      _topBar(isDark),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Coach details not found",
                            style: TextStyle(color: _primaryText(isDark)),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                final data = snapshot.data!.data() ?? {};

                final name = _safeText(data, ['name'], 'Coach');
                final email = _safeText(
                  data,
                  ['email'],
                  currentUser.email ?? '',
                );
                final role = _safeText(data, ['role'], 'Coach');
                final batch = _assignedBatchesText(data);
                final assignedStudents =
                    _safeText(data, ['assignedStudents'], '0');
                final status = _safeText(data, ['status'], 'Active');

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    children: [
                      _topBar(isDark),
                      _coachHero(
                        isDark: isDark,
                        name: name,
                        email: email,
                        role: role,
                        batch: batch,
                        assignedStudents: assignedStudents,
                        status: status,
                      ),
                      const SizedBox(height: 14),

                      _sectionTitle(
                        title: "COACH OVERVIEW",
                        isDark: isDark,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.35,
                          children: [
                            _overviewCard(
                              isDark: isDark,
                              icon: Icons.groups_rounded,
                              title: "Students",
                              value: assignedStudents,
                              subtitle: "Assigned",
                              color: Colors.blueAccent,
                            ),
                            _overviewCard(
                              isDark: isDark,
                              icon: Icons.fact_check_rounded,
                              title: "Attendance",
                              value: "Today",
                              subtitle: "Mark now",
                              color: Colors.green,
                            ),
                            _overviewCard(
                              isDark: isDark,
                              icon: Icons.sports_cricket_rounded,
                              title: "Batch",
                              value: batch,
                              subtitle: "Training",
                              color: Colors.orange,
                            ),
                            _overviewCard(
                              isDark: isDark,
                              icon: Icons.verified_rounded,
                              title: "Status",
                              value: status,
                              subtitle: role,
                              color: Colors.purpleAccent,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      _sectionTitle(
                        title: "QUICK ACTIONS",
                        isDark: isDark,
                      ),

                      _quickActions(isDark),

                      const SizedBox(height: 6),
                    ],
                  ),
                );
              },
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
                onTap: () => _open(const CoachStudentModuleScreen()),
              ),
              YgcaBottomNavItem(
                icon: Icons.fact_check_rounded,
                label: 'Attendance',
                onTap: () => _open(const CoachAttendanceModuleScreen()),
              ),
              YgcaBottomNavItem(
                icon: Icons.analytics_rounded,
                label: 'Reports',
                onTap: () => _open(const CoachPerformanceModuleScreen()),
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
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      child: Row(
        children: [
          _circleButton(
            isDark: isDark,
            icon: Icons.menu_rounded,
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: 10),
          Image.asset(
            logoAsset,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  "Coach Control Center",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11,
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
          const SizedBox(width: 7),
          _circleButton(
            isDark: isDark,
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            onTap: ThemeController.toggleTheme,
          ),
          const SizedBox(width: 7),
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
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111111) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: red.withOpacity(isDark ? 0.34 : 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? red.withOpacity(0.12)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 5),
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

  Widget _coachHero({
    required bool isDark,
    required String name,
    required String email,
    required String role,
    required String batch,
    required String assignedStudents,
    required String status,
  }) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "C";

    return Container(
      height: 248,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.76 : 0.16,
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
                          Colors.black.withOpacity(0.92),
                          Colors.black.withOpacity(0.78),
                          red.withOpacity(0.28),
                        ]
                      : [
                          Colors.white.withOpacity(0.96),
                          Colors.white.withOpacity(0.88),
                          red.withOpacity(0.05),
                        ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),

          Positioned(
            right: -6,
            top: 18,
            bottom: 0,
            child: Opacity(
              opacity: isDark ? 0.30 : 0.10,
              child: Icon(
                Icons.sports_cricket_rounded,
                size: 170,
                color: red,
              ),
            ),
          ),

          Positioned.fill(
            child: CustomPaint(
              painter: _HeroClosedBorderPainter(
                color: isDark ? gold.withOpacity(0.85) : red.withOpacity(0.65),
              ),
            ),
          ),

          Positioned(
            left: 24,
            top: 58,
            child: SizedBox(
              width: 118,
              height: 118,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 118,
                    height: 118,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? gold.withOpacity(0.65)
                            : red.withOpacity(0.35),
                        width: 1.6,
                      ),
                    ),
                  ),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Colors.black.withOpacity(0.35)
                          : Colors.white.withOpacity(0.55),
                      border: Border.all(
                        color: isDark
                            ? red.withOpacity(0.45)
                            : red.withOpacity(0.20),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: isDark ? gold : maroon,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 154,
            top: 38,
            right: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "GOOD MORNING,",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? gold : red,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 30,
                    height: 0.98,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "COACH DASHBOARD",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? gold : red,
                    fontSize: 17,
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 58,
                  height: 3,
                  decoration: BoxDecoration(
                    color: isDark ? gold : red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF374151),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  "Batch: $batch",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Row(
        children: [
          SizedBox(
            width: 172,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  color: isDark ? gold : const Color(0xFF111827),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.9,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: red.withOpacity(isDark ? 0.58 : 0.55),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF121212),
                  const Color(0xFF171717),
                  color.withOpacity(0.14),
                ]
              : [
                  Colors.white,
                  Colors.white,
                  color.withOpacity(0.04),
                ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? red.withOpacity(0.32) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark ? color.withOpacity(0.08) : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(isDark ? 0.15 : 0.10),
              border: Border.all(color: color.withOpacity(0.35)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 96,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontSize: 19,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontSize: 9.5,
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

  Widget _quickActions(bool isDark) {
    return SizedBox(
      height: 92,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _quickActionCard(
            isDark: isDark,
            icon: Icons.fact_check_rounded,
            title: "Mark\nAttendance",
            color: Colors.green,
            onTap: () => _open(const CoachAttendanceModuleScreen()),
          ),
          _quickActionCard(
            isDark: isDark,
            icon: Icons.people_rounded,
            title: "View\nStudents",
            color: Colors.orange,
            onTap: () => _open(const CoachStudentModuleScreen()),
          ),
          _quickActionCard(
            isDark: isDark,
            icon: Icons.bar_chart_rounded,
            title: "Performance\nReports",
            color: Colors.blue,
            onTap: () => _open(const CoachPerformanceModuleScreen()),
          ),
          _quickActionCard(
            isDark: isDark,
            icon: Icons.event_note_rounded,
            title: "Leave\nRequests",
            color: Colors.brown,
            onTap: () => _open(const LeaveRequestScreen()),
          ),
          _quickActionCard(
            isDark: isDark,
            icon: Icons.calendar_month_rounded,
            title: "Schedule\nModule",
            color: Colors.teal,
            onTap: () => _open(const CoachScheduleModuleScreen()),
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
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 92,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: _card(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? red.withOpacity(0.30) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isDark ? red.withOpacity(0.08) : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(height: 7),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _primaryText(isDark),
                fontSize: 10.5,
                height: 1.12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroClosedBorderPainter extends CustomPainter {
  final Color color;

  _HeroClosedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final outerPaint = Paint()
      ..color = color.withOpacity(0.28)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final accentPaint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
      const Radius.circular(26),
    );

    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(18, 18, size.width - 36, size.height - 36),
      const Radius.circular(22),
    );

    canvas.drawRRect(outer, outerPaint);
    canvas.drawRRect(inner, outerPaint);

    canvas.drawLine(const Offset(28, 28), const Offset(70, 28), accentPaint);
    canvas.drawLine(const Offset(28, 28), const Offset(28, 70), accentPaint);
    canvas.drawLine(const Offset(40, 40), const Offset(70, 40), accentPaint);
    canvas.drawLine(const Offset(40, 40), const Offset(40, 70), accentPaint);

    canvas.drawLine(
      Offset(size.width - 28, 28),
      Offset(size.width - 70, 28),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width - 28, 28),
      Offset(size.width - 28, 70),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width - 40, 40),
      Offset(size.width - 70, 40),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width - 40, 40),
      Offset(size.width - 40, 70),
      accentPaint,
    );

    canvas.drawLine(
      Offset(28, size.height - 28),
      Offset(70, size.height - 28),
      accentPaint,
    );
    canvas.drawLine(
      Offset(28, size.height - 28),
      Offset(28, size.height - 70),
      accentPaint,
    );
    canvas.drawLine(
      Offset(40, size.height - 40),
      Offset(70, size.height - 40),
      accentPaint,
    );
    canvas.drawLine(
      Offset(40, size.height - 40),
      Offset(40, size.height - 70),
      accentPaint,
    );

    canvas.drawLine(
      Offset(size.width - 28, size.height - 28),
      Offset(size.width - 70, size.height - 28),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width - 28, size.height - 28),
      Offset(size.width - 28, size.height - 70),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width - 40, size.height - 40),
      Offset(size.width - 70, size.height - 40),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width - 40, size.height - 40),
      Offset(size.width - 40, size.height - 70),
      accentPaint,
    );

    canvas.drawCircle(const Offset(88, 28), 3, dotPaint);
    canvas.drawCircle(Offset(size.width - 88, 28), 3, dotPaint);
    canvas.drawCircle(Offset(88, size.height - 28), 3, dotPaint);
    canvas.drawCircle(Offset(size.width - 88, size.height - 28), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}