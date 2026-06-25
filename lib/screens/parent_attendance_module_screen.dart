import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';

import 'widgets/ygca_app_bar.dart';
import 'attendance_calendar_screen.dart';
import 'attendance_history_screen.dart';

class ParentAttendanceModuleScreen extends StatelessWidget {
  const ParentAttendanceModuleScreen({super.key});

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  String _text(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String _lower(dynamic value) {
    if (value == null) return '';
    return value.toString().trim().toLowerCase();
  }

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

  Future<Map<String, dynamic>?> _getStudentById(String studentId) async {
    final doc = await FirebaseFirestore.instance
        .collection('students')
        .doc(studentId)
        .get();

    if (!doc.exists || doc.data() == null) return null;

    return {
      'studentId': doc.id,
      ...doc.data()!,
    };
  }

  Future<List<Map<String, dynamic>>> _getLinkedChildren() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final parentDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!parentDoc.exists) return [];

    final parentData = parentDoc.data() ?? {};

    final parentEmail = _text(parentData['email']).isNotEmpty
        ? _text(parentData['email'])
        : _text(user.email);

    final parentEmailLower = _lower(parentEmail);

    final children = <Map<String, dynamic>>[];
    final ids = <String>{};
    final addedStudentIds = <String>{};

    final linkedChildrenIds = parentData['linkedChildrenIds'];

    if (linkedChildrenIds is List) {
      for (final id in linkedChildrenIds) {
        final value = _text(id);
        if (value.isNotEmpty) {
          ids.add(value);
        }
      }
    }

    final childId = _text(parentData['childId']);
    if (childId.isNotEmpty) ids.add(childId);

    final studentId = _text(parentData['studentId']);
    if (studentId.isNotEmpty) ids.add(studentId);

    for (final id in ids) {
      final student = await _getStudentById(id);

      if (student != null && !addedStudentIds.contains(student['studentId'])) {
        children.add(student);
        addedStudentIds.add(student['studentId']);
      }
    }

    if (children.isEmpty && parentEmailLower.isNotEmpty) {
      final lowerSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('parentEmailLower', isEqualTo: parentEmailLower)
          .get();

      for (final doc in lowerSnapshot.docs) {
        if (!addedStudentIds.contains(doc.id)) {
          children.add({
            'studentId': doc.id,
            ...doc.data(),
          });
          addedStudentIds.add(doc.id);
        }
      }
    }

    if (children.isEmpty && parentEmail.isNotEmpty) {
      final emailSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('parentEmail', isEqualTo: parentEmail)
          .get();

      for (final doc in emailSnapshot.docs) {
        if (!addedStudentIds.contains(doc.id)) {
          children.add({
            'studentId': doc.id,
            ...doc.data(),
          });
          addedStudentIds.add(doc.id);
        }
      }
    }

