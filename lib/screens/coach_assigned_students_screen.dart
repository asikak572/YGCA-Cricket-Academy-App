import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoachAssignedStudentsScreen extends StatelessWidget {
  const CoachAssignedStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final coachUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Students"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(coachUid)
            .get(),
        builder: (context, coachSnapshot) {
          if (coachSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!coachSnapshot.hasData ||
              !coachSnapshot.data!.exists) {
            return const Center(
              child: Text("Coach data not found"),
            );
          }

          final coachData =
              coachSnapshot.data!.data() as Map<String, dynamic>;

          final coachBatch =
              coachData['batch']?.toString() ?? '';

          if (coachBatch.isEmpty) {
            return const Center(
              child: Text(
                "No batch assigned to this coach",
              ),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('students')
                .where('batch', isEqualTo: coachBatch)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final students = snapshot.data?.docs ?? [];

              if (students.isEmpty) {
                return Center(
                  child: Text(
                    "No students found in $coachBatch",
                  ),
                );
              }

              return ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final data = students[index].data()
                      as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(
                        data['name'] ?? 'Student',
                      ),
                      subtitle: Text(
                        "Roll No: ${data['rollNo'] ?? '-'}\n"
                        "Batch: ${data['batch'] ?? '-'}",
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
} 