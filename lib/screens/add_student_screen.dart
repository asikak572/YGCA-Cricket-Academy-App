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
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

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

    setState(() => isLoading = true);

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
        const SnackBar(content: Text("Student saved successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
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
      backgroundColor: bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _topHeader(context),
            _heroBanner(),
            const SizedBox(height: 18),
            _sectionTitle("STUDENT INFORMATION"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _field("Student Name *", nameController, Icons.person),
                  _field(
                    "Age *",
                    ageController,
                    Icons.cake,
                    keyboardType: TextInputType.number,
                  ),
                  _field(
                    "Phone Number *",
                    phoneController,
                    Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  _field("Batch *", batchController, Icons.groups),
                  _field("Roll No *", rollNoController, Icons.tag),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _sectionTitle("PARENT / GUARDIAN"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _field("Parent Name", parentNameController, Icons.family_restroom),
                  _field(
                    "Parent Phone",
                    parentPhoneController,
                    Icons.call,
                    keyboardType: TextInputType.phone,
                  ),
                  _field(
                    "Aadhaar Number",
                    aadhaarController,
                    Icons.badge,
                    keyboardType: TextInputType.number,
                  ),
                  _field(
                    "Address",
                    addressController,
                    Icons.location_on,
                    maxLines: 3,
                  ),
                  _feeDropdown(),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _saveButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _topHeader(BuildContext context) {
    return Container(
      color: maroon,
      padding: const EdgeInsets.fromLTRB(16, 45, 16, 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Image.asset('assets/images/ygca_logo.jpg', width: 58),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "ADD STUDENT",
              style: TextStyle(
                color: gold,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person_add, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _heroBanner() {
    return Container(
      height: 230,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        border: Border.all(color: gold, width: 1),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_hero_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    darkMaroon.withOpacity(0.96),
                    maroon.withOpacity(0.70),
                    Colors.black.withOpacity(0.38),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person_add_alt_1, color: maroon, size: 42),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "NEW PLAYER",
                        style: TextStyle(
                          color: gold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "STUDENT",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 31,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      Text(
                        "REGISTRATION",
                        style: TextStyle(
                          color: gold,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _heroChip("Create student profile"),
                      const SizedBox(height: 6),
                      _heroChip("Attendance • Fees • Reports"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.7)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: gold,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: maroon,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 42, height: 2, color: gold),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: maroon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: border),
          ),
        ),
      ),
    );
  }

  Widget _feeDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: feeStatus,
        decoration: InputDecoration(
          labelText: "Fee Status",
          prefixIcon: Icon(Icons.payments, color: maroon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: border),
          ),
        ),
        items: const [
          DropdownMenuItem(value: "Pending", child: Text("Pending")),
          DropdownMenuItem(value: "Paid", child: Text("Paid")),
          DropdownMenuItem(value: "Partial", child: Text("Partial")),
        ],
        onChanged: (value) {
          if (value == null) return;
          setState(() => feeStatus = value);
        },
      ),
    );
  }

  Widget _saveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: maroon,
            foregroundColor: gold,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: isLoading ? null : saveStudent,
          icon: isLoading
              ? const SizedBox()
              : const Icon(Icons.save_alt, size: 22),
          label: isLoading
              ? CircularProgressIndicator(color: gold, strokeWidth: 2)
              : const Text(
                  "SAVE STUDENT",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
        ),
      ),
    );
  }
}