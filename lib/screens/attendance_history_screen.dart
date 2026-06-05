import 'package:flutter/material.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final students = [
      {
        "name": "Arjun R",
        "present": 25,
        "absent": 2,
        "percentage": "93%"
      },
      {
        "name": "Kiran M",
        "present": 23,
        "absent": 4,
        "percentage": "85%"
      },
      {
        "name": "Priya S",
        "present": 26,
        "absent": 1,
        "percentage": "96%"
      },
      {
        "name": "Rahul K",
        "present": 22,
        "absent": 5,
        "percentage": "81%"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance History"),
        backgroundColor: const Color(0xFF7F0000),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF7F0000),
                child: Text(
                  student["name"].toString()[0],
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ),
              title: Text(student["name"].toString()),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Present Days: ${student["present"]}"),
                  Text("Absent Days: ${student["absent"]}"),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  student["percentage"].toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}