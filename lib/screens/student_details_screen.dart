import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'attendance_calendar_screen.dart';
import 'attendance_history_screen.dart';
import 'digital_id_card_screen.dart';

class StudentDetailsScreen extends StatefulWidget {
  final String studentId;
  final String name;
  final String age;
  final String batch;
  final String rollNo;
  final String parentName;
  final String phone;
  final String attendance;
  final String feeStatus;

  const StudentDetailsScreen({
    super.key,
    required this.studentId,
    required this.name,
    required this.age,
    required this.batch,
    required this.rollNo,
    required this.parentName,
    required this.phone,
    required this.attendance,
    required this.feeStatus,
  });

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

  bool uploading = false;

  String _text(Map<String, dynamic> data, String key, String fallback) {
    final value = data[key];
    if (value == null || value.toString().trim().isEmpty) return fallback;
    return value.toString().trim();
  }

  int _percent(String value) {
    return int.tryParse(value.replaceAll("%", "").trim()) ?? 0;
  }

  String _feeAmount(Map<String, dynamic> data) {
    final pendingAmount = data['pendingAmount'];
    final totalFee = data['totalFee'];
    final paidAmount = data['paidAmount'];

    if (pendingAmount != null) return "₹$pendingAmount";

    if (totalFee != null && paidAmount != null) {
      final total = int.tryParse(totalFee.toString()) ?? 0;
      final paid = int.tryParse(paidAmount.toString()) ?? 0;
      return "₹${total - paid}";
    }

    return "₹0";
  }

