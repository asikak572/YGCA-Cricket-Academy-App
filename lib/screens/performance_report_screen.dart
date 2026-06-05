import 'package:flutter/material.dart';

class PerformanceReportScreen extends StatelessWidget {
  const PerformanceReportScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final players = [
      {
        "name": "Arjun R",
        "batch": "Morning Batch",
        "batting": 82,
        "bowling": 74,
        "fielding": 88,
        "fitness": 79,
        "remarks": "Good improvement in batting footwork.",
      },
      {
        "name": "Kiran M",
        "batch": "Evening Batch",
        "batting": 76,
        "bowling": 81,
        "fielding": 70,
        "fitness": 84,
        "remarks": "Bowling line and length is improving.",
      },
      {
        "name": "Priya S",
        "batch": "Junior Batch",
        "batting": 89,
        "bowling": 68,
        "fielding": 91,
        "fitness": 86,
        "remarks": "Excellent fielding and batting confidence.",
      },
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Performance Reports"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: players.length,
        itemBuilder: (context, index) {
          final player = players[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: maroon,
                        child: Text(
                          player["name"].toString()[0],
                          style: TextStyle(
                            color: gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player["name"].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              player["batch"].toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.sports_cricket, color: gold),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _skillBar("Batting", player["batting"] as int, Colors.green),
                  _skillBar("Bowling", player["bowling"] as int, Colors.blue),
                  _skillBar("Fielding", player["fielding"] as int, Colors.orange),
                  _skillBar("Fitness", player["fitness"] as int, Colors.purple),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: Text(
                      "Coach Remarks: ${player["remarks"]}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _skillBar(String title, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Text(
                "$value%",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value / 100,
            backgroundColor: const Color(0xFFE2E8F0),
            color: color,
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}