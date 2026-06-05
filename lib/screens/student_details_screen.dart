import 'package:flutter/material.dart';
import 'attendance_calendar_screen.dart';
import 'attendance_history_screen.dart';

class StudentDetailsScreen extends StatelessWidget {
  final String name;
  final String age;
  final String batch;
  final String rollNo;
  final String parentName;
  final String phone;
  final String attendance;
  final String feeStatus;

  const StudentDetailsScreen({
    super.key,
    required this.name,
    required this.age,
    required this.batch,
    required this.rollNo,
    required this.parentName,
    required this.phone,
    required this.attendance,
    required this.feeStatus,
  });

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(" ")
        .map((e) => e.isNotEmpty ? e[0] : "")
        .take(2)
        .join();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Details"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: maroon,
              child: Text(
                initials,
                style: TextStyle(
                  color: gold,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "$batch • Roll No: $rollNo",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            _infoTile("Age", age),
            _infoTile("Batch", batch),
            _infoTile("Roll No", rollNo),
            _infoTile("Parent Name", parentName),
            _infoTile("Phone Number", phone),
            _infoTile("Attendance", attendance),
            _infoTile("Fee Status", feeStatus),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroon,
                      foregroundColor: gold,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttendanceCalendarScreen(
                            name: name,
                            batch: batch,
                            rollNo: rollNo,
                            attendance: attendance,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: const Text("Calendar"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroon,
                      foregroundColor: gold,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AttendanceHistoryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text("History"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}