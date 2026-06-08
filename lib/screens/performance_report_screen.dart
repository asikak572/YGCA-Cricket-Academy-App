import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerformanceReportScreen extends StatelessWidget {
  const PerformanceReportScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  int _toInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }

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
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data?.docs ?? [];

          if (reports.isEmpty) {
            return const Center(child: Text("No performance reports found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final data = reports[index].data() as Map<String, dynamic>;

              final name =
                  data['studentName']?.toString() ??
                  data['name']?.toString() ??
                  'Unknown Student';

              final batch = data['batch']?.toString() ?? '';

              final batting = _toInt(data['batting']);
              final bowling = _toInt(data['bowling']);
              final fielding = _toInt(data['fielding']);
              final fitness = _toInt(data['fitness']);

              final remarks = data['remarks']?.toString() ?? '';

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
                              name.isNotEmpty ? name[0].toUpperCase() : "?",
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
                          Icon(Icons.sports_cricket, color: gold),
                        ],
                      ),

                      const SizedBox(height: 14),

                      _skillBar("Batting", batting, Colors.green),
                      _skillBar("Bowling", bowling, Colors.blue),
                      _skillBar("Fielding", fielding, Colors.orange),
                      _skillBar("Fitness", fitness, Colors.purple),

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
                          "Coach Remarks: $remarks",
                          style: const TextStyle(fontSize: 12),
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
    String? selectedStudentId;
    String selectedStudentName = '';
    String selectedBatch = '';

    final battingController = TextEditingController();
    final bowlingController = TextEditingController();
    final fieldingController = TextEditingController();
    final fitnessController = TextEditingController();
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Performance Report"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('students')
                          .orderBy('name')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text("No students found");
                        }

                        final students = snapshot.data!.docs;

                        return DropdownButtonFormField<String>(
                          value: selectedStudentId,
                          decoration: const InputDecoration(
                            labelText: "Select Student",
                            border: OutlineInputBorder(),
                          ),
                          items: students.map((doc) {
                            final data =
                                doc.data() as Map<String, dynamic>;
                            final name =
                                data['name']?.toString() ?? 'No Name';
                            final batch =
                                data['batch']?.toString() ?? 'No Batch';

                            return DropdownMenuItem(
                              value: doc.id,
                              child: Text("$name - $batch"),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;

                            final selectedDoc = students.firstWhere(
                              (doc) => doc.id == value,
                            );

                            final data =
                                selectedDoc.data() as Map<String, dynamic>;

                            setDialogState(() {
                              selectedStudentId = selectedDoc.id;
                              selectedStudentName =
                                  data['name']?.toString() ?? '';
                              selectedBatch =
                                  data['batch']?.toString() ?? '';
                            });
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    _field(
                      "Batting %",
                      battingController,
                      keyboardType: TextInputType.number,
                    ),
                    _field(
                      "Bowling %",
                      bowlingController,
                      keyboardType: TextInputType.number,
                    ),
                    _field(
                      "Fielding %",
                      fieldingController,
                      keyboardType: TextInputType.number,
                    ),
                    _field(
                      "Fitness %",
                      fitnessController,
                      keyboardType: TextInputType.number,
                    ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroon,
                    foregroundColor: gold,
                  ),
                  onPressed: () async {
                    if (selectedStudentId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a student"),
                        ),
                      );
                      return;
                    }

                    final batting =
                        int.tryParse(battingController.text.trim()) ?? 0;
                    final bowling =
                        int.tryParse(bowlingController.text.trim()) ?? 0;
                    final fielding =
                        int.tryParse(fieldingController.text.trim()) ?? 0;
                    final fitness =
                        int.tryParse(fitnessController.text.trim()) ?? 0;

                    await FirebaseFirestore.instance
                        .collection('performance_reports')
                        .add({
                      'studentId': selectedStudentId,
                      'studentName': selectedStudentName,
                      'batch': selectedBatch,
                      'batting': batting,
                      'bowling': bowling,
                      'fielding': fielding,
                      'fitness': fitness,
                      'remarks': remarksController.text.trim(),
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    await FirebaseFirestore.instance
                        .collection('students')
                        .doc(selectedStudentId)
                        .update({
                      'latestBatting': batting,
                      'latestBowling': bowling,
                      'latestFielding': fielding,
                      'latestFitness': fitness,
                      'latestPerformanceRemarks':
                          remarksController.text.trim(),
                      'latestPerformanceUpdatedAt':
                          FieldValue.serverTimestamp(),
                    });

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Performance report saved"),
                        ),
                      );
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
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
    final safeValue = value.clamp(0, 100);

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(title)),
              Text(
                "$safeValue%",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: safeValue / 100,
            backgroundColor: const Color(0xFFE2E8F0),
            color: color,
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}