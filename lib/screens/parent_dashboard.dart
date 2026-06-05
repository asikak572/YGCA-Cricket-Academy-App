import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Parent Dashboard"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _childCard(),

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
                      builder: (_) => const AttendanceCalendarScreen(
                        name: "Arjun R",
                        batch: "Morning Batch",
                        rollNo: "#014",
                        attendance: "92%",
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
      ),
    );
  }

  Widget _childCard() {
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
              "AR",
              style: TextStyle(
                color: maroon,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Arjun R",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Morning Batch • Roll No: #014",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  "Attendance: 92% • Fee: Paid",
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