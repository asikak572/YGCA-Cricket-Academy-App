import 'package:flutter/material.dart';

class MatchScheduleScreen extends StatelessWidget {
  const MatchScheduleScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    final matches = [
      {
        "title": "YGCA vs Rising Stars",
        "date": "15 Jun 2026",
        "time": "7:00 AM",
        "venue": "Valasaravakkam Ground",
        "status": "Upcoming",
      },
      {
        "title": "YGCA vs Chennai Strikers",
        "date": "22 Jun 2026",
        "time": "4:00 PM",
        "venue": "YMCA Ground",
        "status": "Upcoming",
      },
      {
        "title": "YGCA vs Titans Academy",
        "date": "01 Jun 2026",
        "time": "8:00 AM",
        "venue": "Local Turf",
        "status": "Completed",
      },
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Match Schedule"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          final isUpcoming = match["status"] == "Upcoming";

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: maroon,
                child: Icon(Icons.sports_cricket, color: gold),
              ),
              title: Text(
                match["title"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${match["date"]} • ${match["time"]}\n${match["venue"]}",
              ),
              isThreeLine: true,
              trailing: Text(
                match["status"]!,
                style: TextStyle(
                  color: isUpcoming ? Colors.orange : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}