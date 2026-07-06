import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';

class AttendanceCalendarScreen extends StatefulWidget {
  final String studentId;
  final String name;
  final String batch;
  final String rollNo;
  final String attendance;

  const AttendanceCalendarScreen({
    super.key,
    this.studentId = "",
    this.name = "Arjun R",
    this.batch = "Morning Batch",
    this.rollNo = "#014",
    this.attendance = "0%",
  });

  @override
  State<AttendanceCalendarScreen> createState() =>
      _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState extends State<AttendanceCalendarScreen> {
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

    final childId = _text(userData['childId']);
    if (childId.isNotEmpty && !linkedChildrenIds.contains(childId)) {
      linkedChildrenIds.add(childId);
    }

    final loadedStudents = await _loadStudentsForRole(userData);

    if (!mounted) return;

    Map<String, dynamic>? firstSelected;

    if (widget.studentId.trim().isNotEmpty) {
      for (final student in loadedStudents) {
        if (_text(student['studentId']) == widget.studentId.trim()) {
          firstSelected = student;
          break;
        }
      }

      firstSelected ??= {
        'studentId': widget.studentId.trim(),
        'name': widget.name,
        'batch': widget.batch,
        'rollNo': widget.rollNo,
        'attendance': widget.attendance,
      };

      final alreadyExists = loadedStudents.any(
        (student) => _text(student['studentId']) == widget.studentId.trim(),
      );

      if (!alreadyExists) {
        loadedStudents.insert(0, firstSelected);
      }
    } else if (loadedStudents.isNotEmpty) {
      firstSelected = loadedStudents.first;
    }

    setState(() {
      students = loadedStudents;
      selectedStudent = firstSelected;
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

  String _studentInitials(Map<String, dynamic>? student) {
    final name = _text(student?['name']);
    if (name.isEmpty) return '?';

    return name
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();
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

  bool _isPresent(String status) {
    return status.toLowerCase().trim() == 'present';
  }

  bool _isLeave(String status) {
    final s = status.toLowerCase().trim();
    return s == 'leave' || s == 'leave approved' || s == 'approved leave';
  }

  Color _bg(bool isDark) {
    return isDark ? const Color(0xFF070707) : const Color(0xFFF8FAFC);
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
        final isDark = mode == ThemeMode.dark;

        if (isLoading) {
          return Scaffold(
            backgroundColor: _bg(isDark),
            body: SafeArea(
              child: Column(
                children: [
                  _topBar(context, isDark),
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: _bg(isDark),
          body: SafeArea(
            child: students.isEmpty
                ? Column(
                    children: [
                      _topBar(context, isDark),
                      Expanded(child: _noStudentView(isDark)),
                    ],
                  )
                : Column(
                    children: [
                      _topBar(context, isDark),
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
                                    'Error: ${snapshot.error}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _primaryText(isDark),
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

                            final records = snapshot.data?.docs ?? [];

                            int present = 0;
                            int absent = 0;
                            int leave = 0;
                            final Map<int, String> dayStatus = {};

                            final now = DateTime.now();
                            final daysInMonth =
                                DateTime(now.year, now.month + 1, 0).day;

                            for (final record in records) {
                              final data = record.data();
                              final date = _parseAttendanceDate(data['date']);

                              if (date == null) continue;
                              if (date.year != now.year ||
                                  date.month != now.month) {
                                continue;
                              }

                              final status = _text(data['status']);

                              if (_isPresent(status)) {
                                present++;
                                dayStatus[date.day] = 'P';
                              } else if (_isLeave(status)) {
                                leave++;
                                dayStatus[date.day] = 'L';
                              } else {
                                absent++;
                                dayStatus[date.day] = 'A';
                              }
                            }

                            final total = present + absent + leave;
                            final percent =
                                total == 0 ? 0 : ((present / total) * 100).round();

                            return SingleChildScrollView(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 24),
                              child: Column(
                                children: [
                                  _studentHeader(
                                    isDark: isDark,
                                    initials:
                                        _studentInitials(selectedStudent),
                                    percent: '$percent%',
                                  ),
                                  const SizedBox(height: 14),
                                  _summaryCard(
                                    isDark: isDark,
                                    present: present,
                                    absent: absent,
                                    leave: leave,
                                    percent: percent,
                                  ),
                                  const SizedBox(height: 16),
                                  _legend(isDark),
                                  const SizedBox(height: 12),
                                  _calendar(
                                    isDark: isDark,
                                    dayStatus: dayStatus,
                                    daysInMonth: daysInMonth,
                                  ),
                                  const SizedBox(height: 14),
                                  _noteCard(isDark),
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
  }

  Widget _topBar(BuildContext context, bool isDark) {
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
                  'Attendance Calendar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Student-wise monthly view',
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
          color: isDark ? const Color(0xFF111111) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _border(isDark)),
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : maroon,
          size: 21,
        ),
      ),
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
          borderRadius: BorderRadius.circular(16),
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
              'No students found',
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'No approved or assigned students are available for this account.',
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
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _card(isDark),
        border: Border.all(color: _border(isDark)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _text(selectedStudent?['studentId']).isEmpty
              ? null
              : _text(selectedStudent?['studentId']),
          isExpanded: true,
          dropdownColor: _card(isDark),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: gold),
          hint: Text(
            'Select Student',
            style: TextStyle(color: _secondaryText(isDark)),
          ),
          style: TextStyle(
            color: _primaryText(isDark),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          items: students.map((student) {
            final id = _text(student['studentId']);
            final studentName = _text(student['name']).isEmpty
                ? 'Unnamed Student'
                : _text(student['name']);
            final studentBatch = _text(student['batch']);

            return DropdownMenuItem<String>(
              value: id,
              child: Text(
                studentBatch.isEmpty
                    ? studentName
                    : '$studentName • $studentBatch',
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

            setState(() => selectedStudent = selected);
          },
        ),
      ),
    );
  }

  Widget _studentHeader({
    required bool isDark,
    required String initials,
    required String percent,
  }) {
    final studentName = _text(selectedStudent?['name']).isEmpty
        ? 'Student'
        : _text(selectedStudent?['name']);

    final studentBatch = _text(selectedStudent?['batch']).isEmpty
        ? 'No Batch'
        : _text(selectedStudent?['batch']);

    final studentRollNo = _text(selectedStudent?['rollNo']).isEmpty
        ? '-'
        : _text(selectedStudent?['rollNo']);

    final percentBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.35)),
      ),
      child: Text(
        percent,
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );

    final studentInfo = Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: maroon,
          child: Text(
            initials,
            style: const TextStyle(
              color: gold,
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
                studentName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$studentBatch • Roll No: $studentRollNo',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        border: Border.all(
          color: isDark ? red.withOpacity(0.32) : gold.withOpacity(0.70),
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 330) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                studentInfo,
                const SizedBox(height: 10),
                percentBadge,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: studentInfo),
              percentBadge,
            ],
          );
        },
      ),
    );
  }

  Widget _summaryCard({
    required bool isDark,
    required int present,
    required int absent,
    required int leave,
    required int percent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [maroon, darkMaroon, Colors.black]
              : [maroon, red.withOpacity(0.82), darkMaroon],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.75), width: 1.2),
      ),
      child: Column(
        children: [
          const Text(
            'Firebase Attendance',
            style: TextStyle(
              color: gold,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Student-wise attendance calendar',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 16,
            runSpacing: 12,
            children: [
              _MiniStat(title: 'Present', value: present.toString()),
              _MiniStat(title: 'Absent', value: absent.toString()),
              _MiniStat(title: 'Leave', value: leave.toString()),
              _MiniStat(title: 'Percent', value: '$percent%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border(isDark)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 8,
        children: [
          _LegendItem(label: 'Present', color: Colors.green, isDark: isDark),
          _LegendItem(label: 'Absent', color: Colors.red, isDark: isDark),
          _LegendItem(label: 'Leave', color: Colors.orange, isDark: isDark),
          _LegendItem(label: 'No Record', color: Colors.grey, isDark: isDark),
        ],
      ),
    );
  }

  Widget _calendar({
    required bool isDark,
    required Map<int, String> dayStatus,
    required int daysInMonth,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border(isDark)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(daysInMonth, (index) {
          final day = index + 1;
          final status = dayStatus[day] ?? '';
          Color color = Colors.grey.withOpacity(0.25);
          String label = day.toString();

          if (status == 'P') color = Colors.green;
          if (status == 'A') color = Colors.red;
          if (status == 'L') color = Colors.orange;

          return Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(status.isEmpty ? 0.20 : 0.85),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: status.isEmpty ? _border(isDark) : color,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: status.isEmpty
                      ? _secondaryText(isDark)
                      : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _noteCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border(isDark)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: isDark ? gold : maroon,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Calendar shows current month attendance for the selected student.",
              style: TextStyle(
                color: _secondaryText(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;

  const _MiniStat({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;

  const _LegendItem({
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}