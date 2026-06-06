import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'attendance_calendar_screen.dart';
import 'attendance_history_screen.dart';

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

  Future<void> deleteStudent() async {
    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student deleted successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: $e")),
      );
    }
  }

  Future<void> updateStudent({
    required String name,
    required String age,
    required String batch,
    required String parentName,
    required String phone,
    required String rollNo,
    required String feeStatus,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .update({
        'name': name.trim(),
        'age': int.tryParse(age.trim()) ?? 0,
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

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    }
  }

  void confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Student"),
        content: Text("Are you sure you want to delete ${widget.name}?"),
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
              await deleteStudent();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void showEditDialog() {
    final nameController = TextEditingController(text: widget.name);
    final ageController = TextEditingController(text: widget.age);
    final batchController = TextEditingController(text: widget.batch);
    final parentNameController = TextEditingController(text: widget.parentName);
    final phoneController = TextEditingController(text: widget.phone);
    final rollNoController = TextEditingController(text: widget.rollNo);
    final feeStatusController = TextEditingController(text: widget.feeStatus);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Student"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _editField("Student Name", nameController),
              _editField("Age", ageController, keyboardType: TextInputType.number),
              _editField("Batch", batchController),
              _editField("Parent Name", parentNameController),
              _editField("Phone Number", phoneController, keyboardType: TextInputType.phone),
              _editField("Roll No", rollNoController),
              _editField("Fee Status", feeStatusController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              nameController.dispose();
              ageController.dispose();
              batchController.dispose();
              parentNameController.dispose();
              phoneController.dispose();
              rollNoController.dispose();
              feeStatusController.dispose();
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
              await updateStudent(
                name: nameController.text,
                age: ageController.text,
                batch: batchController.text,
                parentName: parentNameController.text,
                phone: phoneController.text,
                rollNo: rollNoController.text,
                feeStatus: feeStatusController.text,
              );

              nameController.dispose();
              ageController.dispose();
              batchController.dispose();
              parentNameController.dispose();
              phoneController.dispose();
              rollNoController.dispose();
              feeStatusController.dispose();

              if (mounted) Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.name
        .split(" ")
        .map((e) => e.isNotEmpty ? e[0] : "")
        .take(2)
        .join();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Details"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: showEditDialog,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: confirmDelete,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: maroon,
              child: Text(
                initials,
                style: TextStyle(
                  color: gold,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "${widget.batch} • Roll No: ${widget.rollNo}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _infoTile("Age", widget.age),
            _infoTile("Batch", widget.batch),
            _infoTile("Roll No", widget.rollNo),
            _infoTile("Parent Name", widget.parentName),
            _infoTile("Phone Number", widget.phone),
            _infoTile("Attendance", widget.attendance),
            _infoTile("Fee Status", widget.feeStatus),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroon,
                      foregroundColor: gold,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttendanceCalendarScreen(
                            name: widget.name,
                            batch: widget.batch,
                            rollNo: widget.rollNo,
                            attendance: widget.attendance,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: const Text("Calendar"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroon,
                      foregroundColor: gold,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AttendanceHistoryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text("History"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
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