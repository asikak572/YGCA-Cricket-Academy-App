import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);

  String selectedBatch = "U15";
  bool isSaving = false;

  final Map<String, bool> attendanceStatus = {};

  Future<void> saveAttendance(List<QueryDocumentSnapshot> students) async {
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No students found in this batch")),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final today = DateTime.now();
      final dateId =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      final batch = FirebaseFirestore.instance.batch();

      for (final student in students) {
        final data = student.data() as Map<String, dynamic>;
        final studentName = data['name']?.toString() ?? 'No Name';
        final isPresent = attendanceStatus[student.id] ?? true;

        final docRef =
            FirebaseFirestore.instance.collection('attendance').doc();

        batch.set(docRef, {
          'studentId': student.id,
          'studentName': studentName,
          'batch': selectedBatch,
          'date': dateId,
          'status': isPresent ? 'Present' : 'Absent',
          'present': isPresent,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attendance saved to Firebase")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving attendance: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final batches = [
      "U15",
      "Senior",
      "Junior Batch",
      "Senior Batch",
      "Morning Batch",
      "Evening Batch",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              value: selectedBatch,
              decoration: const InputDecoration(
                labelText: "Select Batch",
                border: OutlineInputBorder(),
              ),
              items: batches.map((batch) {
                return DropdownMenuItem(
                  value: batch,
                  child: Text(batch),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  selectedBatch = value;
                  attendanceStatus.clear();
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('students')
                  .where('batch', isEqualTo: selectedBatch)
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

                final students = snapshot.data!.docs;

                if (students.isEmpty) {
                  return Center(
                    child: Text("No students found in $selectedBatch"),
                  );
                }

                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: maroon,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Students in $selectedBatch: ${students.length}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final data =
                              student.data() as Map<String, dynamic>;

                          final name =
                              data['name']?.toString() ?? 'No Name';

                          attendanceStatus.putIfAbsent(student.id, () => true);

                          return Card(
                            child: SwitchListTile(
                              activeThumbColor: maroon,
                              title: Text(name),
                              subtitle: Text(
                                attendanceStatus[student.id] == true
                                    ? "Present"
                                    : "Absent",
                              ),
                              value: attendanceStatus[student.id] ?? true,
                              onChanged: (value) {
                                setState(() {
                                  attendanceStatus[student.id] = value;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: maroon,
                            foregroundColor: gold,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: isSaving
                              ? null
                              : () {
                                  saveAttendance(students);
                                },
                          child: isSaving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Save Attendance"),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}