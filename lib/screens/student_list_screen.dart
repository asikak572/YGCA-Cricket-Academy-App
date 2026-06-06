import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_student_screen.dart';
import 'student_details_screen.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Students"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students')
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

          final students = snapshot.data!.docs;

          return Column(
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
                    const Text(
                      "Total Students",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      students.length.toString(),
                      style: TextStyle(
                        color: gold,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: students.isEmpty
                    ? const Center(
                        child: Text("No students found"),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final doc = students[index];
                          final data = doc.data() as Map<String, dynamic>;

                          final name = data['name']?.toString() ?? 'No Name';
                          final age = data['age']?.toString() ?? '';
                          final batch = data['batch']?.toString() ?? 'No Batch';
                          final phone = data['phone']?.toString() ?? '';
                          final parentName =
                              data['parentName']?.toString() ?? 'Not Added';
                          final rollNo =
                              data['rollNo']?.toString() ?? '#YGCA';
                          final attendance =
                              data['attendance']?.toString() ?? '0%';
                          final feeStatus =
                              data['feeStatus']?.toString() ?? 'Pending';

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StudentDetailsScreen(
                                      studentId: doc.id,
                                      name: name,
                                      age: age,
                                      batch: batch,
                                      rollNo: rollNo,
                                      parentName: parentName,
                                      phone: phone,
                                      attendance: attendance,
                                      feeStatus: feeStatus,
                                    ),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: maroon,
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                                  style: TextStyle(
                                    color: gold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text("$batch • Active"),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: maroon,
        foregroundColor: gold,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddStudentScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}