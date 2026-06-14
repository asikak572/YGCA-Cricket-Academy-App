import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_student_screen.dart';
import 'student_details_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

  String searchQuery = "";

  bool get isSmallScreen {
    final width = MediaQuery.of(context).size.width;
    return width < 370;
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
    if (searchQuery.trim().isEmpty) return true;

    final query = searchQuery.toLowerCase();

    final name = data['name']?.toString().toLowerCase() ?? '';
    final phone = data['phone']?.toString().toLowerCase() ?? '';
    final parentName = data['parentName']?.toString().toLowerCase() ?? '';
    final batch = data['batch']?.toString().toLowerCase() ?? '';
    final rollNo = data['rollNo']?.toString().toLowerCase() ?? '';

    return name.contains(query) ||
        phone.contains(query) ||
        parentName.contains(query) ||
        batch.contains(query) ||
        rollNo.contains(query);
  }

  Future<void> _showApprovalDialog({
    required BuildContext context,
    required QueryDocumentSnapshot doc,
  }) async {
    final data = doc.data() as Map<String, dynamic>;

    final batchController = TextEditingController(
      text: data['batch']?.toString() == 'No Batch'
          ? ''
          : data['batch']?.toString() ?? '',
    );

    final rollNoController = TextEditingController(
      text: data['rollNo']?.toString() == '#YGCA'
          ? ''
          : data['rollNo']?.toString() ?? '',
    );

    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              titlePadding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              contentPadding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
              actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: maroon,
                    child: Icon(Icons.verified_user, color: gold, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Approve Student",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
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
                        "Student Name",
                        data['name']?.toString() ?? 'No Name',
                      ),
                      _approvalInfoTile(
                        "Parent",
                        data['parentName']?.toString() ?? 'Not Added',
                      ),
                      _approvalInfoTile(
                        "Phone",
                        data['phone']?.toString() ?? 'Not Added',
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: batchController,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          labelText: "Assign Batch",
                          hintText: "Example: U-14 Morning",
                          prefixIcon: const Icon(Icons.groups, size: 20),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please assign batch";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: rollNoController,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          labelText: "Assign Roll No",
                          hintText: "Example: YGCA-001",
                          prefixIcon: const Icon(
                            Icons.confirmation_number,
                            size: 20,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please assign roll number";
                          }
                          return null;
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
                  child: const Text("Cancel", style: TextStyle(fontSize: 12)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroon,
                    foregroundColor: gold,
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
                            await FirebaseFirestore.instance
                                .collection('students')
                                .doc(doc.id)
                                .update({
                                  'batch': batchController.text.trim(),
                                  'rollNo': rollNoController.text.trim(),
                                  'approvalStatus': 'Approved',
                                  'status': 'Active',
                                  'isApproved': true,
                                  'approvedAt': FieldValue.serverTimestamp(),
                                  'updatedAt': FieldValue.serverTimestamp(),
                                  'attendance': data['attendance'] ?? '0%',
                                  'feeStatus': data['feeStatus'] ?? 'Pending',
                                });

                            if (!mounted) return;

                            Navigator.of(dialogContext).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Student approved successfully"),
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
                      : const Icon(Icons.check_circle, size: 17),
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

    // IMPORTANT:
    // Do not dispose batchController and rollNoController here.
    // Flutter may still rebuild the dialog during closing animation.
  }

  Future<void> _rejectStudent({
    required BuildContext context,
    required QueryDocumentSnapshot doc,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
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
      await FirebaseFirestore.instance
          .collection('students')
          .doc(doc.id)
          .update({
            'approvalStatus': 'Rejected',
            'status': 'Rejected',
            'isApproved': false,
            'updatedAt': FieldValue.serverTimestamp(),
          });

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

  Widget _approvalInfoTile(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: maroon),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
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
    final small = isSmallScreen;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('students')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong"));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allStudents = snapshot.data?.docs ?? [];

            final pendingStudents = allStudents.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status']?.toString().toLowerCase() ?? '';
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
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  _topHeader(context),
                  _heroBanner(
                    totalStudents: allStudents.length,
                    activeStudents: approvedStudents.length,
                    pendingApprovals: pendingStudents.length,
                  ),
                  SizedBox(height: small ? 14 : 18),

                  _sectionTitle(
                    title: "STUDENT OVERVIEW",
                    leftIcon: Icons.dashboard_rounded,
                    rightIcon: Icons.insights_rounded,
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: small ? 12 : 16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: small ? 8 : 10,
                      mainAxisSpacing: small ? 8 : 10,
                      childAspectRatio: small ? 1.18 : 1.28,
                      children: [
                        _statCard(
                          Icons.groups,
                          "REGISTERED",
                          allStudents.length.toString(),
                          "Students",
                          Colors.blue,
                        ),
                        _statCard(
                          Icons.verified,
                          "APPROVED",
                          approvedStudents.length.toString(),
                          "Active Players",
                          Colors.green,
                        ),
                        _statCard(
                          Icons.pending_actions,
                          "PENDING",
                          pendingStudents.length.toString(),
                          "Approvals",
                          Colors.orange,
                        ),
                        _statCard(
                          Icons.bar_chart,
                          "ATTENDANCE",
                          "$avgAttendance%",
                          "Average",
                          Colors.purple,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: small ? 14 : 18),

                  _sectionTitle(
                    title: "SEARCH STUDENT",
                    leftIcon: Icons.search_rounded,
                    rightIcon: Icons.tune_rounded,
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: small ? 12 : 16),
                    child: _searchBox(),
                  ),

                  SizedBox(height: small ? 14 : 18),

                  _sectionTitle(
                    title: "PENDING APPROVAL",
                    leftIcon: Icons.pending_actions_rounded,
                    rightIcon: Icons.verified_user_outlined,
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: small ? 12 : 16),
                    child: pendingStudents.isEmpty
                        ? _emptyCard(
                            icon: Icons.verified_user_outlined,
                            title: "No Pending Approvals",
                            subtitle:
                                "Newly registered students will appear here for batch and roll number assignment.",
                          )
                        : Column(
                            children: pendingStudents.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;

                              return _pendingStudentCard(
                                context: context,
                                doc: doc,
                                name: data['name']?.toString() ?? 'No Name',
                                age: data['age']?.toString() ?? '',
                                parentName:
                                    data['parentName']?.toString() ??
                                    'Not Added',
                                phone: data['phone']?.toString() ?? 'Not Added',
                                registeredAt: data['createdAt'],
                              );
                            }).toList(),
                          ),
                  ),

                  SizedBox(height: small ? 14 : 18),

                  _sectionTitle(
                    title: "APPROVED STUDENTS",
                    leftIcon: Icons.people_alt_rounded,
                    rightIcon: Icons.arrow_forward_rounded,
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: small ? 12 : 16),
                    child: approvedStudents.isEmpty
                        ? _emptyCard(
                            icon: Icons.people_outline,
                            title: "No Approved Students Found",
                            subtitle:
                                "Approved students will appear here after assigning batch and roll number.",
                          )
                        : Column(
                            children: approvedStudents.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;

                              final name =
                                  data['name']?.toString() ?? 'No Name';
                              final age = data['age']?.toString() ?? '';
                              final batch =
                                  data['batch']?.toString() ?? 'No Batch';
                              final phone = data['phone']?.toString() ?? '';
                              final parentName =
                                  data['parentName']?.toString() ?? 'Not Added';
                              final rollNo =
                                  data['rollNo']?.toString() ?? '#YGCA';
                              final attendance =
                                  data['attendance']?.toString() ?? '0%';
                              final feeStatus =
                                  data['feeStatus']?.toString() ?? 'Pending';

                              return _studentCard(
                                context: context,
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: maroon,
        foregroundColor: gold,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 16),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStudentScreen()),
          );
        },
        icon: const Icon(Icons.add, size: 19),
        label: const Text(
          "Add Student",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _topHeader(BuildContext context) {
    final small = isSmallScreen;

    return Container(
      color: maroon,
      padding: EdgeInsets.fromLTRB(12, small ? 12 : 16, 14, 16),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Image.asset('assets/images/ygca_logo.jpg', width: small ? 44 : 52),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "STUDENT CENTER",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: gold,
                fontSize: small ? 16 : 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
          CircleAvatar(
            radius: small ? 18 : 20,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.people,
              color: Colors.black,
              size: small ? 19 : 21,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroBanner({
    required int totalStudents,
    required int activeStudents,
    required int pendingApprovals,
  }) {
    final small = isSmallScreen;

    return Container(
      height: small ? 205 : 225,
      margin: EdgeInsets.symmetric(horizontal: small ? 12 : 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
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
            padding: EdgeInsets.all(small ? 14 : 18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: small ? 38 : 46,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.groups,
                    color: maroon,
                    size: small ? 34 : 40,
                  ),
                ),
                SizedBox(width: small ? 12 : 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "YGCA",
                        style: TextStyle(
                          color: gold,
                          fontSize: small ? 12 : 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "STUDENT",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: small ? 25 : 29,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      Text(
                        "APPROVAL",
                        style: TextStyle(
                          color: gold,
                          fontSize: small ? 21 : 24,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gold.withOpacity(0.7)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: gold,
          fontSize: isSmallScreen ? 10 : 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionTitle({
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
              color: maroon.withOpacity(0.10),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: maroon.withOpacity(0.15)),
            ),
            child: Icon(leftIcon, color: maroon, size: small ? 16 : 17),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: maroon,
                fontSize: small ? 13 : 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
              ),
            ),
          ),
          // const SizedBox(width: 8),
          // Expanded(
          //   child: Container(
          //     height: 1.4,
          //     decoration: BoxDecoration(
          //       color: gold.withOpacity(0.85),
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //   ),
          // ),
          const SizedBox(width: 8),
          Icon(rightIcon, color: gold, size: small ? 17 : 19),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return SizedBox(
      height: 48,
      child: TextField(
        style: const TextStyle(fontSize: 13),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: "Search name, phone, parent, batch",
          hintStyle: const TextStyle(fontSize: 12),
          prefixIcon: Icon(Icons.search, color: maroon, size: 20),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: gold, width: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _statCard(
    IconData icon,
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    final small = isSmallScreen;

    return Container(
      padding: EdgeInsets.all(small ? 8 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: small ? 17 : 19,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: small ? 17 : 19),
          ),
          SizedBox(height: small ? 6 : 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
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
              fontWeight: FontWeight.bold,
              fontSize: small ? 9.5 : 10.5,
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey, fontSize: small ? 9 : 10),
          ),
        ],
      ),
    );
  }

  Widget _pendingStudentCard({
    required BuildContext context,
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
        color: Colors.white,
        border: Border.all(color: Colors.orange.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                        color: const Color(0xFF64748B),
                        fontSize: small ? 11 : 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Phone: $phone",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: small ? 11 : 12,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      children: [
                        _chip(Icons.pending_actions, "Pending", Colors.orange),
                        _chip(Icons.calendar_month, dateText, Colors.blueGrey),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _pendingActionButtons(context: context, doc: doc),
        ],
      ),
    );
  }

  Widget _pendingActionButtons({
    required BuildContext context,
    required QueryDocumentSnapshot doc,
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
            icon: const Icon(Icons.close, size: 15),
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
              backgroundColor: maroon,
              foregroundColor: gold,
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
              _showApprovalDialog(context: context, doc: doc);
            },
            icon: const Icon(Icons.assignment_turned_in, size: 15),
            label: const Text(
              "Assign & Approve",
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(small ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                      color: const Color(0xFF64748B),
                      fontSize: small ? 11 : 12,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    runSpacing: 5,
                    children: [
                      _chip(Icons.check_circle, attendance, Colors.green),
                      _chip(
                        Icons.payments,
                        feeStatus,
                        feeStatus == "Paid" ? Colors.green : Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 15, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Icon(icon, size: small ? 34 : 38, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: small ? 13 : 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: small ? 11 : 12),
          ),
        ],
      ),
    );
  }
}
