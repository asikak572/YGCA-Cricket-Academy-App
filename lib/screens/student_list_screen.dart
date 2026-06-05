import 'package:flutter/material.dart';
import 'add_student_screen.dart';
import 'student_details_screen.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final students = [
      {
        "name": "Arjun R",
        "age": "15",
        "batch": "Morning Batch",
        "rollNo": "#014",
        "parentName": "Raj Kumar",
        "phone": "9876543210",
        "attendance": "92%",
        "feeStatus": "Paid",
      },
      {
        "name": "Kiran M",
        "age": "14",
        "batch": "Evening Batch",
        "rollNo": "#015",
        "parentName": "Mohan Kumar",
        "phone": "9876543211",
        "attendance": "85%",
        "feeStatus": "Pending",
      },
      {
        "name": "Priya S",
        "age": "13",
        "batch": "Junior Batch",
        "rollNo": "#016",
        "parentName": "Suresh Kumar",
        "phone": "9876543212",
        "attendance": "96%",
        "feeStatus": "Paid",
      },
      {
        "name": "Rahul K",
        "age": "16",
        "batch": "Senior Batch",
        "rollNo": "#017",
        "parentName": "Karthik Raj",
        "phone": "9876543213",
        "attendance": "81%",
        "feeStatus": "Pending",
      },
      {
        "name": "Siva T",
        "age": "15",
        "batch": "Morning Batch",
        "rollNo": "#018",
        "parentName": "Tamil Selvan",
        "phone": "9876543214",
        "attendance": "89%",
        "feeStatus": "Paid",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Students"),
        backgroundColor: const Color(0xFF7F0000),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF7F0000),
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
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];

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
                            name: student["name"]!,
                            age: student["age"]!,
                            batch: student["batch"]!,
                            rollNo: student["rollNo"]!,
                            parentName: student["parentName"]!,
                            phone: student["phone"]!,
                            attendance: student["attendance"]!,
                            feeStatus: student["feeStatus"]!,
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF7F0000),
                      child: Text(
                        student["name"]![0],
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      student["name"]!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text("${student["batch"]} • Active"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7F0000),
        foregroundColor: const Color(0xFFD4AF37),
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