import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

  String selectedBatch = "U15";
  bool isSaving = false;

  final Map<String, bool> attendanceStatus = {};

  Future<void> saveAttendance(List<QueryDocumentSnapshot> students) async {
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No students found in this batch")),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final today = DateTime.now();
      final dateId =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      final firestore = FirebaseFirestore.instance;
      final batchWrite = firestore.batch();

      for (final student in students) {
        final data = student.data() as Map<String, dynamic>;
        final studentName = data['name']?.toString() ?? 'No Name';
        final isPresent = attendanceStatus[student.id] ?? true;

        final attendanceDoc =
            firestore.collection('attendance').doc("${student.id}_$dateId");

        batchWrite.set(attendanceDoc, {
          'studentId': student.id,
          'studentName': studentName,
          'batch': selectedBatch,
          'date': dateId,
          'status': isPresent ? 'Present' : 'Absent',
          'present': isPresent,
          'createdAt': FieldValue.serverTimestamp(),
        });

        final oldPresent =
            int.tryParse(data['presentCount']?.toString() ?? '0') ?? 0;
        final oldTotal =
            int.tryParse(data['totalAttendanceCount']?.toString() ?? '0') ?? 0;

        final newPresent = oldPresent + (isPresent ? 1 : 0);
        final newTotal = oldTotal + 1;
        final percentage =
            newTotal == 0 ? 0 : ((newPresent / newTotal) * 100).round();

        batchWrite.update(
          firestore.collection('students').doc(student.id),
          {
            'presentCount': newPresent,
            'totalAttendanceCount': newTotal,
            'attendance': "$percentage%",
            'lastAttendanceDate': dateId,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
        if (!isPresent) {
  await NotificationService.attendanceAlert(
    studentName: studentName,
    studentId: student.id,
    batch: selectedBatch,
  );
}
      }

      await batchWrite.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attendance saved successfully")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving attendance: $e")),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final batches = [
      "U15",
      "Senior",
      "Junior Batch",
      "Senior Batch",
      "Morning Batch",
      "Evening Batch",
    ];

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          _topHeader(context),
          _batchSelector(batches),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('students')
                  .where('batch', isEqualTo: selectedBatch)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final students = snapshot.data?.docs ?? [];

                if (students.isEmpty) {
                  return Center(
                    child: Text(
                      "No students found in $selectedBatch",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }

                int presentCount = 0;
                int absentCount = 0;

                for (final student in students) {
                  attendanceStatus.putIfAbsent(student.id, () => true);
                  if (attendanceStatus[student.id] == true) {
                    presentCount++;
                  } else {
                    absentCount++;
                  }
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _summaryCard(
                              "Students",
                              students.length.toString(),
                              Icons.groups,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _summaryCard(
                              "Present",
                              presentCount.toString(),
                              Icons.check_circle,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _summaryCard(
                              "Absent",
                              absentCount.toString(),
                              Icons.cancel,
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final data = student.data() as Map<String, dynamic>;

                          final name = data['name']?.toString() ?? 'No Name';
                          final attendance =
                              data['attendance']?.toString() ?? '0%';
                          final rollNo =
                              data['rollNo']?.toString() ?? '#YGCA';
                          final isPresent =
                              attendanceStatus[student.id] ?? true;

                          final initials = name
                              .split(" ")
                              .where((e) => e.isNotEmpty)
                              .map((e) => e[0])
                              .take(2)
                              .join()
                              .toUpperCase();

                          return _studentAttendanceCard(
                            studentId: student.id,
                            name: name,
                            rollNo: rollNo,
                            attendance: attendance,
                            initials: initials,
                            isPresent: isPresent,
                          );
                        },
                      ),
                    ),
                    _saveButton(students),
                  ],
                );
              },
            ),
          ),
        ],
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
          Image.asset(
            'assets/images/ygca_logo.jpg',
            width: 58,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "MARK ATTENDANCE",
              style: TextStyle(
                color: gold,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.check_circle, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _batchSelector(List<String> batches) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: maroon,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gold, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Training Batch",
            style: TextStyle(
              color: gold,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedBatch,
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.groups, color: maroon),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            items: batches.map((batch) {
              return DropdownMenuItem(
                value: batch,
                child: Text(batch),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                selectedBatch = value;
                attendanceStatus.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _studentAttendanceCard({
    required String studentId,
    required String name,
    required String rollNo,
    required String attendance,
    required String initials,
    required bool isPresent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: maroon,
            child: Text(
              initials.isNotEmpty ? initials : "?",
              style: TextStyle(
                color: gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "$rollNo • Current: $attendance",
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                isPresent ? "Present" : "Absent",
                style: TextStyle(
                  color: isPresent ? Colors.green : Colors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                activeThumbColor: Colors.green,
                inactiveThumbColor: Colors.red,
                value: isPresent,
                onChanged: (value) {
                  setState(() {
                    attendanceStatus[studentId] = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _saveButton(List<QueryDocumentSnapshot> students) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(color: Colors.white),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: maroon,
            foregroundColor: gold,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: isSaving ? null : () => saveAttendance(students),
          icon: isSaving
              ? const SizedBox()
              : const Icon(Icons.save_alt, size: 22),
          label: isSaving
              ? CircularProgressIndicator(color: gold, strokeWidth: 2)
              : const Text(
                  "SAVE ATTENDANCE",
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