import 'package:flutter/material.dart';
import 'student_list_screen.dart';
import 'attendance_screen.dart';
import 'attendance_history_screen.dart';
import 'makeup_session_screen.dart';
import 'leave_request_screen.dart';
import 'attendance_report_screen.dart';
import 'cancel_session_screen.dart';
import 'fee_report_screen.dart';
import 'payment_history_screen.dart';
import 'pending_fees_screen.dart';
import 'coach_salary_screen.dart';
import 'match_schedule_screen.dart';
import 'performance_report_screen.dart';
import 'training_schedule_screen.dart';
import 'notification_screen.dart';
import 'coach_management_screen.dart';

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
            _menuCard(context, Icons.people, "Students", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentListScreen()),
              );
            }),
            _menuCard(context, Icons.sports, "Coach Management", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CoachManagementScreen()),
              );
            }),
            _menuCard(context, Icons.check_circle, "Attendance", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AttendanceScreen()),
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
            _menuCard(context, Icons.event_busy, "Cancel Session", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CancelSessionScreen()),
              );
            }),
            _menuCard(context, Icons.event_repeat, "Makeup Sessions", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MakeupSessionScreen()),
              );
            }),
            _menuCard(context, Icons.event_note, "Leave Requests", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeaveRequestScreen()),
              );
            }),
            _menuCard(context, Icons.analytics, "Attendance Reports", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AttendanceReportScreen(),
                ),
              );
            }),
            _menuCard(context, Icons.receipt_long, "Fee Reports", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeeReportScreen()),
              );
            }),
            _menuCard(context, Icons.payments, "Payment History", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PaymentHistoryScreen(),
                ),
              );
            }),
            _menuCard(context, Icons.warning_amber, "Pending Fees", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PendingFeesScreen()),
              );
            }),
            _menuCard(context, Icons.account_balance_wallet, "Coach Salary", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CoachSalaryScreen()),
              );
            }),
            _menuCard(context, Icons.sports_cricket, "Match Schedule", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MatchScheduleScreen()),
              );
            }),
            _menuCard(context, Icons.bar_chart, "Performance Reports", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PerformanceReportScreen(),
                ),
              );
            }),
            _menuCard(context, Icons.calendar_month, "Training Schedule", () {
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
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            }),
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