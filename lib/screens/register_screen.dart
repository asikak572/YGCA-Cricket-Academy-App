import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Student Registration"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 46,
              backgroundColor: maroon,
              child: Icon(Icons.camera_alt, color: gold, size: 34),
            ),
            const SizedBox(height: 8),
            const Text("Upload Student Photo"),

            const SizedBox(height: 18),

            _input("Student Name"),
            _input("Age"),
            _input("Batch"),
            _input("Parent Name"),
            _input("Phone Number"),
            _input("Aadhaar Number"),
            _input("Address", maxLines: 3),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroon,
                  foregroundColor: gold,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Student registration submitted"),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add),
                label: const Text("Register Student"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}