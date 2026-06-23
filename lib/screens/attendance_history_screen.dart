import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
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

  List<List<String>> _chunks(List<String> values, int size) {
    final chunks = <List<String>>[];

    for (int i = 0; i < values.length; i += size) {
      final end = i + size > values.length ? values.length : i + size;
      chunks.add(values.sublist(i, end));
    }

    return chunks;
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

    final singleAssignedBatch = _text(userData['assignedBatch']).isNotEmpty
        ? _text(userData['assignedBatch'])
        : _text(userData['batch']);

    if (singleAssignedBatch.isNotEmpty &&
        !assignedBatches.contains(singleAssignedBatch)) {
      assignedBatches.add(singleAssignedBatch);
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

    if (value is DateTime) {
      return value;
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) return null;

    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _formatDate(dynamic value) {
    final date = _parseAttendanceDate(value);
    if (date == null) {
      return _text(value).isEmpty ? "No Date" : _text(value);
    }

    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  bool _isPresent(String status) {
    return status.toLowerCase().trim() == 'present';
  }

  bool _isLeave(String status) {
    final s = status.toLowerCase().trim();
    return s == 'leave' || s == 'leave approved' || s == 'approved leave';
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: students.isEmpty
          ? Column(
              children: [
                _topHeader(context),
                Expanded(child: _noStudentView()),
              ],
            )
          : Column(
              children: [
                _topHeader(context),
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

                      final records = _sortRecords(snapshot.data?.docs ?? []);

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
                              role: role,
                              total: total,
                              present: present,
                              absent: absent,
                              leave: leave,
                              percentage: percentage,
                            ),
                            const SizedBox(height: 18),
                            _selectedStudentInfo(),
                            const SizedBox(height: 18),
                            _sectionTitle("ATTENDANCE SUMMARY"),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1.15,
                                children: [
                                  _summaryCard(
                                    Icons.calendar_month,
                                    "TOTAL DAYS",
                                    total.toString(),
                                    Colors.blue,
                                  ),
                                  _summaryCard(
                                    Icons.check_circle,
                                    "PRESENT",
                                    present.toString(),
                                    Colors.green,
                                  ),
                                  _summaryCard(
                                    Icons.cancel,
                                    "ABSENT",
                                    absent.toString(),
                                    Colors.red,
                                  ),
                                  _summaryCard(
                                    Icons.percent,
                                    "ATTENDANCE",
                                    "$percentage%",
                                    Colors.orange,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            _sectionTitle("ATTENDANCE CALENDAR"),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: _calendarGraph(records),
                            ),
                            const SizedBox(height: 18),
                            _sectionTitle("RECENT RECORDS"),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: records.isEmpty
                                  ? _emptyCard()
                                  : Column(
                                      children: records.map((doc) {
                                        final data = doc.data();

                                        return _historyCard(
                                          studentName: _text(
                                                  data['studentName'])
                                              .isNotEmpty
                                              ? _text(data['studentName'])
                                              : _text(selectedStudent?['name'])
                                                      .isNotEmpty
                                                  ? _text(
                                                      selectedStudent?['name'])
                                                  : 'Unknown Student',
                                          batch: _text(data['batch']).isNotEmpty
                                              ? _text(data['batch'])
                                              : _text(selectedStudent?['batch'])
                                                      .isNotEmpty
                                                  ? _text(
                                                      selectedStudent?['batch'])
                                                  : 'Unknown Batch',
                                          date: _formatDate(data['date']),
                                          status:
                                              _text(data['status']).isEmpty
                                                  ? 'Absent'
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

  Widget _selectedStudentInfo() {
    final studentName = _text(selectedStudent?['name']).isEmpty
        ? "Student"
        : _text(selectedStudent?['name']);

    final studentBatch = _text(selectedStudent?['batch']).isEmpty
        ? "No Batch"
        : _text(selectedStudent?['batch']);

    final studentRollNo = _text(selectedStudent?['rollNo']).isEmpty
        ? "-"
        : _text(selectedStudent?['rollNo']);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: maroon,
              child: Text(
                studentName.isNotEmpty ? studentName[0].toUpperCase() : "?",
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$studentBatch • Roll No: $studentRollNo",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
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
              "ATTENDANCE DASHBOARD",
              style: TextStyle(
                color: gold,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.history, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _heroBanner({
    required String role,
    required int total,
    required int present,
    required int absent,
    required int leave,
    required int percentage,
  }) {
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
                  child: Icon(Icons.fact_check, color: maroon, size: 42),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.toUpperCase(),
                        style: TextStyle(
                          color: gold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "ATTENDANCE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 29,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      Text(
                        "DASHBOARD",
                        style: TextStyle(
                          color: gold,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _heroChip("Total: $total"),
                          _heroChip("Present: $present"),
                          _heroChip("Absent: $absent"),
                          _heroChip("Leave: $leave"),
                          _heroChip("Attendance: $percentage%"),
                        ],
                      ),
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
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: gold,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: TextStyle(
                color: maroon,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: gold,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _calendarGraph(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> records,
  ) {
    final Map<String, String> statusByDate = {};

    for (final doc in records) {
      final data = doc.data();
      final parsedDate = _parseAttendanceDate(data['date']);
      final status = _text(data['status']).isEmpty
          ? 'Absent'
          : _text(data['status']);

      if (parsedDate != null) {
        statusByDate[_dateKey(parsedDate)] = status;
      }
    }

    final today = DateTime.now();
    final days = List.generate(
      35,
      (index) => today.subtract(Duration(days: 34 - index)),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: days.map((day) {
              final dateId = _dateKey(day);
              final status = statusByDate[dateId] ?? 'No Record';

              Color color;
              if (_isPresent(status)) {
                color = Colors.green;
              } else if (_isLeave(status)) {
                color = Colors.orange;
              } else if (status == "Absent") {
                color = Colors.red;
              } else {
                color = Colors.grey.shade300;
              }

              return Tooltip(
                message: "$dateId • $status",
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _legend("Present", Colors.green),
              _legend("Absent", Colors.red),
              _legend("Leave", Colors.orange),
              _legend("No Record", Colors.grey.shade300),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _historyCard({
    required String studentName,
    required String batch,
    required String date,
    required String status,
  }) {
    Color statusColor;
    IconData icon;

    if (_isPresent(status)) {
      statusColor = Colors.green;
      icon = Icons.check_circle;
    } else if (_isLeave(status)) {
      statusColor = Colors.orange;
      icon = Icons.event_note;
    } else {
      statusColor = Colors.red;
      icon = Icons.cancel;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: maroon,
            child: Text(
              studentName.isNotEmpty ? studentName[0].toUpperCase() : "?",
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$batch • $date",
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(icon, color: statusColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: const Column(
        children: [
          Icon(Icons.history, size: 38, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No attendance records found",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
