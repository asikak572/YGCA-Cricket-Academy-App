import 'package:flutter/material.dart';

class AttendanceReportScreen extends StatelessWidget {
  const AttendanceReportScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final lowAttendance = [
      {"name": "Rahul K", "batch": "Senior Batch", "percent": "81%"},
      {"name": "Kiran M", "batch": "Evening Batch", "percent": "85%"},
      {"name": "Siva T", "batch": "Morning Batch", "percent": "89%"},
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Attendance Reports"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _heroReportCard(),

            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.35,
              children: [
                _statCard("Total Students", "5", Icons.people, gold),
                _statCard("Present Today", "3", Icons.check_circle, Colors.green),
                _statCard("Absent Today", "2", Icons.cancel, Colors.red),
                _statCard("Attendance %", "86%", Icons.percent, Colors.blue),
              ],
            ),

            const SizedBox(height: 16),

            _sectionTitle("Session Summary"),

            _summaryTile(
              icon: Icons.event_repeat,
              title: "Makeup Sessions",
              subtitle: "3 scheduled this month",
              value: "3",
              color: Colors.orange,
            ),

            _summaryTile(
              icon: Icons.event_note,
              title: "Leave Requests",
              subtitle: "1 pending, 1 approved, 1 rejected",
              value: "3",
              color: Colors.purple,
            ),

            _summaryTile(
              icon: Icons.calendar_month,
              title: "Cancelled Sessions",
              subtitle: "Heavy rain / ground unavailable",
              value: "2",
              color: Colors.grey,
            ),

            const SizedBox(height: 16),

            _sectionTitle("Low Attendance Alert"),

            ...lowAttendance.map((student) {
              return _studentAlertCard(
                name: student["name"]!,
                batch: student["batch"]!,
                percent: student["percent"]!,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _heroReportCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: maroon,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            "June 2026 Report",
            style: TextStyle(
              color: gold,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Overall academy attendance performance",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          const LinearProgressIndicator(
            value: 0.86,
            backgroundColor: Colors.white24,
            color: Color(0xFFD4AF37),
            minHeight: 7,
          ),
          const SizedBox(height: 8),
          const Text(
            "86% overall attendance",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _summaryTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _studentAlertCard({
    required String name,
    required String batch,
    required String percent,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: maroon,
          child: Text(
            name[0],
            style: TextStyle(color: gold, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(batch),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            percent,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}