    return children;
  }

  int _attendanceNumber(Map<String, dynamic> child) {
    final attendance = _text(child['attendance']);
    return int.tryParse(attendance.replaceAll('%', '').trim()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: _bg(isDark),
          appBar: const YgcaAppBar(title: "Attendance Module"),
          body: SafeArea(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getLinkedChildren(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      _header(isDark, "Loading...", "Please wait"),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }

                if (snapshot.hasError) {
                  return Column(
                    children: [
                      _header(isDark, "Error", "Unable to load attendance"),
                      Expanded(
                        child: _messageCard(
                          isDark: isDark,
                          icon: Icons.error_outline_rounded,
                          title: "Something went wrong",
                          message: snapshot.error.toString(),
                        ),
                      ),
                    ],
                  );
                }

                final children = snapshot.data ?? [];

                if (children.isEmpty) {
                  return Column(
                    children: [
                      _header(
                        isDark,
                        "No Child Linked",
                        "Contact admin to link student",
                      ),
                      Expanded(
                        child: _messageCard(
                          isDark: isDark,
                          icon: Icons.person_off_rounded,
                          title: "No linked student found",
                          message:
                              "This parent account is not linked with any student yet.",
                        ),
                      ),
                    ],
                  );
                }

                final firstChild = children.first;

                final firstStudentId = _text(firstChild['studentId']);
                final firstName = _text(firstChild['name']).isEmpty
                    ? "Student"
                    : _text(firstChild['name']);

                final firstBatch = _text(firstChild['batch']).isEmpty
                    ? "Batch not assigned"
                    : _text(firstChild['batch']);

                final firstRollNo = _text(firstChild['rollNo']).isEmpty
                    ? "Not assigned"
                    : _text(firstChild['rollNo']);

                final firstAttendance = _text(firstChild['attendance']).isEmpty
                    ? "0%"
                    : _text(firstChild['attendance']);

                final allowedStudentIds = children
                    .map((child) => _text(child['studentId']))
                    .where((id) => id.isNotEmpty)
                    .toList();

                final attendanceNumber = _attendanceNumber(firstChild);

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _header(
                        isDark,
                        firstName,
                        "$firstBatch • Roll No: $firstRollNo",
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 16),
                    ),
                    SliverToBoxAdapter(
                      child: _summaryCard(
                        isDark: isDark,
                        studentName: firstName,
                        attendance: firstAttendance,
                        attendanceNumber: attendanceNumber,
                        childrenCount: children.length,
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 18),
                    ),
                    SliverToBoxAdapter(
                      child: _sectionTitle("ATTENDANCE ACCESS", isDark),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                      sliver: SliverGrid(
                        delegate: SliverChildListDelegate(
                          [
                            _moduleCard(
                              context: context,
                              isDark: isDark,
                              icon: Icons.calendar_month_rounded,
                              title: "Attendance Calendar",
                              subtitle: "Day-wise child attendance",
                              color: const Color(0xFFF97316),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AttendanceCalendarScreen(
                                      studentId: firstStudentId,
                                      name: firstName,
                                      batch: firstBatch,
                                      rollNo: firstRollNo,
                                      attendance: firstAttendance,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _moduleCard(
                              context: context,
                              isDark: isDark,
                              icon: Icons.history_rounded,
                              title: "Attendance History",
                              subtitle: "View full attendance records",
                              color: const Color(0xFFDC2626),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AttendanceHistoryScreen(
                                      allowedStudentIds: allowedStudentIds,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                      ),
                    ),
                    if (children.length > 1)
                      SliverToBoxAdapter(
                        child: _childrenList(
                          isDark: isDark,
                          children: children,
                        ),
                      ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 24),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _header(bool isDark, String title, String subtitle) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.black,
                  darkMaroon,
                  red.withOpacity(0.40),
                ]
              : [
                  maroon,
                  darkMaroon,
                  Colors.black.withOpacity(0.85),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? red.withOpacity(0.35) : gold.withOpacity(0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.18) : maroon.withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -24,
            child: Icon(
              Icons.fact_check_rounded,
              color: Colors.white.withOpacity(0.08),
              size: 112,
            ),
          ),
          Column(
            children: [
              Container(
                width: 68,
                height: 68,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.30),
                  shape: BoxShape.circle,
                  border: Border.all(color: gold.withOpacity(0.85)),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withOpacity(0.16),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fact_check_rounded,
                  color: gold,
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "ATTENDANCE MODULE",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required bool isDark,
    required String studentName,
    required String attendance,
    required int attendanceNumber,
    required int childrenCount,
  }) {
    final progress = attendanceNumber.clamp(0, 100) / 100;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? red.withOpacity(0.28) : gold.withOpacity(0.70),
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark ? Colors.black.withOpacity(0.24) : Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: attendanceNumber >= 75
                ? Colors.green.withOpacity(0.18)
                : Colors.orange.withOpacity(0.18),
            child: Icon(
              attendanceNumber >= 75
                  ? Icons.verified_rounded
                  : Icons.warning_rounded,
              color: attendanceNumber >= 75 ? Colors.green : Colors.orange,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Child Attendance Summary",
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$studentName • $attendance",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress.toDouble(),
                    minHeight: 8,
                    backgroundColor:
                        isDark ? Colors.white12 : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      attendanceNumber >= 75 ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Text(
                childrenCount.toString(),
                style: TextStyle(
                  color: isDark ? gold : maroon,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                "Child",
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? gold : maroon,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              color: isDark ? red.withOpacity(0.45) : gold.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moduleCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: _card(isDark),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? color.withOpacity(0.34) : _border(isDark),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? color.withOpacity(0.14)
                    : Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color,
                        color.withOpacity(0.62),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.26),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 27),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : color.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: isDark ? gold : maroon,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _childrenList({
    required bool isDark,
    required List<Map<String, dynamic>> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("LINKED CHILDREN", isDark),
          ...children.map((child) {
            final name = _text(child['name']).isEmpty
                ? "Student"
                : _text(child['name']);

            final batch = _text(child['batch']).isEmpty
                ? "Batch not assigned"
                : _text(child['batch']);

            final attendance = _text(child['attendance']).isEmpty
                ? "0%"
                : _text(child['attendance']);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF180808) : const Color(0xFFFFFBF2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? red.withOpacity(0.22)
                      : gold.withOpacity(0.42),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: maroon,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "S",
                      style: const TextStyle(
                        color: gold,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
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
                          ),
                        ),
                        Text(
                          batch,
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
                  Text(
                    attendance,
                    style: TextStyle(
                      color: isDark ? gold : maroon,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _messageCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _card(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border(isDark)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _secondaryText(isDark), size: 42),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText(isDark),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}