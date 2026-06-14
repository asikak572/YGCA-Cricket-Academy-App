import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'leave_request_screen.dart';
import 'notification_screen.dart';
import 'widgets/ygca_dashboard_app_bar.dart';
import 'widgets/ygca_drawer.dart';

import 'coach_attendance_module_screen.dart';
import 'coach_student_module_screen.dart';
import 'coach_performance_module_screen.dart';
import 'coach_schedule_module_screen.dart';
import 'edit_profile_screen.dart';

class CoachDashboard extends StatelessWidget {
  const CoachDashboard({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

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

  String _safeText(Map<String, dynamic> data, List<String> keys, String fallback) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("No user logged in")));
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: YgcaDashboardAppBar(
        role: 'COACH',
        notificationCount: 3,
        onNotificationTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        ),
        onLogout: () => _logout(context),
      ),
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CoachStudentModuleScreen()),
            ),
          ),
          YgcaNavItem(
            icon: Icons.fact_check_rounded,
            label: 'Attendance Module',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CoachAttendanceModuleScreen()),
            ),
          ),
          YgcaNavItem(
            icon: Icons.bar_chart_rounded,
            label: 'Performance Module',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CoachPerformanceModuleScreen()),
            ),
          ),
          YgcaNavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Schedule Module',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CoachScheduleModuleScreen()),
            ),
          ),
          YgcaNavItem(
            icon: Icons.event_note_rounded,
            label: 'Leave Requests',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LeaveRequestScreen()),
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Coach details not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final name = _safeText(data, ['name'], 'Coach');
          final email = _safeText(data, ['email'], currentUser.email ?? '');
          final role = _safeText(data, ['role'], 'Coach');
          final batch = _safeText(data, ['batch', 'assignedBatch'], 'Batch not assigned');
          final assignedStudents = _safeText(data, ['assignedStudents'], '0');

          return SingleChildScrollView(
            child: Column(
              children: [
                _coachHero(
                  name: name,
                  email: email,
                  role: role,
                  batch: batch,
                  assignedStudents: assignedStudents,
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
                    childAspectRatio: 1.08,
                    children: [
                      _statCard(Icons.groups, "STUDENTS", assignedStudents, "Assigned", Colors.blue),
                      _statCard(Icons.check_circle, "ATTENDANCE", "Today", "Mark Now", Colors.green),
                      _statCard(Icons.sports, "BATCH", batch, "Training", Colors.orange),
                      _statCard(Icons.verified, "STATUS", "Active", role, Colors.purple),
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
                    childAspectRatio: 1.55,
                    children: [
                      _menuCard(
  context,
  Icons.fact_check,
  "Attendance Module",
  Colors.green,
  () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CoachAttendanceModuleScreen(),
      ),
    );
  },
),
                     
                    _menuCard(
  context,
  Icons.people,
  "Student Module",
  Colors.orange,
  () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CoachStudentModuleScreen(),
      ),
    );
  },
),
                      _menuCard(
  context,
  Icons.bar_chart,
  "Performance Module",
  Colors.blue,
  () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CoachPerformanceModuleScreen(),
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
        builder: (_) => const CoachScheduleModuleScreen(),
      ),
    );
  },
),
                     
                     _menuCard(
  context,
  Icons.event_note,
  "Leave Requests",
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
                _coachNoteCard(),
                const SizedBox(height: 22),
                _footer(),
                const SizedBox(height: 26),
              ],
            ),
          );
        },
      ),
    );
  }



  Widget _coachHero({
    required String name,
    required String email,
    required String role,
    required String batch,
    required String assignedStudents,
  }) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "C";

    return Container(
      height: 250,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
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
                    initial,
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: gold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          role.toUpperCase(),
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
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _heroChip("Batch: $batch"),
                          _heroChip("Students: $assignedStudents"),
                          _heroChip("Status: Active"),
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

  Widget _statCard(
    IconData icon,
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          Icon(icon, color: color, size: 32),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
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
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
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

          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: 18,
          ),
        ],
      ),
    ),
  );
}
  Widget _coachNoteCard() {
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
                  "TRAIN. GUIDE. INSPIRE.",
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Great coaches build great players.",
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}