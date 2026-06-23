import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';

import 'leave_request_screen.dart';
import 'notification_screen.dart';
import 'widgets/ygca_drawer.dart';

import 'coach_attendance_module_screen.dart';
import 'coach_student_module_screen.dart';
import 'coach_performance_module_screen.dart';
import 'coach_schedule_module_screen.dart';
import 'edit_profile_screen.dart';

class CoachDashboard extends StatelessWidget {
  const CoachDashboard({super.key});

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  void _open(BuildContext context, Widget screen) {
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
          backgroundColor: _bg(isDark),
          drawer: YgcaDrawer(
            role: 'Coach',
            navItems: [
              YgcaNavItem(
                icon: Icons.home_rounded,
                label: 'Dashboard',
                onTap: () {},
              ),
              YgcaNavItem(
                icon: Icons.people_rounded,
                label: 'Student Module',
                onTap: () => _open(
                  context,
                  const CoachStudentModuleScreen(),
                ),
              ),
              YgcaNavItem(
                icon: Icons.fact_check_rounded,
                label: 'Attendance Module',
                onTap: () => _open(
                  context,
                  const CoachAttendanceModuleScreen(),
                ),
              ),
              YgcaNavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Performance Module',
                onTap: () => _open(
                  context,
                  const CoachPerformanceModuleScreen(),
                ),
              ),
              YgcaNavItem(
                icon: Icons.calendar_month_rounded,
                label: 'Schedule Module',
                onTap: () => _open(
                  context,
                  const CoachScheduleModuleScreen(),
                ),
              ),
              YgcaNavItem(
                icon: Icons.event_note_rounded,
                label: 'Leave Requests',
                onTap: () => _open(
                  context,
                  const LeaveRequestScreen(),
                ),
              ),
              YgcaNavItem(
                icon: Icons.person_rounded,
                label: 'Edit Profile',
                onTap: () => _open(
                  context,
                  const EditProfileScreen(),
                ),
              ),
              YgcaNavItem(
                icon: Icons.notifications_rounded,
                label: 'Notifications',
                onTap: () => _open(
                  context,
                  const NotificationScreen(),
                ),
              ),
            ],
            onLogout: () => _logout(context),
          ),
          body: SafeArea(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Column(
                    children: [
                      _topBar(context, isDark),
                      const Expanded(
                        child: Center(
                          child: Text("Something went wrong"),
                        ),
                      ),
                    ],
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      _topBar(context, isDark),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Column(
                    children: [
                      _topBar(context, isDark),
                      const Expanded(
                        child: Center(
                          child: Text("Coach details not found"),
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
                  child: Column(
                    children: [
                      _topBar(context, isDark),
                      _coachHero(
                        isDark: isDark,
                        name: name,
                        email: email,
                        role: role,
                        batch: batch,
                        assignedStudents: assignedStudents,
                        status: status,
                      ),
                      const SizedBox(height: 18),
                      _sectionTitle("COACH OVERVIEW", isDark),
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
                            _statCard(
                              isDark: isDark,
                              icon: Icons.groups_rounded,
                              title: "STUDENTS",
                              value: assignedStudents,
                              subtitle: "Assigned",
                              color: Colors.blueAccent,
                            ),
                            _statCard(
                              isDark: isDark,
                              icon: Icons.fact_check_rounded,
                              title: "ATTENDANCE",
                              value: "Today",
                              subtitle: "Mark now",
                              color: Colors.green,
                            ),
                            _statCard(
                              isDark: isDark,
                              icon: Icons.sports_cricket_rounded,
                              title: "BATCH",
                              value: batch,
                              subtitle: "Training",
                              color: Colors.orange,
                            ),
                            _statCard(
                              isDark: isDark,
                              icon: Icons.verified_rounded,
                              title: "STATUS",
                              value: status,
                              subtitle: role,
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
                              Icons.fact_check_rounded,
                              "Mark\nAttendance",
                              Colors.green,
                              () => _open(
                                context,
                                const CoachAttendanceModuleScreen(),
                              ),
                            ),
                            _quickAction(
                              context,
                              isDark,
                              Icons.people_rounded,
                              "View\nStudents",
                              Colors.orange,
                              () => _open(
                                context,
                                const CoachStudentModuleScreen(),
                              ),
                            ),
                            _quickAction(
                              context,
                              isDark,
                              Icons.bar_chart_rounded,
                              "Performance\nReports",
                              Colors.blue,
                              () => _open(
                                context,
                                const CoachPerformanceModuleScreen(),
                              ),
                            ),
                            _quickAction(
                              context,
                              isDark,
                              Icons.event_note_rounded,
                              "Leave\nRequests",
                              Colors.brown,
                              () => _open(
                                context,
                                const LeaveRequestScreen(),
                              ),
                            ),
                            _quickAction(
                              context,
                              isDark,
                              Icons.calendar_month_rounded,
                              "Schedule\nModule",
                              Colors.teal,
                              () => _open(
                                context,
                                const CoachScheduleModuleScreen(),
                              ),
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
                              Icons.fact_check_rounded,
                              "Attendance",
                              "Mark session attendance",
                              Colors.green,
                              () => _open(
                                context,
                                const CoachAttendanceModuleScreen(),
                              ),
                            ),
                            _moduleCard(
                              context,
                              isDark,
                              Icons.people_alt_rounded,
                              "Student Module",
                              "Assigned batch students",
                              Colors.orange,
                              () => _open(
                                context,
                                const CoachStudentModuleScreen(),
                              ),
                            ),
                            _moduleCard(
                              context,
                              isDark,
                              Icons.bar_chart_rounded,
                              "Performance",
                              "Reports and analytics",
                              Colors.blue,
                              () => _open(
                                context,
                                const CoachPerformanceModuleScreen(),
                              ),
                            ),
                            _moduleCard(
                              context,
                              isDark,
                              Icons.calendar_month_rounded,
                              "Schedule",
                              "Sessions and makeup",
                              Colors.teal,
                              () => _open(
                                context,
                                const CoachScheduleModuleScreen(),
                              ),
                            ),
                            _moduleCard(
                              context,
                              isDark,
                              Icons.event_note_rounded,
                              "Leave Requests",
                              "Approve and manage",
                              Colors.brown,
                              () => _open(
                                context,
                                const LeaveRequestScreen(),
                              ),
                            ),
                            _moduleCard(
                              context,
                              isDark,
                              Icons.person_rounded,
                              "Edit Profile",
                              "Update coach details",
                              Colors.indigo,
                              () => _open(
                                context,
                                const EditProfileScreen(),
                              ),
                            ),
                            _moduleCard(
                              context,
                              isDark,
                              Icons.notifications_active_rounded,
                              "Notifications",
                              "Academy updates",
                              Colors.redAccent,
                              () => _open(
                                context,
                                const NotificationScreen(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      _todaySessionCard(isDark, batch),
                      const SizedBox(height: 18),
                      _coachNoteCard(isDark),
                      const SizedBox(height: 18),
                      _footer(isDark),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
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
                  "Coach Control Center",
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
      height: 230,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? red.withOpacity(0.55) : gold.withOpacity(0.9),
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
            right: -24,
            bottom: -24,
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
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: maroon,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 230,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "GOOD MORNING,",
                            style: TextStyle(
                              color: gold,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: gold,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              role.toUpperCase(),
                              style: const TextStyle(
                                color: maroon,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _heroChip("Students: $assignedStudents"),
                              _heroChip("Status: $status"),
                            ],
                          ),
                          const SizedBox(height: 7),
                          _heroChip("Batch: $batch"),
                        ],
                      ),
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
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.75)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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

  Widget _statCard({
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
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 20,
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

  Widget _todaySessionCard(bool isDark, String batch) {
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
            child: Icon(
              Icons.event_available_rounded,
              color: gold,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Assigned Training Batch",
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  batch,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Attendance • Students • Performance",
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
              "LIVE",
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coachNoteCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : const Color(0xFFFFFBF2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? gold.withOpacity(0.65) : gold.withOpacity(0.9),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events_rounded, color: gold, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TRAIN. GUIDE. INSPIRE.",
                  style: TextStyle(
                    color: isDark ? gold : maroon,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Great coaches build great players.",
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _footerItem(Icons.favorite_rounded, "Passion"),
          _footerItem(Icons.star_rounded, "Discipline"),
          _footerItem(Icons.emoji_events_rounded, "Success"),
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