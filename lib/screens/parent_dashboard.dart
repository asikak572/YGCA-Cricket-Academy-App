import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'notification_screen.dart';
import 'leave_request_screen.dart';
import 'widgets/ygca_dashboard_header.dart';
import 'parent_attendance_module_screen.dart';
import 'parent_fee_module_screen.dart';
import 'parent_schedule_module_screen.dart';
import 'parent_performance_module_screen.dart';
import 'edit_profile_screen.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

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

  int _percentValue(String text) {
    return int.tryParse(text.replaceAll("%", "").trim()) ?? 0;
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
            return const Center(child: Text("Parent details not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final parentName = _safeText(data, ['name'], 'Parent');
          final parentEmail = _safeText(
            data,
            ['email'],
            currentUser.email ?? '',
          );

          final childName = _safeText(
            data,
            ['childName', 'studentName', 'nameOfChild'],
            'Child not assigned',
          );

          final childBatch = _safeText(
            data,
            ['childBatch', 'batch'],
            'Batch not assigned',
          );

          final rollNo = _safeText(
            data,
            ['childRollNo', 'rollNo'],
            'Not assigned',
          );

          final attendance = _safeText(
            data,
            ['attendance', 'childAttendance', 'attendancePercentage'],
            '0%',
          );

          final feeStatus = _safeText(
            data,
            ['feeStatus', 'fee'],
            'Pending',
          );

          final attendanceNumber = _percentValue(attendance);

          return SingleChildScrollView(
            child: Column(
              children: [
                YgcaDashboardHeader(
                  dashboardTitle: "PARENT DASHBOARD",
                  onLogout: () => _logout(context),
                  useLogoLayout: true,
                  dynamicSubtitle: "Welcome, $parentName",
                ),
                _childHero(
                  childName: childName,
                  parentName: parentName,
                  parentEmail: parentEmail,
                  childBatch: childBatch,
                  rollNo: rollNo,
                  attendance: attendance,
                  feeStatus: feeStatus,
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
                      _statCard(
                        Icons.verified,
                        "ATTENDANCE",
                        "$attendanceNumber%",
                        attendanceNumber >= 75
                            ? "Good Progress"
                            : "Needs Focus",
                        Colors.green,
                      ),
                      _statCard(
                        Icons.currency_rupee,
                        "FEE STATUS",
                        feeStatus,
                        feeStatus == "Paid" ? "No Due" : "Check Fees",
                        Colors.orange,
                      ),
                      _statCard(
                        Icons.groups,
                        "BATCH",
                        childBatch,
                        "Assigned",
                        Colors.blue,
                      ),
                      _statCard(
                        Icons.tag,
                        "ROLL NO.",
                        rollNo,
                        "Student ID",
                        Colors.purple,
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
                    childAspectRatio: 1.45,
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
                              builder: (_) =>
                                  const ParentAttendanceModuleScreen(),
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
                                  const ParentPerformanceModuleScreen(),
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
                              builder: (_) => const ParentFeeModuleScreen(),
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
                              builder: (_) =>
                                  const ParentScheduleModuleScreen(),
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
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                _sectionTitle("RECENT ACTIVITY"),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _activityCard(),
                ),

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



  Widget _childHero({
    required String childName,
    required String parentName,
    required String parentEmail,
    required String childBatch,
    required String rollNo,
    required String attendance,
    required String feeStatus,
  }) {
    final initials = childName
        .split(" ")
        .where((part) => part.isNotEmpty)
        .map((part) => part[0])
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      height: 240,
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
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: Text(
                    initials.isNotEmpty ? initials : "C",
                    style: TextStyle(
                      color: maroon,
                      fontSize: 32,
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
                        childName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        "$childBatch • Roll No: $rollNo",
                        style: TextStyle(
                          color: gold,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Parent: $parentName",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        parentEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _heroChip("Attendance: $attendance"),
                          _heroChip("Fee: $feeStatus"),
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
              fontSize: 18,
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
            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _activityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          _activityRow(
            Icons.check_circle,
            "Attendance updated recently",
            Colors.green,
          ),
          _activityRow(
            Icons.sports_cricket,
            "Training schedule available",
            Colors.blue,
          ),
          _activityRow(
            Icons.payments,
            "Fee status is visible",
            Colors.orange,
          ),
          _activityRow(
            Icons.notifications,
            "New academy notifications",
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _activityRow(IconData icon, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
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
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
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