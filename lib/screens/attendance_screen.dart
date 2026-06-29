import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';
import 'notification_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  String selectedBatch = "Friday: 6:00 PM – 8:00 PM";
  bool isSaving = false;

  final Map<String, bool> attendanceStatus = {};

  final List<String> batches = const [
    "Friday: 6:00 PM – 8:00 PM",
    "Saturday: 7:00 AM – 9:00 AM",
    "Saturday: 4:00 PM – 6:00 PM",
    "Saturday: 6:00 PM – 8:00 PM",
  ];

  Color _bg(bool isDark) {
    return isDark ? const Color(0xFF070707) : const Color(0xFFFAFAFA);
  }

  Color _card(bool isDark) {
    return isDark ? const Color(0xFF111111) : Colors.white;
  }

  Color _border(bool isDark) {
    return isDark ? const Color(0xFF3A1515) : const Color(0xFFE2E8F0);
  }

  Color _primaryText(bool isDark) {
    return isDark ? Colors.white : const Color(0xFF111827);
  }

  Color _secondaryText(bool isDark) {
    return isDark ? Colors.white60 : const Color(0xFF64748B);
  }

  Future<void> saveAttendance(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> students,
  ) async {
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
        final data = student.data();
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
        const SnackBar(
          content: Text("Attendance saved successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving attendance: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: _bg(isDark),
          body: SafeArea(
            child: Column(
              children: [
                _topHeader(context, isDark),
                _batchSelector(isDark),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('students')
                        .where('batch', isEqualTo: selectedBatch)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Text(
        "Error loading students:\n${snapshot.error}",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final students = snapshot.data?.docs ?? [];

                      if (students.isEmpty) {
                        return _emptyState(isDark);
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
                                    isDark: isDark,
                                    title: "Students",
                                    value: students.length.toString(),
                                    icon: Icons.groups_rounded,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _summaryCard(
                                    isDark: isDark,
                                    title: "Present",
                                    value: presentCount.toString(),
                                    icon: Icons.check_circle_rounded,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _summaryCard(
                                    isDark: isDark,
                                    title: "Absent",
                                    value: absentCount.toString(),
                                    icon: Icons.cancel_rounded,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: students.length,
                              itemBuilder: (context, index) {
                                final student = students[index];
                                final data = student.data();

                                final name =
                                    data['name']?.toString() ?? 'No Name';
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
                                  isDark: isDark,
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
                          _saveButton(isDark, students),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _topHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.black,
                  darkMaroon,
                  red.withOpacity(0.55),
                ]
              : [
                  maroon,
                  red.withOpacity(0.78),
                  darkMaroon,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? red.withOpacity(0.40) : gold.withOpacity(0.8),
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark ? red.withOpacity(0.18) : maroon.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _circleHeaderButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Image.asset(
            'assets/images/ygca_logo.jpg',
            width: 52,
            height: 52,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "MARK ATTENDANCE",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: gold,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Batch-wise student attendance",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeMode,
            builder: (context, mode, _) {
              final dark = mode == ThemeMode.dark;

              return _circleHeaderButton(
                icon: dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                onTap: ThemeController.toggleTheme,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _circleHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.20)),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 21,
        ),
      ),
    );
  }

  Widget _batchSelector(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? red.withOpacity(0.28) : gold.withOpacity(0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.35)
                : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: red.withOpacity(0.16),
                child: Icon(
                  Icons.groups_rounded,
                  color: isDark ? gold : maroon,
                  size: 18,
                ),
              ),
              const SizedBox(width: 9),
              Text(
                "Select Training Batch",
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedBatch,
            dropdownColor: isDark ? const Color(0xFF111111) : Colors.white,
            style: TextStyle(
              color: _primaryText(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? const Color(0xFF0B0B0B) : Colors.white,
              prefixIcon: Icon(
                Icons.sports_cricket_rounded,
                color: isDark ? gold : maroon,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: _border(isDark)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: _border(isDark)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: isDark ? red : maroon),
              ),
            ),
            items: batches.map((batch) {
              return DropdownMenuItem(
                value: batch,
                child: Text(
                  batch,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: isSaving
                ? null
                : (value) {
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

  Widget _emptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: _card(isDark),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _border(isDark)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.groups_2_outlined,
                color: isDark ? gold : maroon,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                "No students found",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                selectedBatch,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard({
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF151515),
                  const Color(0xFF1A0808),
                  color.withOpacity(0.16),
                ]
              : [
                  Colors.white,
                  const Color(0xFFFFFBF2),
                  color.withOpacity(0.08),
                ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : gold.withOpacity(0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? color.withOpacity(0.10)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 90,
          child: Column(
            children: [
              Icon(icon, color: color, size: 25),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _studentAttendanceCard({
    required bool isDark,
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
        color: _card(isDark),
        border: Border.all(
          color: isPresent
              ? Colors.green.withOpacity(isDark ? 0.35 : 0.25)
              : Colors.red.withOpacity(isDark ? 0.40 : 0.28),
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.30)
                : Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: isPresent ? Colors.green : Colors.redAccent,
            child: Text(
              initials.isNotEmpty ? initials : "?",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
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
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$rollNo • Current: $attendance",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isPresent
                      ? Colors.green.withOpacity(0.14)
                      : Colors.red.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPresent ? "Present" : "Absent",
                  style: TextStyle(
                    color: isPresent ? Colors.green : Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.82,
                child: Switch(
                  activeThumbColor: Colors.green,
                  inactiveThumbColor: Colors.redAccent,
                  activeTrackColor: Colors.green.withOpacity(0.35),
                  inactiveTrackColor: Colors.red.withOpacity(0.22),
                  value: isPresent,
                  onChanged: isSaving
                      ? null
                      : (value) {
                          setState(() {
                            attendanceStatus[studentId] = value;
                          });
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _saveButton(
    bool isDark,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> students,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: _bg(isDark),
        border: Border(
          top: BorderSide(color: _border(isDark)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? red : maroon,
            foregroundColor: isDark ? Colors.white : gold,
            elevation: 8,
            shadowColor: red.withOpacity(0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: isSaving ? null : () => saveAttendance(students),
          icon: isSaving
              ? const SizedBox()
              : const Icon(Icons.save_alt_rounded, size: 22),
          label: isSaving
              ? CircularProgressIndicator(
                  color: isDark ? Colors.white : gold,
                  strokeWidth: 2,
                )
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
