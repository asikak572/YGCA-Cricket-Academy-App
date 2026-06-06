import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceReportScreen extends StatelessWidget {
  const AttendanceReportScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Attendance Reports"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data?.docs ?? [];

          int totalRecords = records.length;
          int presentCount = 0;
          int absentCount = 0;

          final Map<String, Map<String, dynamic>> studentSummary = {};

          for (final record in records) {
            final data = record.data() as Map<String, dynamic>;

            final studentId = data['studentId']?.toString() ?? '';
            final studentName = data['studentName']?.toString() ?? 'No Name';
            final batch = data['batch']?.toString() ?? 'No Batch';
            final status = data['status']?.toString() ?? 'Absent';

            if (status == "Present") {
              presentCount++;
            } else {
              absentCount++;
            }

            if (!studentSummary.containsKey(studentId)) {
              studentSummary[studentId] = {
                'name': studentName,
                'batch': batch,
                'present': 0,
                'absent': 0,
                'total': 0,
              };
            }

            studentSummary[studentId]!['total'] =
                studentSummary[studentId]!['total'] + 1;

            if (status == "Present") {
              studentSummary[studentId]!['present'] =
                  studentSummary[studentId]!['present'] + 1;
            } else {
              studentSummary[studentId]!['absent'] =
                  studentSummary[studentId]!['absent'] + 1;
            }
          }

          final attendancePercent = totalRecords == 0
              ? 0
              : ((presentCount / totalRecords) * 100).round();

          final lowAttendance = studentSummary.values.where((student) {
            final total = student['total'] as int;
            final present = student['present'] as int;
            final percent = total == 0 ? 0 : ((present / total) * 100).round();
            return percent < 90;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _heroReportCard(attendancePercent),
                const SizedBox(height: 16),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.35,
                  children: [
                    _statCard(
                      "Total Records",
                      totalRecords.toString(),
                      Icons.list_alt,
                      gold,
                    ),
                    _statCard(
                      "Present",
                      presentCount.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _statCard(
                      "Absent",
                      absentCount.toString(),
                      Icons.cancel,
                      Colors.red,
                    ),
                    _statCard(
                      "Attendance %",
                      "$attendancePercent%",
                      Icons.percent,
                      Colors.blue,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _sectionTitle("Student Attendance Summary"),

                if (studentSummary.isEmpty)
                  const Card(
                    child: ListTile(
                      title: Text("No attendance data available"),
                    ),
                  )
                else
                  ...studentSummary.values.map((student) {
                    final total = student['total'] as int;
                    final present = student['present'] as int;
                    final absent = student['absent'] as int;
                    final percent =
                        total == 0 ? 0 : ((present / total) * 100).round();

                    return _studentSummaryCard(
                      name: student['name'].toString(),
                      batch: student['batch'].toString(),
                      present: present,
                      absent: absent,
                      percent: percent,
                    );
                  }),

                const SizedBox(height: 16),

                _sectionTitle("Low Attendance Alert"),

                if (lowAttendance.isEmpty)
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text("No low attendance students"),
                      subtitle: Text("All students are above 90%"),
                    ),
                  )
                else
                  ...lowAttendance.map((student) {
                    final total = student['total'] as int;
                    final present = student['present'] as int;
                    final percent =
                        total == 0 ? 0 : ((present / total) * 100).round();

                    return _studentAlertCard(
                      name: student['name'].toString(),
                      batch: student['batch'].toString(),
                      percent: "$percent%",
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _heroReportCard(int attendancePercent) {
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
            "Attendance Report",
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
          LinearProgressIndicator(
            value: attendancePercent / 100,
            backgroundColor: Colors.white24,
            color: gold,
            minHeight: 7,
          ),
          const SizedBox(height: 8),
          Text(
            "$attendancePercent% overall attendance",
            style: const TextStyle(color: Colors.white, fontSize: 12),
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

  Widget _studentSummaryCard({
    required String name,
    required String batch,
    required int present,
    required int absent,
    required int percent,
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
            name.isNotEmpty ? name[0].toUpperCase() : "?",
            style: TextStyle(color: gold, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$batch\nPresent: $present • Absent: $absent"),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: percent >= 90
                ? Colors.green.withOpacity(0.12)
                : Colors.red.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "$percent%",
            style: TextStyle(
              color: percent >= 90 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
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
            name.isNotEmpty ? name[0].toUpperCase() : "?",
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