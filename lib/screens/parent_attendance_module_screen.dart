import 'package:flutter/material.dart';

import 'widgets/ygca_app_bar.dart';

import 'attendance_calendar_screen.dart';
import 'attendance_history_screen.dart';

class ParentAttendanceModuleScreen extends StatelessWidget {
  const ParentAttendanceModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),

      appBar: const YgcaAppBar(title: "Attendance Module"),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: [

            _moduleCard(
              context,
              Icons.calendar_month,
              "Attendance Calendar",
              Colors.orange,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendanceCalendarScreen(
                      name: "",
                      batch: "",
                      rollNo: "",
                      attendance: "0%",
                    ),
                  ),
                );
              },
            ),

            _moduleCard(
              context,
              Icons.history,
              "Attendance History",
              Colors.red,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AttendanceHistoryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _moduleCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color,
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}