import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';

import 'add_student_screen.dart';
import 'student_details_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  String searchQuery = "";

  late final Stream<QuerySnapshot> _studentsStream;
  final TextEditingController _searchController = TextEditingController();

  bool get isSmallScreen {
    return MediaQuery.of(context).size.width < 370;
  }

  @override
  void initState() {
    super.initState();

    _studentsStream = FirebaseFirestore.instance
        .collection('students')
        .orderBy('createdAt', descending: true)
        .snapshots();

    _searchController.addListener(() {
      if (!mounted) return;

      setState(() {
        searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  String _cleanEmail(String value) {
    return value.trim().toLowerCase();
  }

  int _percentValue(String value) {
    return int.tryParse(value.replaceAll("%", "").trim()) ?? 0;
  }

  bool _isApproved(Map<String, dynamic> data) {
    final approvalStatus =
        data['approvalStatus']?.toString().toLowerCase().trim() ?? '';
    final status = data['status']?.toString().toLowerCase().trim() ?? '';

    return approvalStatus == 'approved' ||
        status == 'active' ||
        data['isApproved'] == true;
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) return true;

    final searchableText = [
      data['name'],
      data['phone'],
      data['parentName'],
      data['parentEmail'],
      data['parentPhone'],
      data['batch'],
      data['rollNo'],
      data['feeStatus'],
      data['status'],
      data['approvalStatus'],
    ].whereType<Object>().map((value) {
      return value.toString().toLowerCase();
    }).join(' ');

    return searchableText.contains(query);
  }

  Future<String> _generateRollNumber(String studentName) async {
    if (studentName.trim().isEmpty) return "Y1";

    final firstLetter = studentName.trim()[0].toUpperCase();

    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('approvalStatus', isEqualTo: 'Approved')
        .get();

    int count = 0;

    for (final doc in snapshot.docs) {
      final rollNo = doc.data()['rollNo']?.toString().toUpperCase() ?? '';
      if (rollNo.startsWith(firstLetter)) count++;
    }

    return '$firstLetter${count + 1}';
  }

  Future<void> _autoLinkParentToStudent({
    required String studentId,
    required Map<String, dynamic> studentData,
  }) async {
    final rawParentEmail = studentData['parentEmail']?.toString().trim() ?? '';
    final parentEmailLower = _cleanEmail(rawParentEmail);

    final rawParentPhone =
        studentData['parentPhone']?.toString().trim().isNotEmpty == true
            ? studentData['parentPhone'].toString().trim()
            : studentData['phone']?.toString().trim() ?? '';

    final firestore = FirebaseFirestore.instance;

    await firestore.collection('students').doc(studentId).set({
      'parentEmail': rawParentEmail,
      'parentEmailLower': parentEmailLower,
      'parentPhone': rawParentPhone,
      'linkStatus': 'Checking Parent Account',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await firestore.collection('users').doc(studentId).set({
      'parentEmail': rawParentEmail,
      'parentEmailLower': parentEmailLower,
      'parentPhone': rawParentPhone,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    QuerySnapshot<Map<String, dynamic>> parentQuery;

    if (parentEmailLower.isNotEmpty) {
      parentQuery = await firestore
          .collection('users')
          .where('role', isEqualTo: 'Parent')
          .where('emailLower', isEqualTo: parentEmailLower)
          .limit(1)
          .get();

      if (parentQuery.docs.isEmpty && rawParentEmail.isNotEmpty) {
        parentQuery = await firestore
            .collection('users')
            .where('role', isEqualTo: 'Parent')
            .where('email', isEqualTo: rawParentEmail)
            .limit(1)
            .get();
      }
    } else {
      parentQuery = await firestore
          .collection('users')
          .where('role', isEqualTo: 'Parent')
          .where('phone', isEqualTo: rawParentPhone)
          .limit(1)
          .get();
    }

    if (parentQuery.docs.isEmpty && rawParentPhone.isNotEmpty) {
      parentQuery = await firestore
          .collection('users')
          .where('role', isEqualTo: 'Parent')
          .where('phone', isEqualTo: rawParentPhone)
          .limit(1)
          .get();
    }

    if (parentQuery.docs.isEmpty) {
      await firestore.collection('students').doc(studentId).set({
        'parentUid': '',
        'linkStatus': 'Parent Account Not Found',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await firestore.collection('users').doc(studentId).set({
        'parentUid': '',
        'linkStatus': 'Parent Account Not Found',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return;
    }

    final parentDoc = parentQuery.docs.first;
    final parentUid = parentDoc.id;

    await firestore.collection('users').doc(parentUid).set({
      'linkedChildrenIds': FieldValue.arrayUnion([studentId]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await firestore.collection('students').doc(studentId).set({
      'parentUid': parentUid,
      'parentEmail': rawParentEmail,
      'parentEmailLower': parentEmailLower,
      'parentPhone': rawParentPhone,
      'linkStatus': 'Linked',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await firestore.collection('users').doc(studentId).set({
      'parentUid': parentUid,
      'parentEmail': rawParentEmail,
      'parentEmailLower': parentEmailLower,
      'parentPhone': rawParentPhone,
      'linkStatus': 'Linked',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _showApprovalDialog({
    required BuildContext context,
    required QueryDocumentSnapshot doc,
    required bool isDark,
  }) async {
    final data = doc.data() as Map<String, dynamic>;

    final batchOptions = [
      "Friday: 6:00 PM – 8:00 PM",
      "Saturday: 7:00 AM – 9:00 AM",
      "Saturday: 4:00 PM – 6:00 PM",
      "Saturday: 6:00 PM – 8:00 PM",
    ];

    String selectedBatch = data['batch']?.toString() ?? batchOptions.first;

    if (!batchOptions.contains(selectedBatch)) {
      selectedBatch = batchOptions.first;
    }

    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _card(isDark),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: isDark ? red.withOpacity(0.35) : gold),
              ),
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: maroon,
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: gold,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Approve Student",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _approvalInfoTile(
                        isDark,
                        "Student Name",
                        data['name']?.toString() ?? 'No Name',
                      ),
                      _approvalInfoTile(
                        isDark,
                        "Parent",
                        data['parentName']?.toString() ?? 'Not Added',
                      ),
                      _approvalInfoTile(
                        isDark,
                        "Parent Email",
                        data['parentEmail']?.toString() ?? 'Not Added',
                      ),
                      _approvalInfoTile(
                        isDark,
                        "Phone",
                        data['phone']?.toString() ?? 'Not Added',
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.04)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border(isDark)),
                        ),
                        child: Text(
                          "Roll No will be generated automatically after approval",
                          style: TextStyle(
                            color: isDark ? gold : maroon,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedBatch,
                        dropdownColor: _card(isDark),
                        style: TextStyle(
                          color: _primaryText(isDark),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        decoration: InputDecoration(
                          labelText: "Session Batch",
                          labelStyle: TextStyle(
                            color: _secondaryText(isDark),
                          ),
                          prefixIcon: Icon(
                            Icons.groups_rounded,
                            color: isDark ? gold : maroon,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _border(isDark)),
                          ),
                        ),
                        items: batchOptions.map((batch) {
                          return DropdownMenuItem<String>(
                            value: batch,
                            child: Text(
                              batch,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedBatch = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          FocusScope.of(dialogContext).unfocus();
                          Navigator.of(dialogContext).pop();
                        },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: isDark ? Colors.white70 : maroon,
                      fontSize: 12,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? red : maroon,
                    foregroundColor: isDark ? Colors.white : gold,
                    minimumSize: const Size(105, 38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          FocusScope.of(dialogContext).unfocus();

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            final studentName =
                                data['name']?.toString().trim() ?? '';
                            final generatedRollNo =
                                await _generateRollNumber(studentName);

                            final parentEmail =
                                data['parentEmail']?.toString().trim() ?? '';
                            final parentEmailLower = _cleanEmail(parentEmail);

                            await FirebaseFirestore.instance
                                .collection('students')
                                .doc(doc.id)
                                .set({
                              'uid': doc.id,
                              'role': 'Student',
                              'batch': selectedBatch,
                              'rollNo': generatedRollNo,
                              'approvalStatus': 'Approved',
                              'status': 'Active',
                              'isApproved': true,
                              'approvedAt': FieldValue.serverTimestamp(),
                              'updatedAt': FieldValue.serverTimestamp(),
                              'attendance': data['attendance'] ?? '0%',
                              'feeStatus': data['feeStatus'] ?? 'Pending',
                              'parentEmail': parentEmail,
                              'parentEmailLower': parentEmailLower,
                            }, SetOptions(merge: true));

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(doc.id)
                                .set({
                              'uid': doc.id,
                              'role': 'Student',
                              'approvalStatus': 'Approved',
                              'status': 'Active',
                              'rollNo': generatedRollNo,
                              'batch': selectedBatch,
                              'isApproved': true,
                              'parentEmail': parentEmail,
                              'parentEmailLower': parentEmailLower,
                              'updatedAt': FieldValue.serverTimestamp(),
                            }, SetOptions(merge: true));

                            await _autoLinkParentToStudent(
                              studentId: doc.id,
                              studentData: {
                                ...data,
                                'parentEmail': parentEmail,
                              },
                            );

                            if (!mounted) return;

                            Navigator.of(dialogContext).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Student approved and parent linked if parent account exists",
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;

                            setDialogState(() {
                              isSaving = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Approval failed: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  icon: isSaving
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_rounded, size: 17),
                  label: Text(
                    isSaving ? "Saving..." : "Approve",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _rejectStudent({
    required BuildContext context,
    required QueryDocumentSnapshot doc,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            "Reject Student?",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          content: const Text(
            "This student will be marked as rejected and will not appear in the active student list.",
            style: TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text("Cancel", style: TextStyle(fontSize: 12)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(85, 38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text("Reject", style: TextStyle(fontSize: 12)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance.collection('students').doc(doc.id).set({
        'approvalStatus': 'Rejected',
        'status': 'Rejected',
        'isApproved': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance.collection('users').doc(doc.id).set({
        'approvalStatus': 'Rejected',
        'status': 'Rejected',
        'isApproved': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Student rejected"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Reject failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _approvalInfoTile(bool isDark, String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color:
            isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _border(isDark)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: isDark ? gold : maroon,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontWeight: FontWeight.w800,
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        final small = isSmallScreen;

        return Scaffold(
          backgroundColor: _bg(isDark),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: isDark ? red : maroon,
            foregroundColor: isDark ? Colors.white : gold,
            extendedPadding: const EdgeInsets.symmetric(horizontal: 16),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddStudentScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 19),
            label: const Text(
              "Add Student",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
          ),
          body: SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: _studentsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _messageCard(
                    isDark: isDark,
                    icon: Icons.error_outline_rounded,
                    title: "Something went wrong",
                    message: snapshot.error.toString(),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allStudents = snapshot.data?.docs ?? [];

                final pendingStudents = allStudents.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status =
                      data['status']?.toString().toLowerCase() ?? '';
                  final approvalStatus =
                      data['approvalStatus']?.toString().toLowerCase() ?? '';

                  return !_isApproved(data) &&
                      status != 'rejected' &&
                      approvalStatus != 'rejected' &&
                      _matchesSearch(data);
                }).toList();

                final approvedStudents = allStudents.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _isApproved(data) && _matchesSearch(data);
                }).toList();

                int totalAttendance = 0;

                for (final doc in approvedStudents) {
                  final data = doc.data() as Map<String, dynamic>;
                  final attendance = data['attendance']?.toString() ?? '0%';
                  totalAttendance += _percentValue(attendance);
                }

                final avgAttendance = approvedStudents.isEmpty
                    ? 0
                    : (totalAttendance / approvedStudents.length).round();

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    children: [
                      _topHeader(context, isDark),
                      _heroBanner(
                        isDark: isDark,
                        totalStudents: allStudents.length,
                        activeStudents: approvedStudents.length,
                        pendingApprovals: pendingStudents.length,
                      ),
                      SizedBox(height: small ? 14 : 18),
                      _sectionTitle(
                        isDark: isDark,
                        title: "STUDENT OVERVIEW",
                        leftIcon: Icons.dashboard_rounded,
                        rightIcon: Icons.insights_rounded,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: small ? 12 : 16,
                        ),
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: small ? 8 : 10,
                          mainAxisSpacing: small ? 8 : 10,
                          childAspectRatio: small ? 1.18 : 1.28,
                          children: [
                            _statCard(
                              isDark: isDark,
                              icon: Icons.groups_rounded,
                              title: "REGISTERED",
                              value: allStudents.length.toString(),
                              subtitle: "Students",
                              color: Colors.blueAccent,
                            ),
                            _statCard(
                              isDark: isDark,
                              icon: Icons.verified_rounded,
                              title: "APPROVED",
                              value: approvedStudents.length.toString(),
                              subtitle: "Active Players",
                              color: Colors.green,
                            ),
                            _statCard(
                              isDark: isDark,
                              icon: Icons.pending_actions_rounded,
                              title: "PENDING",
                              value: pendingStudents.length.toString(),
                              subtitle: "Approvals",
                              color: Colors.orange,
                            ),
                            _statCard(
                              isDark: isDark,
                              icon: Icons.bar_chart_rounded,
                              title: "ATTENDANCE",
                              value: "$avgAttendance%",
                              subtitle: "Average",
                              color: Colors.purpleAccent,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: small ? 14 : 18),
                      _sectionTitle(
                        isDark: isDark,
                        title: "SEARCH STUDENT",
                        leftIcon: Icons.search_rounded,
                        rightIcon: Icons.tune_rounded,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: small ? 12 : 16,
                        ),
                        child: _searchBox(isDark),
                      ),
                      SizedBox(height: small ? 14 : 18),
                      _sectionTitle(
                        isDark: isDark,
                        title: "PENDING APPROVAL",
                        leftIcon: Icons.pending_actions_rounded,
                        rightIcon: Icons.verified_user_outlined,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: small ? 12 : 16,
                        ),
                        child: pendingStudents.isEmpty
                            ? _emptyCard(
                                isDark: isDark,
                                icon: Icons.verified_user_outlined,
                                title: "No Pending Approvals",
                                subtitle:
                                    "Newly registered students will appear here for approval.",
                              )
                            : Column(
                                children: pendingStudents.map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;

                                  return _pendingStudentCard(
                                    context: context,
                                    isDark: isDark,
                                    doc: doc,
                                    name: data['name']?.toString() ?? 'No Name',
                                    age: data['age']?.toString() ?? '',
                                    parentName:
                                        data['parentName']?.toString() ??
                                            'Not Added',
                                    phone:
                                        data['phone']?.toString() ?? 'Not Added',
                                    registeredAt: data['createdAt'],
                                  );
                                }).toList(),
                              ),
                      ),
                      SizedBox(height: small ? 14 : 18),
                      _sectionTitle(
                        isDark: isDark,
                        title: "APPROVED STUDENTS",
                        leftIcon: Icons.people_alt_rounded,
                        rightIcon: Icons.arrow_forward_rounded,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: small ? 12 : 16,
                        ),
                        child: approvedStudents.isEmpty
                            ? _emptyCard(
                                isDark: isDark,
                                icon: Icons.people_outline_rounded,
                                title: "No Approved Students Found",
                                subtitle:
                                    "Approved students will appear here after assigning batch and roll number.",
                              )
                            : Column(
                                children: approvedStudents.map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;

                                  final name =
                                      data['name']?.toString() ?? 'No Name';
                                  final age = data['age']?.toString() ?? '';
                                  final batch =
                                      data['batch']?.toString() ?? 'No Batch';
                                  final phone =
                                      data['phone']?.toString() ?? '';
                                  final parentName =
                                      data['parentName']?.toString() ??
                                          'Not Added';
                                  final rollNo =
                                      data['rollNo']?.toString() ?? '#YGCA';
                                  final attendance =
                                      data['attendance']?.toString() ?? '0%';
                                  final feeStatus =
                                      data['feeStatus']?.toString() ??
                                          'Pending';

                                  return _studentCard(
                                    context: context,
                                    isDark: isDark,
                                    studentId: doc.id,
                                    name: name,
                                    age: age,
                                    batch: batch,
                                    rollNo: rollNo,
                                    parentName: parentName,
                                    phone: phone,
                                    attendance: attendance,
                                    feeStatus: feeStatus,
                                  );
                                }).toList(),
                              ),
                      ),
                      const SizedBox(height: 95),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _topHeader(BuildContext context, bool isDark) {
    final small = isSmallScreen;

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
            width: small ? 42 : 46,
            height: small ? 42 : 46,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "STUDENT CENTER",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: small ? 16 : 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  "Approval & student management",
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
          color: _card(isDark),
          shape: BoxShape.circle,
          border: Border.all(color: _border(isDark)),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? red.withOpacity(0.12)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : maroon,
          size: 21,
        ),
      ),
    );
  }

  Widget _heroBanner({
    required bool isDark,
    required int totalStudents,
    required int activeStudents,
    required int pendingApprovals,
  }) {
    final small = isSmallScreen;

    return Container(
      height: small ? 210 : 230,
      margin: EdgeInsets.fromLTRB(small ? 12 : 16, 12, small ? 12 : 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? red.withOpacity(0.55) : gold.withOpacity(0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.20) : maroon.withOpacity(0.16),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
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
                  colors: isDark
                      ? [
                          Colors.black.withOpacity(0.90),
                          darkMaroon.withOpacity(0.88),
                          red.withOpacity(0.35),
                        ]
                      : [
                          maroon.withOpacity(0.92),
                          maroon.withOpacity(0.72),
                          Colors.black.withOpacity(0.25),
                        ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Positioned(
            right: -22,
            bottom: -22,
            child: Icon(
              Icons.groups_rounded,
              color: Colors.white.withOpacity(0.08),
              size: 145,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(small ? 14 : 18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: small ? 39 : 46,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.groups_rounded,
                    color: maroon,
                    size: small ? 34 : 40,
                  ),
                ),
                SizedBox(width: small ? 12 : 16),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 230,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "YGCA",
                            style: TextStyle(
                              color: gold,
                              fontSize: small ? 12 : 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            "STUDENT",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: small ? 27 : 30,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          Text(
                            "APPROVAL",
                            style: TextStyle(
                              color: gold,
                              fontSize: small ? 22 : 25,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 7,
                            runSpacing: 6,
                            children: [
                              _heroChip("Registered: $totalStudents"),
                              _heroChip("Approved: $activeStudents"),
                              _heroChip("Pending: $pendingApprovals"),
                            ],
                          ),
                        ],
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

  Widget _heroChip(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gold.withOpacity(0.7)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: gold,
          fontSize: isSmallScreen ? 10 : 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _sectionTitle({
    required bool isDark,
    required String title,
    required IconData leftIcon,
    required IconData rightIcon,
  }) {
    final small = isSmallScreen;

    return Padding(
      padding: EdgeInsets.fromLTRB(small ? 12 : 16, 0, small ? 12 : 16, 10),
      child: Row(
        children: [
          Container(
            width: small ? 28 : 31,
            height: small ? 28 : 31,
            decoration: BoxDecoration(
              color: isDark ? red.withOpacity(0.12) : maroon.withOpacity(0.10),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: isDark ? red.withOpacity(0.25) : maroon.withOpacity(0.15),
              ),
            ),
            child: Icon(
              leftIcon,
              color: isDark ? gold : maroon,
              size: small ? 16 : 17,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  color: isDark ? gold : maroon,
                  fontSize: small ? 13 : 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(rightIcon, color: gold, size: small ? 17 : 19),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: isDark ? red.withOpacity(0.40) : gold.withOpacity(0.80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBox(bool isDark) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          color: _primaryText(isDark),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: "Search name, phone, parent, batch, roll no",
          hintStyle: TextStyle(
            color: _secondaryText(isDark),
            fontSize: 12,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? gold : maroon,
            size: 20,
          ),
          suffixIcon: searchQuery.trim().isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: _secondaryText(isDark),
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: _card(isDark),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _border(isDark)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _border(isDark)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: isDark ? red : gold, width: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final small = isSmallScreen;

    return Container(
      padding: EdgeInsets.all(small ? 8 : 10),
      decoration: BoxDecoration(
        color: _card(isDark),
        border: Border.all(
          color: isDark ? color.withOpacity(0.35) : _border(isDark),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? color.withOpacity(0.09)
                : Colors.black.withOpacity(0.045),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 138,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: small ? 17 : 19,
                backgroundColor: color.withOpacity(0.18),
                child: Icon(icon, color: color, size: small ? 17 : 19),
              ),
              SizedBox(height: small ? 6 : 7),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: small ? 17 : 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontWeight: FontWeight.bold,
                  fontSize: small ? 9.5 : 10.5,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: small ? 9 : 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pendingStudentCard({
    required BuildContext context,
    required bool isDark,
    required QueryDocumentSnapshot doc,
    required String name,
    required String age,
    required String parentName,
    required String phone,
    required dynamic registeredAt,
  }) {
    final small = isSmallScreen;

    String dateText = "Recently";

    if (registeredAt is Timestamp) {
      final date = registeredAt.toDate();
      dateText = "${date.day}/${date.month}/${date.year}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(small ? 12 : 14),
      decoration: BoxDecoration(
        color: _card(isDark),
        border: Border.all(color: Colors.orange.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.orange.withOpacity(0.09)
                : Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: small ? 23 : 26,
                backgroundColor: Colors.orange,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: small ? 15 : 17,
                  ),
                ),
              ),
              SizedBox(width: small ? 9 : 11),
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
                        fontSize: small ? 13 : 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Parent: $parentName",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontSize: small ? 11 : 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Phone: $phone",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontSize: small ? 11 : 12,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      children: [
                        _chip(
                          isDark,
                          Icons.pending_actions_rounded,
                          "Pending",
                          Colors.orange,
                        ),
                        _chip(
                          isDark,
                          Icons.calendar_month_rounded,
                          dateText,
                          Colors.blueGrey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _pendingActionButtons(
            context: context,
            doc: doc,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _pendingActionButtons({
    required BuildContext context,
    required QueryDocumentSnapshot doc,
    required bool isDark,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 330;

        final rejectButton = SizedBox(
          height: 39,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red, width: 1),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              _rejectStudent(context: context, doc: doc);
            },
            icon: const Icon(Icons.close_rounded, size: 15),
            label: const Text(
              "Reject",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );

        final approveButton = SizedBox(
          height: 39,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? red : maroon,
              foregroundColor: isDark ? Colors.white : gold,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              _showApprovalDialog(context: context, doc: doc, isDark: isDark);
            },
            icon: const Icon(Icons.assignment_turned_in_rounded, size: 15),
            label: const Text(
              "Approve Student",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );

        if (compact) {
          return Column(
            children: [
              SizedBox(width: double.infinity, child: approveButton),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: rejectButton),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: rejectButton),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: approveButton),
          ],
        );
      },
    );
  }

  Widget _studentCard({
    required BuildContext context,
    required bool isDark,
    required String studentId,
    required String name,
    required String age,
    required String batch,
    required String rollNo,
    required String parentName,
    required String phone,
    required String attendance,
    required String feeStatus,
  }) {
    final small = isSmallScreen;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentDetailsScreen(
                studentId: studentId,
                name: name,
                age: age,
                batch: batch,
                rollNo: rollNo,
                parentName: parentName,
                phone: phone,
                attendance: attendance,
                feeStatus: feeStatus,
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(small ? 12 : 14),
          decoration: BoxDecoration(
            color: _card(isDark),
            border: Border.all(color: _border(isDark)),
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? red.withOpacity(0.08)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: small ? 23 : 26,
                backgroundColor: maroon,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                  style: TextStyle(
                    color: gold,
                    fontWeight: FontWeight.bold,
                    fontSize: small ? 15 : 17,
                  ),
                ),
              ),
              SizedBox(width: small ? 9 : 11),
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
                        fontSize: small ? 13 : 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "$rollNo • $batch",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontSize: small ? 11 : 12,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      children: [
                        _chip(
                          isDark,
                          Icons.check_circle_rounded,
                          attendance,
                          Colors.green,
                        ),
                        _chip(
                          isDark,
                          Icons.payments_rounded,
                          feeStatus,
                          feeStatus == "Paid" ? Colors.green : Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: _secondaryText(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(bool isDark, IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 10 : 10.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final small = isSmallScreen;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(small ? 16 : 18),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        children: [
          Icon(icon, size: small ? 34 : 38, color: _secondaryText(isDark)),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
              fontSize: small ? 13 : 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondaryText(isDark),
              fontSize: small ? 11 : 12,
            ),
          ),
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