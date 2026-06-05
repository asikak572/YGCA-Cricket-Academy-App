import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        "title": "Training Cancelled",
        "message": "Evening session cancelled due to rain.",
        "time": "10 min ago",
      },
      {
        "title": "Fee Reminder",
        "message": "Fee payment due on 15 June.",
        "time": "1 hour ago",
      },
      {
        "title": "Match Schedule",
        "message": "Match scheduled for Sunday.",
        "time": "Yesterday",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFF7F0000),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF7F0000),
                child: Icon(
                  Icons.notifications,
                  color: Color(0xFFD4AF37),
                ),
              ),
              title: Text(
                item["title"]!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(item["message"]!),
              trailing: Text(
                item["time"]!,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}