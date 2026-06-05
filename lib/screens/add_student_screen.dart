import 'package:flutter/material.dart';

class AddStudentScreen extends StatelessWidget {
  const AddStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const maroon = Color(0xFF7F0000);
    const gold = Color(0xFFD4AF37);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Student"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 42,
              backgroundColor: maroon,
              child: Icon(Icons.camera_alt, color: gold, size: 30),
            ),
            const SizedBox(height: 20),
            _field("Student Name"),
            _field("Age"),
            _field("Phone Number"),
            _field("Parent Name"),
            _field("Parent Phone"),
            _field("Aadhaar Number"),
            _field("Batch"),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroon,
                  foregroundColor: gold,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Student saved")),
                  );
                },
                child: const Text("Save Student"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}