import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceCalendarScreen extends StatelessWidget {
  final String studentId;
  final String name;
  final String batch;
  final String rollNo;
  final String attendance;

  const AttendanceCalendarScreen({
    super.key,
    this.studentId = "",
    this.name = "Arjun R",
    this.batch = "Morning Batch",
    this.rollNo = "#014",
    this.attendance = "0%",
  });

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(" ")
        .map((e) => e.isNotEmpty ? e[0] : "")
        .take(2)
        .join();

    Query query = FirebaseFirestore.instance.collection('attendance');

    if (studentId.isNotEmpty) {
      query = query.where('studentId', isEqualTo: studentId);
    } else {
      query = query.where('studentName', isEqualTo: name);
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Student Attendance"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data?.docs ?? [];

          int present = 0;
          int absent = 0;
          final Map<int, String> dayStatus = {};

          for (final record in records) {
            final data = record.data() as Map<String, dynamic>;

            final date = data['date']?.toString() ?? "";
            final status = data['status']?.toString() ?? "Absent";

            if (status == "Present") {
              present++;
            } else {
              absent++;
            }

            if (date.length >= 10) {
              final day = int.tryParse(date.substring(8, 10));
              if (day != null) {
                dayStatus[day] = status == "Present" ? "P" : "A";
              }
            }
          }

          final total = present + absent;
          final percent = total == 0 ? 0 : ((present / total) * 100).round();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _studentHeader(initials, "$percent%"),
                const SizedBox(height: 14),
                _summaryCard(present, absent, percent),
                const SizedBox(height: 16),
                _legend(),
                const SizedBox(height: 12),
                _calendar(dayStatus),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _studentHeader(String initials, String percent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: maroon,
            child: Text(
              initials,
              style: TextStyle(color: gold, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  "$batch • Roll No: $rollNo",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDF4),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Text(
              percent,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(int present, int absent, int percent) {
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
            "Firebase Attendance",
            style: TextStyle(color: gold, fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Student-wise attendance calendar",
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(title: "Present", value: present.toString()),
              _MiniStat(title: "Absent", value: absent.toString()),
              _MiniStat(title: "Total", value: (present + absent).toString()),
              _MiniStat(title: "Percent", value: "$percent%"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: const [
        _LegendItem(label: "Present", color: Colors.green),
        _LegendItem(label: "Absent", color: Colors.red),
        _LegendItem(label: "No Record", color: Colors.grey),
      ],
    );
  }

  Widget _calendar(Map<int, String> dayStatus) {
    final days = List.generate(30, (index) => index + 1);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              _WeekDay("Sun"),
              _WeekDay("Mon"),
              _WeekDay("Tue"),
              _WeekDay("Wed"),
              _WeekDay("Thu"),
              _WeekDay("Fri"),
              _WeekDay("Sat"),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              final status = dayStatus[day] ?? "";
              return _DayBox(day: day.toString(), status: status);
            },
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;

  const _MiniStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _WeekDay extends StatelessWidget {
  final String text;

  const _WeekDay(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }
}

class _DayBox extends StatelessWidget {
  final String day;
  final String status;

  const _DayBox({required this.day, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.grey.shade100;
    Color textColor = Colors.grey;
    String label = "-";

    if (status == "P") {
      bgColor = Colors.green.shade50;
      textColor = Colors.green;
      label = "P";
    } else if (status == "A") {
      bgColor = Colors.red.shade50;
      textColor = Colors.red;
      label = "A";
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: textColor, fontSize: 9)),
        ],
      ),
    );
  }
}