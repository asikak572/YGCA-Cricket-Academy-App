import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'attendance_calendar_screen.dart';
import 'attendance_history_screen.dart';
import 'performance_report_screen.dart';
import 'match_schedule_screen.dart';
import 'training_schedule_screen.dart';
import 'notification_screen.dart';

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
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
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
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Student details not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final name = _safeText(data, ['name', 'studentName'], 'Student');
          final email = _safeText(data, ['email'], currentUser.email ?? '');
          final batch = _safeText(
            data,
            ['batch', 'studentBatch'],
            'Batch not assigned',
          );
          final rollNo = _safeText(
            data,
            ['rollNo', 'studentRollNo'],
            'Not assigned',
          );
          final attendance = _safeText(
            data,
            ['attendance', 'attendancePercentage'],
            '0%',
          );

          final attendanceNumber = _percentValue(attendance);

          return SingleChildScrollView(
            child: Column(
              children: [
                _topHeader(context),
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
                    childAspectRatio: 1.25,
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
                    childAspectRatio: 1.55,
                    children: [
                      _menuCard(
                        context,
                        Icons.calendar_month,
                        "My Attendance",
                        "Calendar & status",
                        Colors.orange,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AttendanceCalendarScreen(
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
                        Icons.history,
                        "History",
                        "Attendance history",
                        Colors.red,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AttendanceHistoryScreen(),
                            ),
                          );
                        },
                      ),
                      _menuCard(
                        context,
                        Icons.bar_chart,
                        "Performance",
                        "Track progress",
                        Colors.green,
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
                        Icons.sports_cricket,
                        "Matches",
                        "Match schedule",
                        Colors.purple,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MatchScheduleScreen(),
                            ),
                          );
                        },
                      ),
                      _menuCard(
                        context,
                        Icons.calendar_today,
                        "Training",
                        "Training schedule",
                        Colors.teal,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TrainingScheduleScreen(),
                            ),
                          );
                        },
                      ),
                      _menuCard(
                        context,
                        Icons.notifications,
                        "Notifications",
                        "Academy updates",
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
          );
        },
      ),
    );
  }

  Widget _topHeader(BuildContext context) {
    return Container(
      color: maroon,
      padding: const EdgeInsets.fromLTRB(16, 45, 16, 20),
      child: Row(
        children: [
          const Icon(Icons.menu, color: Colors.white, size: 28),
          const Spacer(),
          Column(
            children: [
              Text(
                "YGCA",
                style: TextStyle(
                  color: gold,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const Text(
                "YOUNG GEN CRICKET ACADEMY",
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              const SizedBox(height: 4),
              const Text(
                "STUDENT DASHBOARD",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          Stack(
            children: [
              const Icon(Icons.notifications_none, color: Colors.white, size: 28),
              Positioned(
                right: 0,
                top: 0,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.orange,
                  child: const Text(
                    "3",
                    style: TextStyle(fontSize: 9, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
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
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
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
          color: Colors.white,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 23),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: gold, size: 20),
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