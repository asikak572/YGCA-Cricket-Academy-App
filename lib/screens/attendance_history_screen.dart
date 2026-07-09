import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final List<String> allowedStudentIds;

  const AttendanceHistoryScreen({
    super.key,
    this.allowedStudentIds = const [],
  });

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  bool isLoading = true;

  String uid = '';
  String role = '';
  String email = '';

  List<String> assignedBatches = [];
  List<String> linkedChildrenIds = [];

  List<Map<String, dynamic>> students = [];
  Map<String, dynamic>? selectedStudent;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  String _text(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String _lower(String value) {
    return value.trim().toLowerCase();
  }

  List<String> _listFromDynamic(dynamic value) {
    final result = <String>[];

    if (value is List) {
      for (final item in value) {
        final text = _text(item);
        if (text.isNotEmpty) result.add(text);
      }
    }

    return result;
  }

  List<List<String>> _chunks(List<String> values, int size) {
    final chunks = <List<String>>[];

    for (int i = 0; i < values.length; i += size) {
      final end = i + size > values.length ? values.length : i + size;
      chunks.add(values.sublist(i, end));
    }

    return chunks;
  }

  DateTime _startOfWeek(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day - (date.weekday - 1),
    );
  }

  String _dateId(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<List<String>> _loadCoachAssignedSessions() async {
    final weekId = _dateId(_startOfWeek(DateTime.now()));

    final snapshot = await FirebaseFirestore.instance
        .collection('coach_session_assignments')
        .where('weekStartDate', isEqualTo: weekId)
        .get();

    final sessions = snapshot.docs
        .where((doc) {
          final data = doc.data();
          final coachId = data['coachId']?.toString().trim() ?? '';
          final status = data['status']?.toString().toLowerCase().trim() ?? '';

          return coachId == uid && status == 'active';
        })
        .map((doc) {
          final data = doc.data();
          final session = data['session']?.toString().trim() ?? '';
          final batch = data['batch']?.toString().trim() ?? '';
          return session.isNotEmpty ? session : batch;
        })
        .where((session) => session.isNotEmpty)
        .toSet()
        .toList();

    return sessions;
  }

  Future<void> _loadInitialData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() => isLoading = false);
      return;
    }

    uid = user.uid;
    email = _lower(user.email ?? '');

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!userDoc.exists) {
      if (!mounted) return;
      setState(() => isLoading = false);
      return;
    }

    final userData = userDoc.data() ?? {};
    role = _text(userData['role']);

    assignedBatches = _listFromDynamic(userData['assignedBatches']);

    final singleAssignedBatch = _text(userData['assignedBatch']).isNotEmpty
        ? _text(userData['assignedBatch'])
        : _text(userData['batch']);

    if (singleAssignedBatch.isNotEmpty &&
        !assignedBatches.contains(singleAssignedBatch)) {
      assignedBatches.add(singleAssignedBatch);
    }

    if (role == 'Coach') {
      assignedBatches = await _loadCoachAssignedSessions();
    }

    linkedChildrenIds = _listFromDynamic(userData['linkedChildrenIds']);

    for (final id in widget.allowedStudentIds) {
      final value = _text(id);
      if (value.isNotEmpty && !linkedChildrenIds.contains(value)) {
        linkedChildrenIds.add(value);
      }
    }

    final childId = _text(userData['childId']);
    if (childId.isNotEmpty && !linkedChildrenIds.contains(childId)) {
      linkedChildrenIds.add(childId);
    }

    final loadedStudents = await _loadStudentsForRole(userData);

    if (!mounted) return;

    setState(() {
      students = loadedStudents;
      selectedStudent = loadedStudents.isNotEmpty ? loadedStudents.first : null;
      isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> _loadStudentsForRole(
    Map<String, dynamic> userData,
  ) async {
    if (role == 'Admin') {
      final snapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('isApproved', isEqualTo: true)
          .get();

      return _studentsFromSnapshot(snapshot);
    }

    if (role == 'Coach') {
      if (assignedBatches.isEmpty) return [];

      final allStudents = <Map<String, dynamic>>[];

      for (final batchChunk in _chunks(assignedBatches, 10)) {
        final snapshot = await FirebaseFirestore.instance
            .collection('students')
            .where('batch', whereIn: batchChunk)
            .where('isApproved', isEqualTo: true)
            .get();

        allStudents.addAll(_studentsFromSnapshot(snapshot));
      }

      return _dedupeStudents(allStudents);
    }

    if (role == 'Parent') {
      final allStudents = <Map<String, dynamic>>[];

      for (final childId in linkedChildrenIds) {
        final doc = await FirebaseFirestore.instance
            .collection('students')
            .doc(childId)
            .get();

        if (doc.exists && doc.data() != null) {
          allStudents.add({
            'studentId': doc.id,
            ...doc.data()!,
          });
        }
      }

      final parentUidSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('parentUid', isEqualTo: uid)
          .get();

      allStudents.addAll(_studentsFromSnapshot(parentUidSnapshot));

      final parentEmail = _lower(
        _text(userData['email']).isNotEmpty ? _text(userData['email']) : email,
      );

      if (parentEmail.isNotEmpty) {
        final parentEmailSnapshot = await FirebaseFirestore.instance
            .collection('students')
            .where('parentEmailLower', isEqualTo: parentEmail)
            .get();

        allStudents.addAll(_studentsFromSnapshot(parentEmailSnapshot));
      }

      return _dedupeStudents(allStudents);
    }

    if (role == 'Student') {
      final doc =
          await FirebaseFirestore.instance.collection('students').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        return [
          {
            'studentId': doc.id,
            ...doc.data()!,
          }
        ];
      }

      return [
        {
          'studentId': uid,
          'name': _text(userData['name']),
          'batch': _text(userData['batch']),
          'rollNo': _text(userData['rollNo']),
          'attendance': _text(userData['attendance']),
        }
      ];
    }

    return [];
  }

  List<Map<String, dynamic>> _studentsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map((doc) {
      return {
        'studentId': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  List<Map<String, dynamic>> _dedupeStudents(List<Map<String, dynamic>> input) {
    final ids = <String>{};
    final result = <Map<String, dynamic>>[];

    for (final student in input) {
      final id = _text(student['studentId']);
      if (id.isNotEmpty && !ids.contains(id)) {
        ids.add(id);
        result.add(student);
      }
    }

    result.sort((a, b) {
      final aName = _text(a['name']).toLowerCase();
      final bName = _text(b['name']).toLowerCase();
      return aName.compareTo(bName);
    });

    return result;
  }

  Query<Map<String, dynamic>> _attendanceQuery() {
    final selectedId = _text(selectedStudent?['studentId']);

    if (selectedId.isEmpty) {
      return FirebaseFirestore.instance
          .collection('attendance')
          .where('studentId', isEqualTo: '__NO_STUDENT_SELECTED__');
    }

    return FirebaseFirestore.instance
        .collection('attendance')
        .where('studentId', isEqualTo: selectedId);
  }

  DateTime? _parseAttendanceDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    final raw = value.toString().trim();
    if (raw.isEmpty) return null;

    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(dynamic value) {
    final date = _parseAttendanceDate(value);
    if (date == null) return _text(value).isEmpty ? AppStrings.noDate : _text(value);

    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  bool _isPresent(String status) {
    return status.toLowerCase().trim() == 'present';
  }

  bool _isLeave(String status) {
    final s = status.toLowerCase().trim();
    return s == 'leave' || s == 'leave approved' || s == 'approved leave';
  }

  String _localizedStatus(String status) {
    final normalized = status.trim().toLowerCase();

    if (normalized == 'present') return AppStrings.present;
    if (normalized == 'absent') return AppStrings.absent;
    if (normalized == 'leave' ||
        normalized == 'leave approved' ||
        normalized == 'approved leave') {
      return AppStrings.leave;
    }

    return status;
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortRecords(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> records,
  ) {
    final sorted = [...records];

    sorted.sort((a, b) {
      final aDate = _parseAttendanceDate(a.data()['date']);
      final bDate = _parseAttendanceDate(b.data()['date']);

      if (aDate != null && bDate != null) {
        return bDate.compareTo(aDate);
      }

      return 0;
    });

    return sorted;
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<String>(
          valueListenable: ThemeController.language,
          builder: (context, language, __) {
            final isDark = mode == ThemeMode.dark;

            if (isLoading) {
          return Scaffold(
            backgroundColor: _bg(isDark),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: _bg(isDark),
          body: SafeArea(
            child: students.isEmpty
                ? Column(
                    children: [
                      _topHeader(context, isDark),
                      Expanded(child: _noStudentView(isDark)),
                    ],
                  )
                : Column(
                    children: [
                      _topHeader(context, isDark),
                      if (role == 'Admin' ||
                          role == 'Coach' ||
                          role == 'Parent')
                        _studentDropdown(isDark),
                      Expanded(
                        child:
                            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: _attendanceQuery().snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    "${AppStrings.error}: ${snapshot.error}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _primaryText(isDark),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final records =
                                _sortRecords(snapshot.data?.docs ?? []);

                            int present = 0;
                            int absent = 0;
                            int leave = 0;

                            for (final doc in records) {
                              final data = doc.data();
                              final status = _text(data['status']);

                              if (_isPresent(status)) {
                                present++;
                              } else if (_isLeave(status)) {
                                leave++;
                              } else {
                                absent++;
                              }
                            }

                            final total = records.length;
                            final percentage =
                                total == 0 ? 0 : ((present / total) * 100).round();

                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  _heroBanner(
                                    isDark: isDark,
                                    role: role,
                                    total: total,
                                    present: present,
                                    absent: absent,
                                    leave: leave,
                                    percentage: percentage,
                                  ),
                                  const SizedBox(height: 18),
                                  _selectedStudentInfo(isDark),
                                  const SizedBox(height: 18),
                                  _sectionTitle(
                                      AppStrings.attendanceSummary, isDark),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: GridView.count(
                                      crossAxisCount: 2,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 1.12,
                                      children: [
                                        _summaryCard(
                                          isDark: isDark,
                                          icon: Icons.calendar_month_rounded,
                                          title: AppStrings.totalDays,
                                          value: total.toString(),
                                          color: Colors.blueAccent,
                                        ),
                                        _summaryCard(
                                          isDark: isDark,
                                          icon: Icons.check_circle_rounded,
                                          title: AppStrings.present.toUpperCase(),
                                          value: present.toString(),
                                          color: Colors.green,
                                        ),
                                        _summaryCard(
                                          isDark: isDark,
                                          icon: Icons.cancel_rounded,
                                          title: AppStrings.absent.toUpperCase(),
                                          value: absent.toString(),
                                          color: Colors.redAccent,
                                        ),
                                        _summaryCard(
                                          isDark: isDark,
                                          icon: Icons.percent_rounded,
                                          title: AppStrings.attendance.toUpperCase(),
                                          value: "$percentage%",
                                          color: Colors.orange,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  _sectionTitle(AppStrings.recentRecords, isDark),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: records.isEmpty
                                        ? _emptyCard(isDark)
                                        : Column(
                                            children: records.map((doc) {
                                              final data = doc.data();

                                              return _historyCard(
                                                isDark: isDark,
                                                studentName: _text(data[
                                                            'studentName'])
                                                        .isNotEmpty
                                                    ? _text(data['studentName'])
                                                    : _text(selectedStudent?[
                                                                'name'])
                                                            .isNotEmpty
                                                        ? _text(selectedStudent?[
                                                            'name'])
                                                        : AppStrings.unknownStudent,
                                                batch: _text(data['batch'])
                                                        .isNotEmpty
                                                    ? _text(data['batch'])
                                                    : _text(selectedStudent?[
                                                                'batch'])
                                                            .isNotEmpty
                                                        ? _text(selectedStudent?[
                                                            'batch'])
                                                        : AppStrings.unknownBatch,
                                                date: _formatDate(data['date']),
                                                status:
                                                    _text(data['status']).isEmpty
                                                        ? AppStrings.absent
                                                        : _text(data['status']),
                                              );
                                            }).toList(),
                                          ),
                                  ),
                                  const SizedBox(height: 26),
                                ],
                              ),
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
      },
    );
  }

  Widget _noStudentView(bool isDark) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _card(isDark),
          border: Border.all(color: _border(isDark)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_off_rounded,
              size: 42,
              color: _secondaryText(isDark),
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.noStudentsFound,
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              AppStrings.noApprovedAssignedStudents,
              textAlign: TextAlign.center,
              style: TextStyle(color: _secondaryText(isDark)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _studentDropdown(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _card(isDark),
        border: Border.all(color: _border(isDark)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _text(selectedStudent?['studentId']).isEmpty
              ? null
              : _text(selectedStudent?['studentId']),
          isExpanded: true,
          dropdownColor: _card(isDark),
          icon: Icon(Icons.keyboard_arrow_down, color: isDark ? gold : maroon),
          hint: Text(
            AppStrings.selectStudent,
            style: TextStyle(color: _secondaryText(isDark)),
          ),
          style: TextStyle(
            color: _primaryText(isDark),
            fontWeight: FontWeight.w700,
          ),
          items: students.map((student) {
            final id = _text(student['studentId']);
            final studentName = _text(student['name']).isEmpty
                ? AppStrings.unnamedStudent
                : _text(student['name']);
            final studentBatch = _text(student['batch']);

            return DropdownMenuItem<String>(
              value: id,
              child: Text(
                studentBatch.isEmpty
                    ? studentName
                    : "$studentName • $studentBatch",
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            final selected = students.firstWhere(
              (student) => _text(student['studentId']) == value,
              orElse: () => students.first,
            );

            setState(() {
              selectedStudent = selected;
            });
          },
        ),
      ),
    );
  }

  Widget _selectedStudentInfo(bool isDark) {
    final studentName = _text(selectedStudent?['name']).isEmpty
        ? AppStrings.student
        : _text(selectedStudent?['name']);

    final studentBatch = _text(selectedStudent?['batch']).isEmpty
        ? AppStrings.noBatch
        : _text(selectedStudent?['batch']);

    final studentRollNo = _text(selectedStudent?['rollNo']).isEmpty
        ? "-"
        : _text(selectedStudent?['rollNo']);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card(isDark),
          border: Border.all(color: _border(isDark)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: maroon,
              child: Text(
                studentName.isNotEmpty ? studentName[0].toUpperCase() : "?",
                style: const TextStyle(
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
                    studentName,
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
                    "$studentBatch • ${AppStrings.rollNo}: $studentRollNo",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _secondaryText(isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Row(
        children: [
          _circleButton(
            isDark: isDark,
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Image.asset(
            'assets/images/ygca_logo.jpg',
            width: 46,
            height: 46,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.attendance.toUpperCase(),
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  AppStrings.historyDashboard,
                  style: TextStyle(
                    color: _secondaryText(isDark),
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
              return _circleButton(
                isDark: isDark,
                icon: dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                onTap: ThemeController.toggleTheme,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _card(isDark),
          shape: BoxShape.circle,
          border: Border.all(color: _border(isDark)),
        ),
        child: Icon(icon, color: isDark ? Colors.white : maroon, size: 21),
      ),
    );
  }

  Widget _heroBanner({
    required bool isDark,
    required String role,
    required int total,
    required int present,
    required int absent,
    required int leave,
    required int percentage,
  }) {
    return Container(
      height: 205,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.black,
                  darkMaroon,
                  red.withOpacity(0.35),
                ]
              : [
                  maroon,
                  red.withOpacity(0.80),
                  darkMaroon,
                ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? red.withOpacity(0.55) : gold.withOpacity(0.9),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 46,
            backgroundColor: Colors.white,
            child: Icon(Icons.fact_check_rounded, color: maroon, size: 42),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 230,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.toUpperCase(),
                      style: const TextStyle(
                        color: gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      AppStrings.attendance.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    Text(
                      AppStrings.history.toUpperCase(),
                      style: const TextStyle(
                        color: gold,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _heroChip("${AppStrings.total}: $total"),
                        _heroChip("${AppStrings.present}: $present"),
                        _heroChip("${AppStrings.absent}: $absent"),
                        _heroChip("${AppStrings.leave}: $leave"),
                        _heroChip("${AppStrings.attendance}: $percentage%"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.75)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: gold,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
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

  Widget _summaryCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 34),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: _primaryText(isDark),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard({
    required bool isDark,
    required String studentName,
    required String batch,
    required String date,
    required String status,
  }) {
    final present = _isPresent(status);
    final leave = _isLeave(status);
    final color = present ? Colors.green : leave ? Colors.orange : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.16),
            child: Icon(
              present
                  ? Icons.check_rounded
                  : leave
                      ? Icons.event_note_rounded
                      : Icons.close_rounded,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
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
                  "$batch • $date",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _localizedStatus(status),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card(isDark),
        border: Border.all(color: _border(isDark)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        AppStrings.noAttendanceRecordsFound,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _secondaryText(isDark),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}