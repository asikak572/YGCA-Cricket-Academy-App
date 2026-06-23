import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoachAssignedStudentsScreen extends StatelessWidget {
  const CoachAssignedStudentsScreen({super.key});

  List<String> _getAssignedBatches(Map<String, dynamic> coachData) {
    final assignedBatches = coachData['assignedBatches'];

    if (assignedBatches is List && assignedBatches.isNotEmpty) {
      return assignedBatches
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final singleBatch = coachData['batch']?.toString().trim() ?? '';
    if (singleBatch.isNotEmpty) return [singleBatch];

    final assignedBatch = coachData['assignedBatch']?.toString().trim() ?? '';
    if (assignedBatch.isNotEmpty) return [assignedBatch];

    return [];
  }

  Stream<QuerySnapshot> _studentStream(List<String> assignedBatches) {
    final studentsRef = FirebaseFirestore.instance.collection('students');

    if (assignedBatches.length == 1) {
      return studentsRef
          .where('batch', isEqualTo: assignedBatches.first)
          .snapshots();
    }

    return studentsRef.where('batch', whereIn: assignedBatches).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final coachUid = FirebaseAuth.instance.currentUser?.uid;

    if (coachUid == null) {
      return const Scaffold(
        body: Center(child: Text("No coach logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Students"),
        backgroundColor: const Color(0xFF7F0000),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(coachUid).get(),
        builder: (context, coachSnapshot) {
          if (coachSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (coachSnapshot.hasError) {
            return Center(child: Text("Error: ${coachSnapshot.error}"));
          }

          if (!coachSnapshot.hasData || !coachSnapshot.data!.exists) {
            return const Center(child: Text("Coach data not found"));
          }

          final coachData = coachSnapshot.data!.data() as Map<String, dynamic>;
          final assignedBatches = _getAssignedBatches(coachData);

          if (assignedBatches.isEmpty) {
            return const Center(
              child: Text("No batch assigned to this coach"),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: _studentStream(assignedBatches),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final students = snapshot.data?.docs ?? [];

              if (students.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      "No students found in assigned batches:\n${assignedBatches.join('\n')}",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBF2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD4AF37)),
                    ),
                    child: Text(
                      "Assigned Batches:\n${assignedBatches.join('\n')}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final data = students[index].data() as Map<String, dynamic>;

                        final name = data['name']?.toString() ?? 'Student';
                        final rollNo = data['rollNo']?.toString() ?? '-';
                        final batch = data['batch']?.toString() ?? '-';
                        final phone = data['phone']?.toString() ?? '-';
                        final status = data['status']?.toString() ?? 'Active';

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF7F0000),
                              child: Icon(Icons.person, color: Color(0xFFD4AF37)),
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Roll No: $rollNo\n"
                              "Batch: $batch\n"
                              "Phone: $phone\n"
                              "Status: $status",
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
