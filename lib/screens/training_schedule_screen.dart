import 'package:flutter/material.dart';

class TrainingScheduleScreen extends StatelessWidget {
  const TrainingScheduleScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    final schedules = [
      {
        "day": "Friday",
        "time": "4:00 PM - 6:00 PM",
        "batch": "Evening Batch",
        "type": "Regular Training",
      },
      {
        "day": "Friday",
        "time": "6:00 PM - 8:00 PM",
        "batch": "Flood Light Batch",
        "type": "Nets + Fitness",
      },
      {
        "day": "Saturday",
        "time": "7:00 AM - 9:00 AM",
        "batch": "Morning Batch",
        "type": "Batting & Bowling",
      },
      {
        "day": "Sunday",
        "time": "7:00 AM - 9:00 AM",
        "batch": "Junior Batch",
        "type": "Match Practice",
      },
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Training Schedule"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final item = schedules[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: maroon,
                child: Icon(Icons.calendar_month, color: gold),
              ),
              title: Text(
                item["day"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${item["time"]}\n${item["batch"]} • ${item["type"]}",
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      ),
    );
  }
}