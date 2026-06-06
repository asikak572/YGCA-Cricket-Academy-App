import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerformanceReportScreen extends StatelessWidget {
  const PerformanceReportScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Performance Reports"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('performance_reports')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final reports = snapshot.data?.docs ?? [];

          if (reports.isEmpty) {
            return const Center(
              child: Text("No performance reports found"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final data =
                  reports[index].data() as Map<String, dynamic>;

              final name =
                  data['name']?.toString() ?? '';

              final batch =
                  data['batch']?.toString() ?? '';

              final batting =
                  data['batting'] ?? 0;

              final bowling =
                  data['bowling'] ?? 0;

              final fielding =
                  data['fielding'] ?? 0;

              final fitness =
                  data['fitness'] ?? 0;

              final remarks =
                  data['remarks']?.toString() ?? '';

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
                              name.isNotEmpty
                                  ? name[0].toUpperCase()
                                  : "?",
                              style: TextStyle(
                                color: gold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  batch,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.sports_cricket,
                            color: gold,
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      _skillBar(
                        "Batting",
                        batting,
                        Colors.green,
                      ),

                      _skillBar(
                        "Bowling",
                        bowling,
                        Colors.blue,
                      ),

                      _skillBar(
                        "Fielding",
                        fielding,
                        Colors.orange,
                      ),

                      _skillBar(
                        "Fitness",
                        fitness,
                        Colors.purple,
                      ),

                      const SizedBox(height: 12),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                            color: border,
                          ),
                        ),
                        child: Text(
                          "Coach Remarks: $remarks",
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: maroon,
        foregroundColor: gold,
        onPressed: () {
          _showAddDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Report"),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final batchController = TextEditingController();
    final battingController = TextEditingController();
    final bowlingController = TextEditingController();
    final fieldingController = TextEditingController();
    final fitnessController = TextEditingController();
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Performance Report"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _field("Student Name", nameController),
              _field("Batch", batchController),
              _field("Batting %", battingController),
              _field("Bowling %", bowlingController),
              _field("Fielding %", fieldingController),
              _field("Fitness %", fitnessController),
              _field("Coach Remarks", remarksController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('performance_reports')
                  .add({
                'name': nameController.text.trim(),
                'batch': batchController.text.trim(),
                'batting':
                    int.tryParse(battingController.text) ?? 0,
                'bowling':
                    int.tryParse(bowlingController.text) ?? 0,
                'fielding':
                    int.tryParse(fieldingController.text) ?? 0,
                'fitness':
                    int.tryParse(fitnessController.text) ?? 0,
                'remarks':
                    remarksController.text.trim(),
                'createdAt':
                    FieldValue.serverTimestamp(),
              });

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _skillBar(
    String title,
    int value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title),
              ),
              Text(
                "$value%",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value / 100,
            backgroundColor:
                const Color(0xFFE2E8F0),
            color: color,
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}