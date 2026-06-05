import 'package:flutter/material.dart';

class AttendanceCalendarScreen extends StatelessWidget {
  final String name;
  final String batch;
  final String rollNo;
  final String attendance;

  const AttendanceCalendarScreen({
    super.key,
    this.name = "Arjun R",
    this.batch = "Morning Batch",
    this.rollNo = "#014",
    this.attendance = "92%",
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

    final days = [
      "", "", "", "", "", "1P", "2P",
      "3A", "4P", "5P", "6C", "7M", "8P", "9P",
      "10P", "11A", "12P", "13P", "14M", "15P", "16P",
      "17P", "18C", "19P", "20P", "21A", "22P", "23P",
      "24P", "25P", "26M", "27P", "28P", "29", "30",
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Student Attendance"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _studentHeader(initials),
            const SizedBox(height: 14),
            _summaryCard(),
            const SizedBox(height: 16),
            _legend(),
            const SizedBox(height: 12),
            _calendar(days),
          ],
        ),
      ),
    );
  }

  Widget _studentHeader(String initials) {
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
              attendance,
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

  Widget _summaryCard() {
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
            "June 2026 Attendance",
            style: TextStyle(color: gold, fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Student-wise monthly attendance calendar",
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(title: "Present", value: "21"),
              _MiniStat(title: "Absent", value: "3"),
              _MiniStat(title: "Makeup", value: "3"),
              _MiniStat(title: "Cancelled", value: "2"),
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
        _LegendItem(label: "Makeup", color: Colors.orange),
        _LegendItem(label: "Cancelled", color: Colors.grey),
      ],
    );
  }

  Widget _calendar(List<String> days) {
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
              final item = days[index];

              if (item.isEmpty) return const SizedBox();

              final day = item.replaceAll(RegExp(r'[A-Z]'), '');
              final status = item.replaceAll(RegExp(r'[0-9]'), '');

              return _DayBox(day: day, status: status);
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
    Color bgColor = Colors.white;
    Color textColor = Colors.black;
    String label = "";

    if (status == "P") {
      bgColor = Colors.green.shade50;
      textColor = Colors.green;
      label = "P";
    } else if (status == "A") {
      bgColor = Colors.red.shade50;
      textColor = Colors.red;
      label = "A";
    } else if (status == "M") {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange;
      label = "M";
    } else if (status == "C") {
      bgColor = Colors.grey.shade200;
      textColor = Colors.grey;
      label = "C";
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
          if (label.isNotEmpty)
            Text(label, style: TextStyle(color: textColor, fontSize: 9)),
        ],
      ),
    );
  }
}