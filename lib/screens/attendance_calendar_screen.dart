import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

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

  Future<void> _loadInitialData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      return;
    }

    uid = user.uid;
    email = _lower(user.email ?? '');

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!userDoc.exists) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      return;
    }

    final userData = userDoc.data() ?? {};
    role = _text(userData['role']);

    assignedBatches = _listFromDynamic(userData['assignedBatches']);
    linkedChildrenIds = _listFromDynamic(userData['linkedChildrenIds']);

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

  List<String> _listFromDynamic(dynamic value) {
    final result = <String>[];

    if (value is List) {
      for (final item in value) {
        final text = _text(item);
        if (text.isNotEmpty) {
          result.add(text);
        }
      }
    }

    return result;
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
      if (assignedBatches.isEmpty) {
        return [];
      }

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

        if (doc.exists) {
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

      if (doc.exists) {
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

  List<List<String>> _chunks(List<String> values, int size) {
    final chunks = <List<String>>[];

    for (int i = 0; i < values.length; i += size) {
      final end = i + size > values.length ? values.length : i + size;
      chunks.add(values.sublist(i, end));
    }

    return chunks;
  }

  String _studentInitials(Map<String, dynamic>? student) {
    final name = _text(student?['name']);
    if (name.isEmpty) return "?";

    return name
        .split(" ")
        .map((e) => e.isNotEmpty ? e[0] : "")
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

    if (value is Timestamp) {
      return value.toDate();
    }

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: const Text("Student Attendance"),
          backgroundColor: maroon,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Student Attendance"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: students.isEmpty
          ? _noStudentView()
          : Column(
              children: [
                if (role == 'Admin' || role == 'Coach' || role == 'Parent')
                  _studentDropdown(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _attendanceQuery().snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              "Error: ${snapshot.error}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
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

                        if (date.year != now.year || date.month != now.month) {
                          continue;
                        }

                        final status = _text(data['status']);

                        if (_isPresent(status)) {
                          present++;
                          dayStatus[date.day] = "P";
                        } else if (_isLeave(status)) {
                          leave++;
                          dayStatus[date.day] = "L";
                        } else {
                          absent++;
                          dayStatus[date.day] = "A";
                        }
                      }

                      final total = present + absent + leave;
                      final percent =
                          total == 0 ? 0 : ((present / total) * 100).round();

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _studentHeader(_studentInitials(selectedStudent), "$percent%"),
                            const SizedBox(height: 14),
                            _summaryCard(present, absent, leave, percent),
                            const SizedBox(height: 16),
                            _legend(),
                            const SizedBox(height: 12),
                            _calendar(dayStatus, daysInMonth),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _noStudentView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_off, size: 42, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "No students found",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "No approved or assigned students are available for this account.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _studentDropdown() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _text(selectedStudent?['studentId']).isEmpty
              ? null
              : _text(selectedStudent?['studentId']),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: maroon),
          hint: const Text("Select Student"),
          items: students.map((student) {
            final id = _text(student['studentId']);
            final studentName = _text(student['name']).isEmpty
                ? "Unnamed Student"
                : _text(student['name']);
            final studentBatch = _text(student['batch']);

            return DropdownMenuItem<String>(
              value: id,
              child: Text(
                studentBatch.isEmpty ? studentName : "$studentName • $studentBatch",
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

  Widget _studentHeader(String initials, String percent) {
    final studentName = _text(selectedStudent?['name']).isEmpty
        ? "Student"
        : _text(selectedStudent?['name']);

    final studentBatch = _text(selectedStudent?['batch']).isEmpty
        ? "No Batch"
        : _text(selectedStudent?['batch']);

    final studentRollNo = _text(selectedStudent?['rollNo']).isEmpty
        ? "-"
        : _text(selectedStudent?['rollNo']);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: maroon,
            child: Text(
              initials,
              style: TextStyle(color: gold, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "$studentBatch • Roll No: $studentRollNo",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDF4),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Text(
              percent,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(int present, int absent, int leave, int percent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: maroon,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            "Firebase Attendance",
            style: TextStyle(
              color: gold,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Student-wise attendance calendar",
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(title: "Present", value: present.toString()),
              _MiniStat(title: "Absent", value: absent.toString()),
              _MiniStat(title: "Leave", value: leave.toString()),
              _MiniStat(title: "Percent", value: "$percent%"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: const [
        _LegendItem(label: "Present", color: Colors.green),
        _LegendItem(label: "Absent", color: Colors.red),
        _LegendItem(label: "Leave", color: Colors.orange),
        _LegendItem(label: "No Record", color: Colors.grey),
      ],
    );
  }

  Widget _calendar(Map<int, String> dayStatus, int daysInMonth) {
    final days = List.generate(daysInMonth, (index) => index + 1);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              _WeekDay("Sun"),
              _WeekDay("Mon"),
              _WeekDay("Tue"),
              _WeekDay("Wed"),
              _WeekDay("Thu"),
              _WeekDay("Fri"),
              _WeekDay("Sat"),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              final status = dayStatus[day] ?? "";
              return _DayBox(day: day.toString(), status: status);
            },
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;

  const _MiniStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _WeekDay extends StatelessWidget {
  final String text;

  const _WeekDay(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }
}

class _DayBox extends StatelessWidget {
  final String day;
  final String status;

  const _DayBox({required this.day, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.grey.shade100;
    Color textColor = Colors.grey;
    String label = "-";

    if (status == "P") {
      bgColor = Colors.green.shade50;
      textColor = Colors.green;
      label = "P";
    } else if (status == "A") {
      bgColor = Colors.red.shade50;
      textColor = Colors.red;
      label = "A";
    } else if (status == "L") {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange;
      label = "L";
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          Text(label, style: TextStyle(color: textColor, fontSize: 9)),
        ],
      ),
    );
  }
}
