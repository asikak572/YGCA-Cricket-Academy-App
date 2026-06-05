import 'package:flutter/material.dart';

class PendingFeesScreen extends StatelessWidget {
  const PendingFeesScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final pendingStudents = [
      {
        "name": "Kiran M",
        "batch": "Evening Batch",
        "amount": "₹4,000",
      },
      {
        "name": "Priya S",
        "batch": "Junior Batch",
        "amount": "₹5,000",
      },
      {
        "name": "Rahul K",
        "batch": "Senior Batch",
        "amount": "₹3,000",
      },
      {
        "name": "Siva T",
        "batch": "Morning Batch",
        "amount": "₹2,500",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Fees"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: maroon,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  "Total Pending Amount",
                  style: TextStyle(
                    color: gold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "₹14,500",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: pendingStudents.length,
              itemBuilder: (context, index) {
                final student = pendingStudents[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: maroon,
                      child: Text(
                        student["name"]![0],
                        style: TextStyle(
                          color: gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      student["name"]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(student["batch"]!),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          student["amount"]!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Pending",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}