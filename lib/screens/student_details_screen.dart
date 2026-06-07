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
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    }
  }

  void confirmDelete(String name) {
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
              await deleteStudent();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void showEditDialog(Map<String, dynamic> data) {
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
              _editField(
                "Age",
                ageController,
                keyboardType: TextInputType.number,
              ),
              _editField("Batch", batchController),
              _editField("Parent Name", parentNameController),
              _editField(
                "Phone Number",
                phoneController,
                keyboardType: TextInputType.phone,
              ),
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
              await updateStudent(
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

  String _text(Map<String, dynamic> data, String key, String fallback) {
    final value = data[key];
    if (value == null) return fallback;

    final text = value.toString().trim();
    if (text.isEmpty) return fallback;

    return text;
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
        final age = _text(data, 'age', '');
        final batch = _text(data, 'batch', 'No Batch');
        final rollNo = _text(data, 'rollNo', '#YGCA');
        final parentName = _text(data, 'parentName', 'Not Added');
        final phone = _text(data, 'phone', '');
        final attendance = _text(data, 'attendance', '0%');
        final feeStatus = _text(data, 'feeStatus', 'Pending');

        final initials = name
            .split(" ")
            .where((e) => e.isNotEmpty)
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase();

        return Scaffold(
          appBar: AppBar(
            title: const Text("Student Details"),
            backgroundColor: maroon,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () => showEditDialog(data),
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () => confirmDelete(name),
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
                    initials.isNotEmpty ? initials : "?",
                    style: TextStyle(
                      color: gold,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "$batch • Roll No: $rollNo",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                _infoTile("Age", age),
                _infoTile("Batch", batch),
                _infoTile("Roll No", rollNo),
                _infoTile("Parent Name", parentName),
                _infoTile("Phone Number", phone),
                _infoTile("Attendance", attendance),
                _infoTile("Fee Status", feeStatus),

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
                                studentId: widget.studentId,
                                name: name,
                                batch: batch,
                                rollNo: rollNo,
                                attendance: attendance,
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
      },
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