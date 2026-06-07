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
  final rollNoController = TextEditingController();
  final addressController = TextEditingController();

  String feeStatus = "Pending";
  bool isLoading = false;

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);

  Future<void> saveStudent() async {
    if (nameController.text.trim().isEmpty ||
        ageController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        batchController.text.trim().isEmpty ||
        rollNoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill required fields")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('students').add({
        'name': nameController.text.trim(),
        'age': ageController.text.trim(),
        'phone': phoneController.text.trim(),
        'parentName': parentNameController.text.trim(),
        'parentPhone': parentPhoneController.text.trim(),
        'aadhaarNumber': aadhaarController.text.trim(),
        'batch': batchController.text.trim(),
        'rollNo': rollNoController.text.trim(),
        'address': addressController.text.trim(),
        'attendance': '0%',
        'feeStatus': feeStatus,
        'role': 'Student',
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student saved to Firebase")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
    rollNoController.dispose();
    addressController.dispose();
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
            _field("Roll No *", rollNoController),
            _field("Address", addressController, maxLines: 3),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                value: feeStatus,
                decoration: const InputDecoration(
                  labelText: "Fee Status",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "Pending", child: Text("Pending")),
                  DropdownMenuItem(value: "Paid", child: Text("Paid")),
                  DropdownMenuItem(value: "Partial", child: Text("Partial")),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    feeStatus = value;
                  });
                },
              ),
            ),

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
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ).copyWith(labelText: label),
      ),
    );
  }
}