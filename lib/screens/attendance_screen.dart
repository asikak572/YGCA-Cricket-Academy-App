import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);

  String selectedBatch = "Junior Batch";

  final List<Map<String, dynamic>> students = [
    {"name": "Arjun R", "present": true},
    {"name": "Kiran M", "present": true},
    {"name": "Priya S", "present": false},
    {"name": "Rahul K", "present": true},
    {"name": "Siva T", "present": false},
  ];

  @override
  Widget build(BuildContext context) {
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
              initialValue: selectedBatch,
              decoration: const InputDecoration(
                labelText: "Select Batch",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "Junior Batch", child: Text("Junior Batch")),
                DropdownMenuItem(value: "Senior Batch", child: Text("Senior Batch")),
                DropdownMenuItem(value: "Morning Batch", child: Text("Morning Batch")),
                DropdownMenuItem(value: "Evening Batch", child: Text("Evening Batch")),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  selectedBatch = value;
                });
              },
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: students.length,
              itemBuilder: (context, index) {
                return Card(
                  child: SwitchListTile(
                    activeThumbColor: maroon,
                    title: Text(students[index]["name"]),
                    subtitle: Text(
                      students[index]["present"] ? "Present" : "Absent",
                    ),
                    value: students[index]["present"],
                    onChanged: (value) {
                      setState(() {
                        students[index]["present"] = value;
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Attendance saved successfully"),
                    ),
                  );
                },
                child: const Text("Save Attendance"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}