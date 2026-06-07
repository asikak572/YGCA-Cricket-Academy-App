import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'attendance_calendar_screen.dart';
import 'attendance_history_screen.dart';
import 'performance_report_screen.dart';
import 'fee_report_screen.dart';
import 'match_schedule_screen.dart';
import 'notification_screen.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
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
      appBar: AppBar(
        title: const Text("Parent Dashboard"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _childCard(
                  parentName: parentName,
                  parentEmail: parentEmail,
                  childName: childName,
                  childBatch: childBatch,
                  rollNo: rollNo,
                  attendance: attendance,
                  feeStatus: feeStatus,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _menuCard(context, Icons.calendar_month, "Attendance", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttendanceCalendarScreen(
                            name: childName,
                            batch: childBatch,
                            rollNo: rollNo,
                            attendance: attendance,
                          ),
                        ),
                      );
                    }),
                    _menuCard(context, Icons.history, "History", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AttendanceHistoryScreen(),
                        ),
                      );
                    }),
                    _menuCard(context, Icons.bar_chart, "Performance", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PerformanceReportScreen(),
                        ),
                      );
                    }),
                    _menuCard(context, Icons.payments, "Fee Status", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FeeReportScreen(),
                        ),
                      );
                    }),
                    _menuCard(context, Icons.sports_cricket, "Matches", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MatchScheduleScreen(),
                        ),
                      );
                    }),
                    _menuCard(context, Icons.notifications, "Notifications", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _childCard({
    required String parentName,
    required String parentEmail,
    required String childName,
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: maroon,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              initials.isNotEmpty ? initials : "C",
              style: TextStyle(
                color: maroon,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  childName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Parent: $parentName",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  parentEmail,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  "$childBatch • Roll No: $rollNo",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  "Attendance: $attendance • Fee: $feeStatus",
                  style: TextStyle(color: gold, fontSize: 12),
                ),
              ],
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
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: gold),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}