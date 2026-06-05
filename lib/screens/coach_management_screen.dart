import 'package:flutter/material.dart';

class CoachManagementScreen extends StatelessWidget {
  const CoachManagementScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    final coaches = [
      {
        "name": "Coach Sathya",
        "role": "Head Coach",
        "phone": "9941411006",
        "batch": "Senior Batch",
      },
      {
        "name": "Coach Nazeer",
        "role": "Batting Coach",
        "phone": "8939299555",
        "batch": "Morning Batch",
      },
      {
        "name": "Coach Kumar",
        "role": "Fitness Coach",
        "phone": "9876543210",
        "batch": "Junior Batch",
      },
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Coach Management"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: coaches.length,
        itemBuilder: (context, index) {
          final coach = coaches[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: maroon,
                child: Icon(Icons.sports, color: gold),
              ),
              title: Text(
                coach["name"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${coach["role"]}\n${coach["batch"]} • ${coach["phone"]}",
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: maroon,
        foregroundColor: gold,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Add coach feature coming next")),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Coach"),
      ),
    );
  }
}