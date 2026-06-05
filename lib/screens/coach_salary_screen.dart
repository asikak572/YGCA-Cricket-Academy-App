import 'package:flutter/material.dart';

class CoachSalaryScreen extends StatelessWidget {
  const CoachSalaryScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final coaches = [
      {
        "name": "Coach Sathya",
        "role": "Head Coach",
        "salary": "₹30,000",
        "status": "Paid",
      },
      {
        "name": "Coach Nazeer",
        "role": "Batting Coach",
        "salary": "₹25,000",
        "status": "Pending",
      },
      {
        "name": "Coach Kumar",
        "role": "Fitness Coach",
        "salary": "₹18,000",
        "status": "Paid",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Coach Salary"),
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
                  "Monthly Salary Budget",
                  style: TextStyle(color: gold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  "₹73,000",
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
              itemCount: coaches.length,
              itemBuilder: (context, index) {
                final coach = coaches[index];
                final isPaid = coach["status"] == "Paid";

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: maroon,
                      child: Text(
                        coach["name"]![6],
                        style: TextStyle(
                          color: gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      coach["name"]!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(coach["role"]!),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          coach["salary"]!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          coach["status"]!,
                          style: TextStyle(
                            color: isPaid ? Colors.green : Colors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
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