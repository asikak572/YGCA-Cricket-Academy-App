import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'notification_screen.dart';
import 'widgets/ygca_dashboard_app_bar.dart';
import 'widgets/ygca_drawer.dart';
import 'leave_request_screen.dart';
import 'student_attendance_module_screen.dart';
import 'student_performance_module_screen.dart';
import 'student_schedule_module_screen.dart';
import 'edit_profile_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

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

  int _percentValue(String value) {
    return int.tryParse(value.replaceAll("%", "").trim()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("No user logged in")));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('students')
          .doc(currentUser.uid)
          .snapshots(),
      builder: (context, studentSnapshot) {
        if (studentSnapshot.hasError) {
          return Scaffold(
            backgroundColor: bg,
            body: Center(child: Text("Error: ${studentSnapshot.error}")),
          );
        }

        if (studentSnapshot.connectionState == ConnectionState.waiting) {
          return _loadingScaffold(context);
        }

        if (studentSnapshot.hasData && studentSnapshot.data!.exists) {
          final data = studentSnapshot.data!.data() ?? {};
          return _dashboardScaffold(
            context: context,
            currentUser: currentUser,
            studentData: data,
          );
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('students')
              .where('uid', isEqualTo: currentUser.uid)
              .limit(1)
              .snapshots(),
          builder: (context, querySnapshot) {
            if (querySnapshot.hasError) {
              return Scaffold(
                backgroundColor: bg,
                body: Center(child: Text("Error: ${querySnapshot.error}")),
              );
            }

            if (querySnapshot.connectionState == ConnectionState.waiting) {
              return _loadingScaffold(context);
            }

            if (!querySnapshot.hasData || querySnapshot.data!.docs.isEmpty) {
              return Scaffold(
                backgroundColor: bg,
                appBar: YgcaDashboardAppBar(
                  role: 'STUDENT',
                  notificationCount: 0,
                  onNotificationTap: () {},
                  onLogout: () => _logout(context),
                ),
                body: const Center(
                  child: Text(
                    "Student details not found.\nPlease contact admin.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }

            final data = querySnapshot.data!.docs.first.data();

            return _dashboardScaffold(
              context: context,
              currentUser: currentUser,
              studentData: data,
            );
          },
        );
      },
    );
  }

  Widget _loadingScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: YgcaDashboardAppBar(
        role: 'STUDENT',
        notificationCount: 0,
        onNotificationTap: () {},
        onLogout: () => _logout(context),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _dashboardScaffold({
    required BuildContext context,
    required User currentUser,
    required Map<String, dynamic> studentData,
  }) {
    final name = _safeText(studentData, ['name', 'studentName'], 'Student');

    final email = _safeText(studentData, ['email'], currentUser.email ?? '');

    final batch = _safeText(studentData, [
      'batch',
      'studentBatch',
    ], 'Batch not assigned');

    final rollNo = _safeText(studentData, [
      'rollNo',
      'studentRollNo',
    ], 'Not assigned');

    final attendance = _safeText(studentData, [
      'attendance',
      'attendancePercentage',
    ], '0%');

    final attendanceNumber = _percentValue(attendance);

    return Scaffold(
      backgroundColor: bg,
      appBar: YgcaDashboardAppBar(
        role: 'STUDENT',
        notificationCount: 3,
        onNotificationTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        ),
        onLogout: () => _logout(context),
      ),
      drawer: YgcaDrawer(
        role: 'Student',
        navItems: [
          YgcaNavItem(
            icon: Icons.home_rounded,
            label: 'Dashboard',
            onTap: () {},
          ),
          YgcaNavItem(
            icon: Icons.fact_check_rounded,
            label: 'Attendance Module',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentAttendanceModuleScreen(
                  studentId: currentUser.uid,
                  name: name,
                  batch: batch,
                  rollNo: rollNo,
                  attendance: attendance,
                ),
              ),
            ),
          ),
          YgcaNavItem(
            icon: Icons.bar_chart_rounded,
            label: 'Performance Module',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StudentPerformanceModuleScreen(),
              ),
            ),
          ),
          YgcaNavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Schedule Module',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StudentScheduleModuleScreen(),
              ),
            ),
          ),
          YgcaNavItem(
            icon: Icons.person_rounded,
            label: 'Edit Profile',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          YgcaNavItem(
            icon: Icons.event_note_rounded,
            label: 'Apply Leave',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LeaveRequestScreen()),
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
        ],
        onLogout: () => _logout(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _studentHero(
                name: name,
                email: email,
                batch: batch,
                rollNo: rollNo,
                attendance: attendance,
              ),
              const SizedBox(height: 18),

              _sectionTitle("OVERVIEW"),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.95,
                  children: [
                    _statCard(
                      Icons.verified,
                      "ATTENDANCE",
                      "$attendanceNumber%",
                      attendanceNumber >= 75 ? "Good Progress" : "Needs Focus",
                      Colors.green,
                    ),
                    _statCard(
                      Icons.groups,
                      "BATCH",
                      batch,
                      "Assigned Batch",
                      Colors.blue,
                    ),
                    _statCard(
                      Icons.tag,
                      "ROLL NO.",
                      rollNo,
                      "Student ID",
                      Colors.purple,
                    ),
                    _statCard(
                      Icons.sports_cricket,
                      "PLAYER",
                      "Active",
                      "YGCA Student",
                      Colors.orange,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _sectionTitle("QUICK ACCESS"),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      Icons.fact_check,
                      "Attendance Module",
                      Colors.orange,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StudentAttendanceModuleScreen(
                              studentId: currentUser.uid,
                              name: name,
                              batch: batch,
                              rollNo: rollNo,
                              attendance: attendance,
                            ),
                          ),
                        );
                      },
                    ),
                    _menuCard(
                      context,
                      Icons.bar_chart,
                      "Performance Module",
                      Colors.green,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const StudentPerformanceModuleScreen(),
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
                            builder: (_) => const StudentScheduleModuleScreen(),
                          ),
                        );
                      },
                    ),
                    _menuCard(
                      context,
                      Icons.person,
                      "Edit Profile",
                      Colors.indigo,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    _menuCard(
                      context,
                      Icons.event_note,
                      "Apply Leave",
                      Colors.brown,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LeaveRequestScreen(),
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
                  ],
                ),
              ),

              const SizedBox(height: 22),
              _motivationCard(),
              const SizedBox(height: 22),
              _footer(),
              const SizedBox(height: 26),
            ],
          ),
        ),
      ),
    );
  }

  Widget _studentHero({
    required String name,
    required String email,
    required String batch,
    required String rollNo,
    required String attendance,
  }) {
    final initials = name
        .split(" ")
        .where((part) => part.isNotEmpty)
        .map((part) => part[0])
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      height: 260,
      width: double.infinity,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
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
                    maroon.withOpacity(0.68),
                    Colors.black.withOpacity(0.38),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Text(
                    initials.isNotEmpty ? initials : "S",
                    style: TextStyle(
                      color: maroon,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 29,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5, bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: gold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "STUDENT",
                          style: TextStyle(
                            color: maroon,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _heroChip("Batch: $batch"),
                          _heroChip("Roll No: $rollNo"),
                          _heroChip("Attendance: $attendance"),
                        ],
                      ),
                    ],
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
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.7)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: gold,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: gold,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: TextStyle(
                color: maroon,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: gold,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    IconData icon,
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.visible,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
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

  Widget _motivationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: maroon,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gold, width: 1.3),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: gold, size: 42),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "DISCIPLINE. DEDICATION. DOMINANCE.",
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "We don’t just play cricket, we live it!",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
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
        border: Border.all(color: gold, width: 1.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _footerItem(Icons.favorite_border, "Passion"),
          _footerItem(Icons.star_border, "Discipline"),
          _footerItem(Icons.emoji_events_outlined, "Success"),
        ],
      ),
    );
  }

  Widget _footerItem(IconData icon, String title) {
    return Column(
      children: [
        Icon(icon, color: gold, size: 28),
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
