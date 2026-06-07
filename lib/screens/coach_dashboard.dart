import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'attendance_screen.dart';
import 'attendance_history_screen.dart';
import 'makeup_session_screen.dart';
import 'leave_request_screen.dart';
import 'performance_report_screen.dart';
import 'student_list_screen.dart';
import 'match_schedule_screen.dart';
import 'training_schedule_screen.dart';
import 'notification_screen.dart';

class CoachDashboard extends StatelessWidget {
  const CoachDashboard({super.key});

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
        title: const Text("Coach Dashboard"),
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
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Coach details not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final name = data['name']?.toString() ?? 'Coach';
          final email = data['email']?.toString() ?? '';
          final role = data['role']?.toString() ?? 'Coach';
          final batch = data['batch']?.toString() ?? 'Batch not assigned';
          final assignedStudents =
              data['assignedStudents']?.toString() ?? 'Not assigned';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _coachCard(
                  name: name,
                  email: email,
                  role: role,
                  batch: batch,
                  assignedStudents: assignedStudents,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _menuCard(context, Icons.check_circle, "Mark Attendance", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AttendanceScreen(),
                        ),
                      );
                    }),
                    _menuCard(context, Icons.people, "My Students", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudentListScreen(),
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
                    _menuCard(context, Icons.history, "Attendance History", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AttendanceHistoryScreen(),
                        ),
                      );
                    }),
                    _menuCard(context, Icons.event_repeat, "Makeup Sessions", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MakeupSessionScreen(),
                        ),
                      );
                    }),
                    _menuCard(context, Icons.event_note, "Leave Requests", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LeaveRequestScreen(),
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
                    _menuCard(context, Icons.calendar_month, "Training", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TrainingScheduleScreen(),
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

  Widget _coachCard({
    required String name,
    required String email,
    required String role,
    required String batch,
    required String assignedStudents,
  }) {
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
            child: Icon(Icons.sports, color: maroon, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  "$role • $batch",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  "Assigned Students: $assignedStudents",
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