  Future<void> _uploadPhoto() async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedImage == null) return;

      setState(() => uploading = true);

      final file = File(pickedImage.path);

      final ref = FirebaseStorage.instance
          .ref()
          .child('student_photos')
          .child('${widget.studentId}.jpg');

      await ref.putFile(file);

      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .update({
        'photoUrl': url,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student photo uploaded")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Photo upload failed: $e")),
      );
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  Future<void> _deleteStudent() async {
    await FirebaseFirestore.instance
        .collection('students')
        .doc(widget.studentId)
        .delete();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Student deleted successfully")),
    );

    Navigator.pop(context);
  }

  Future<void> _updateStudent({
    required String name,
    required String age,
    required String batch,
    required String parentName,
    required String phone,
    required String rollNo,
    required String feeStatus,
  }) async {
    await FirebaseFirestore.instance
        .collection('students')
        .doc(widget.studentId)
        .update({
      'name': name.trim(),
      'age': age.trim(),
      'batch': batch.trim(),
      'parentName': parentName.trim(),
      'phone': phone.trim(),
      'rollNo': rollNo.trim(),
      'feeStatus': feeStatus.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Student updated successfully")),
    );
  }

  void _confirmDelete(String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Student"),
        content: Text("Are you sure you want to delete $name?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _deleteStudent();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> data) {
    final nameController =
        TextEditingController(text: data['name']?.toString() ?? '');
    final ageController =
        TextEditingController(text: data['age']?.toString() ?? '');
    final batchController =
        TextEditingController(text: data['batch']?.toString() ?? '');
    final parentNameController =
        TextEditingController(text: data['parentName']?.toString() ?? '');
    final phoneController =
        TextEditingController(text: data['phone']?.toString() ?? '');
    final rollNoController =
        TextEditingController(text: data['rollNo']?.toString() ?? '');
    final feeStatusController =
        TextEditingController(text: data['feeStatus']?.toString() ?? 'Pending');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Student"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _editField("Student Name", nameController),
              _editField("Age", ageController,
                  keyboardType: TextInputType.number),
              _editField("Batch", batchController),
              _editField("Parent Name", parentNameController),
              _editField("Phone Number", phoneController,
                  keyboardType: TextInputType.phone),
              _editField("Roll No", rollNoController),
              _editField("Fee Status", feeStatusController),
            ],
          ),
        ),
        actions: [
          TextButton(
  onPressed: () {
    Navigator.pop(context);
  },
  child: const Text("Cancel"),
),
          ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: maroon,
    foregroundColor: gold,
  ),
  onPressed: () async {
    await _updateStudent(
      name: nameController.text,
      age: ageController.text,
      batch: batchController.text,
      parentName: parentNameController.text,
      phone: phoneController.text,
      rollNo: rollNoController.text,
      feeStatus: feeStatusController.text,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  },
  child: const Text("Update"),
),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Something went wrong")),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("Student not found")),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        final name = _text(data, 'name', 'No Name');
        final age = _text(data, 'age', '0');
        final batch = _text(data, 'batch', 'No Batch');
        final rollNo = _text(data, 'rollNo', '#YGCA');
        final parentName = _text(data, 'parentName', 'Not Added');
        final phone = _text(data, 'phone', '');
        final attendance = _text(data, 'attendance', '0%');
        final feeStatus = _text(data, 'feeStatus', 'Pending');
        final photoUrl = _text(data, 'photoUrl', '');
        final feeAmount = _feeAmount(data);
        final attendanceValue = _percent(attendance);

        final initials = name
            .split(" ")
            .where((e) => e.isNotEmpty)
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase();

        return Scaffold(
          backgroundColor: bg,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _topHeader(context),
                _profileCard(
                  initials: initials,
                  name: name,
                  batch: batch,
                  rollNo: rollNo,
                  photoUrl: photoUrl,
                ),
                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _summaryCard(
                    attendance: "$attendanceValue%",
                    fee: feeStatus == "Paid" ? "Paid" : feeAmount,
                    batch: batch,
                    rollNo: rollNo,
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _infoCard(
                    title: "STUDENT INFORMATION",
                    children: [
                      _infoRow("Full Name", name),
                      _infoRow("Age", "$age Years"),
                      _infoRow("Parent", parentName),
                      _infoRow("Phone", phone.isEmpty ? "Not Added" : phone),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _infoCard(
                    title: "QUICK ACTIONS",
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _actionCard(
                              Icons.calendar_month,
                              "Attendance",
                              Colors.orange,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AttendanceCalendarScreen(
                                      studentId: widget.studentId,
                                      name: name,
                                      batch: batch,
                                      rollNo: rollNo,
                                      attendance: attendance,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _actionCard(
                              Icons.history,
                              "History",
                              Colors.red,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AttendanceHistoryScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _actionCard(
                              Icons.edit,
                              "Edit",
                              Colors.blue,
                              () => _showEditDialog(data),
                            ),
                          ),


                          const SizedBox(width: 8),

Expanded(
  child: _actionCard(
    Icons.badge,
    "ID Card",
    Colors.green,
    () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DigitalIdCardScreen(
            name: name,
            rollNo: rollNo,
            batch: batch,
            parentName: parentName,
            phone: phone,
            photoUrl: photoUrl,
          ),
        ),
      );
    },
  ),
),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _actionCard(
                              Icons.delete,
                              "Delete",
                              Colors.red,
                              () => _confirmDelete(name),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _topHeader(BuildContext context) {
    return Container(
      color: maroon,
      padding: const EdgeInsets.fromLTRB(14, 42, 14, 14),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Image.asset('assets/images/ygca_logo.jpg', width: 48),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "STUDENT DETAILS",
              style: TextStyle(
                color: gold,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person),
          ),
        ],
      ),
    );
  }

  Widget _profileCard({
    required String initials,
    required String name,
    required String batch,
    required String rollNo,
    required String photoUrl,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: maroon,
        borderRadius: BorderRadius.circular(22),
        image: const DecorationImage(
          image: AssetImage('assets/images/home_hero_bg.png'),
          fit: BoxFit.cover,
          opacity: 0.28,
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white,
                backgroundImage:
                    photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                child: photoUrl.isEmpty
                    ? Text(
                        initials.isEmpty ? "S" : initials,
                        style: TextStyle(
                          color: maroon,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: uploading ? null : _uploadPhoto,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: gold,
                    child: uploading
                        ? SizedBox(
                            height: 13,
                            width: 13,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: maroon,
                            ),
                          )
                        : Icon(Icons.camera_alt, color: maroon, size: 15),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  batch,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Roll No: $rollNo",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 7),
                GestureDetector(
                  onTap: uploading ? null : _uploadPhoto,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: gold),
                    ),
                    child: Text(
                      photoUrl.isEmpty ? "Upload Photo" : "Change Photo",
                      style: TextStyle(
                        color: gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String attendance,
    required String fee,
    required String batch,
    required String rollNo,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  Icons.verified,
                  "Attendance",
                  attendance,
                  Colors.green,
                ),
              ),
              _verticalDivider(),
              Expanded(
                child: _summaryItem(
                  Icons.currency_rupee,
                  "Fee",
                  fee,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  Icons.groups,
                  "Batch",
                  batch,
                  Colors.blue,
                ),
              ),
              _verticalDivider(),
              Expanded(
                child: _summaryItem(
                  Icons.tag,
                  "Roll No",
                  rollNo,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 38,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: border,
    );
  }

  Widget _infoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                color: maroon,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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