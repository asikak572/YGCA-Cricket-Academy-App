import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Coach Dashboard"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _coachCard(),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _menuCard(context, Icons.check_circle, "Mark Attendance", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
                }),
                _menuCard(context, Icons.people, "My Students", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentListScreen()));
                }),
                _menuCard(context, Icons.bar_chart, "Performance", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PerformanceReportScreen()));
                }),
                _menuCard(context, Icons.history, "Attendance History", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()));
                }),
                _menuCard(context, Icons.event_repeat, "Makeup Sessions", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MakeupSessionScreen()));
                }),
                _menuCard(context, Icons.event_note, "Leave Requests", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaveRequestScreen()));
                }),
                _menuCard(context, Icons.sports_cricket, "Matches", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MatchScheduleScreen()));
                }),
                _menuCard(context, Icons.calendar_month, "Training", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainingScheduleScreen()));
                }),
                _menuCard(context, Icons.notifications, "Notifications", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _coachCard() {
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Coach Sathya",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Head Coach • Senior Batch",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  "Assigned Students: 25",
                  style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12),
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