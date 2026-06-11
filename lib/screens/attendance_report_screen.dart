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
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data?.docs ?? [];

          int totalRecords = records.length;
          int presentCount = 0;
          int absentCount = 0;

          final Map<String, Map<String, dynamic>> studentSummary = {};
          final Map<String, Map<String, int>> batchSummary = {};

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

            studentSummary.putIfAbsent(studentId, () {
              return {
                'name': studentName,
                'batch': batch,
                'present': 0,
                'absent': 0,
                'total': 0,
              };
            });

            studentSummary[studentId]!['total']++;
            if (status == "Present") {
              studentSummary[studentId]!['present']++;
            } else {
              studentSummary[studentId]!['absent']++;
            }

            batchSummary.putIfAbsent(batch, () {
              return {'present': 0, 'absent': 0, 'total': 0};
            });

            batchSummary[batch]!['total'] =
                (batchSummary[batch]!['total'] ?? 0) + 1;

            if (status == "Present") {
              batchSummary[batch]!['present'] =
                  (batchSummary[batch]!['present'] ?? 0) + 1;
            } else {
              batchSummary[batch]!['absent'] =
                  (batchSummary[batch]!['absent'] ?? 0) + 1;
            }
          }

          final attendancePercent = totalRecords == 0
              ? 0
              : ((presentCount / totalRecords) * 100).round();

          final allStudents = studentSummary.values.toList();

          allStudents.sort((a, b) {
            final aTotal = a['total'] as int;
            final bTotal = b['total'] as int;
            final aPresent = a['present'] as int;
            final bPresent = b['present'] as int;

            final aPercent =
                aTotal == 0 ? 0 : ((aPresent / aTotal) * 100).round();
            final bPercent =
                bTotal == 0 ? 0 : ((bPresent / bTotal) * 100).round();

            return bPercent.compareTo(aPercent);
          });

          final topStudents = allStudents.take(3).toList();

          final lowAttendance = allStudents.where((student) {
            final total = student['total'] as int;
            final present = student['present'] as int;
            final percent = total == 0 ? 0 : ((present / total) * 100).round();
            return percent < 75;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _heroReportCard(context, attendancePercent),
                const SizedBox(height: 16),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.35,
                  children: [
                    _statCard("Total Records", totalRecords.toString(),
                        Icons.list_alt, gold),
                    _statCard("Present", presentCount.toString(),
                        Icons.check_circle, Colors.green),
                    _statCard(
                        "Absent", absentCount.toString(), Icons.cancel, Colors.red),
                    _statCard("Attendance %", "$attendancePercent%",
                        Icons.percent, Colors.blue),
                  ],
                ),

                const SizedBox(height: 18),

                _sectionTitle("Batch Wise Summary"),

                if (batchSummary.isEmpty)
                  _emptySmall("No batch report available")
                else
                  ...batchSummary.entries.map((entry) {
                    final batch = entry.key;
                    final present = entry.value['present'] ?? 0;
                    final absent = entry.value['absent'] ?? 0;
                    final total = entry.value['total'] ?? 0;
                    final percent =
                        total == 0 ? 0 : ((present / total) * 100).round();

                    return _batchCard(
                      batch: batch,
                      present: present,
                      absent: absent,
                      percent: percent,
                    );
                  }),

                const SizedBox(height: 18),

                _sectionTitle("Top Attendance Students"),

                if (topStudents.isEmpty)
                  _emptySmall("No student data available")
                else
                  ...topStudents.map((student) {
                    final total = student['total'] as int;
                    final present = student['present'] as int;
                    final percent =
                        total == 0 ? 0 : ((present / total) * 100).round();

                    return _topStudentCard(
                      name: student['name'].toString(),
                      batch: student['batch'].toString(),
                      percent: percent,
                    );
                  }),

                const SizedBox(height: 18),

                _sectionTitle("Student Attendance Summary"),

                if (studentSummary.isEmpty)
                  _emptySmall("No attendance data available")
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

                const SizedBox(height: 18),

                _sectionTitle("Low Attendance Alert"),

                if (lowAttendance.isEmpty)
                  _successCard()
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

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _heroReportCard(BuildContext context, int attendancePercent) {
    String health = "Needs Attention";
    Color healthColor = Colors.red;

    if (attendancePercent >= 90) {
      health = "Excellent";
      healthColor = Colors.green;
    } else if (attendancePercent >= 75) {
      health = "Good";
      healthColor = Colors.orange;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: maroon,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gold),
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
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: attendancePercent / 100,
            backgroundColor: Colors.white24,
            color: gold,
            minHeight: 8,
          ),
          const SizedBox(height: 10),
          Text(
            "$attendancePercent% overall attendance",
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: healthColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: healthColor),
            ),
            child: Text(
              health,
              style: TextStyle(
                color: healthColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: gold,
              side: BorderSide(color: gold),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("PDF export will be added later")),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text("Export Report"),
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
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
          style: TextStyle(
            color: maroon,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _batchCard({
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
          child: Icon(Icons.groups, color: gold),
        ),
        title: Text(
          batch,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Present: $present • Absent: $absent"),
        trailing: _percentChip(percent),
      ),
    );
  }

  Widget _topStudentCard({
    required String name,
    required String batch,
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
          backgroundColor: gold,
          child: Icon(Icons.emoji_events, color: maroon),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(batch),
        trailing: _percentChip(percent),
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
        trailing: _percentChip(percent),
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
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFEF2F2),
          child: Icon(Icons.warning_amber, color: Colors.red),
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

  Widget _percentChip(int percent) {
    Color color = Colors.red;

    if (percent >= 90) {
      color = Colors.green;
    } else if (percent >= 75) {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "$percent%",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _successCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: const Text(
          "No low attendance students",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text("All students are above 75%"),
      ),
    );
  }

  Widget _emptySmall(String text) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(text),
      ),
    );
  }
}