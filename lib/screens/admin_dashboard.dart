import 'package:flutter/material.dart';
import 'student_list_screen.dart';
import 'attendance_screen.dart';
import 'attendance_history_screen.dart';
import 'makeup_session_screen.dart';
import 'leave_request_screen.dart';
import 'attendance_report_screen.dart';
import 'cancel_session_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _menuCard(
              context,
              Icons.people,
              "Students",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentListScreen(),
                  ),
                );
              },
            ),

            _menuCard(
              context,
              Icons.check_circle,
              "Attendance",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AttendanceScreen(),
                  ),
                );
              },
            ),

            _menuCard(
              context,
              Icons.history,
              "Attendance History",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AttendanceHistoryScreen(),
                  ),
                );
              },
            ),

            _menuCard(
              context,
              Icons.event_busy,
              "Cancel Session",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CancelSessionScreen(),
                  ),
                );
              },
            ),

            _menuCard(
              context,
              Icons.event_repeat,
              "Makeup Sessions",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MakeupSessionScreen(),
                  ),
                );
              },
            ),

            _menuCard(
              context,
              Icons.event_note,
              "Leave Requests",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LeaveRequestScreen(),
                  ),
                );
              },
            ),

            _menuCard(
              context,
              Icons.analytics,
              "Attendance Reports",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AttendanceReportScreen(),
                  ),
                );
              },
            ),
          ],
        ),
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
            Icon(icon, size: 38, color: gold),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}