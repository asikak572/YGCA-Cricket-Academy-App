import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final parentNameController = TextEditingController();
  final parentPhoneController = TextEditingController();
  final aadhaarController = TextEditingController();
  final batchController = TextEditingController();

  bool isLoading = false;

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);

  Future<void> saveStudent() async {
    if (nameController.text.trim().isEmpty ||
        ageController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        batchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill required fields")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    await FirebaseFirestore.instance.collection('students').add({
      'name': nameController.text.trim(),
      'age': int.tryParse(ageController.text.trim()) ?? 0,
      'phone': phoneController.text.trim(),
      'parentName': parentNameController.text.trim(),
      'parentPhone': parentPhoneController.text.trim(),
      'aadhaarNumber': aadhaarController.text.trim(),
      'batch': batchController.text.trim(),
      'role': 'Student',
      'status': 'Active',
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Student saved to Firebase")),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    parentNameController.dispose();
    parentPhoneController.dispose();
    aadhaarController.dispose();
    batchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            CircleAvatar(
              radius: 42,
              backgroundColor: maroon,
              child: Icon(Icons.camera_alt, color: gold, size: 30),
            ),
            const SizedBox(height: 20),

            _field("Student Name *", nameController),
            _field("Age *", ageController, keyboardType: TextInputType.number),
            _field("Phone Number *", phoneController, keyboardType: TextInputType.phone),
            _field("Parent Name", parentNameController),
            _field("Parent Phone", parentPhoneController, keyboardType: TextInputType.phone),
            _field("Aadhaar Number", aadhaarController, keyboardType: TextInputType.number),
            _field("Batch *", batchController),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroon,
                  foregroundColor: gold,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: isLoading ? null : saveStudent,
                child: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Save Student"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
}