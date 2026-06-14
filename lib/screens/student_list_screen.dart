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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: maroon,
                    child: Icon(Icons.verified_user, color: gold),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Approve Student",
                      style: TextStyle(fontWeight: FontWeight.w900),
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
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: batchController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: "Assign Batch",
                          hintText: "Example: U-14 Morning Batch",
                          prefixIcon: const Icon(Icons.groups),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please assign batch";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: rollNoController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: "Assign Roll No",
                          hintText: "Example: YGCA-001",
                          prefixIcon: const Icon(Icons.confirmation_number),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
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
                          Navigator.pop(dialogContext);
                        },
                  child: const Text("Cancel"),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroon,
                    foregroundColor: gold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

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

                            Navigator.pop(dialogContext);

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
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle),
                  label: Text(isSaving ? "Approving..." : "Approve"),
                ),
              ],
            );
          },
        );
      },
    );

    batchController.dispose();
    rollNoController.dispose();
  }

  Future<void> _rejectStudent({
    required BuildContext context,
    required QueryDocumentSnapshot doc,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Reject Student?"),
          content: const Text(
            "This student will be marked as rejected and will not appear in the active student list.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text("Reject"),
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: StreamBuilder<QuerySnapshot>(
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

          int pendingFees = 0;
          int totalAttendance = 0;

          for (final doc in approvedStudents) {
            final data = doc.data() as Map<String, dynamic>;

            final feeStatus = data['feeStatus']?.toString() ?? 'Pending';
            final attendance = data['attendance']?.toString() ?? '0%';

            if (feeStatus != 'Paid') pendingFees++;
            totalAttendance += _percentValue(attendance);
          }

          final avgAttendance = approvedStudents.isEmpty
              ? 0
              : (totalAttendance / approvedStudents.length).round();

          return SingleChildScrollView(
            child: Column(
              children: [
                _topHeader(context),
                _heroBanner(
                  totalStudents: allStudents.length,
                  activeStudents: approvedStudents.length,
                  pendingApprovals: pendingStudents.length,
                ),
                const SizedBox(height: 18),
                _sectionTitle("STUDENT OVERVIEW"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.25,
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
                        "AVG ATTENDANCE",
                        "$avgAttendance%",
                        "Approved Students",
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _sectionTitle("SEARCH STUDENT"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _searchBox(),
                ),
                const SizedBox(height: 18),
                _sectionTitle("PENDING APPROVAL"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                  data['parentName']?.toString() ?? 'Not Added',
                              phone: data['phone']?.toString() ?? 'Not Added',
                              registeredAt: data['createdAt'],
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 18),
                _sectionTitle("APPROVED STUDENT LIST"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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

                            final name = data['name']?.toString() ?? 'No Name';
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
                const SizedBox(height: 90),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: maroon,
        foregroundColor: gold,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStudentScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Student"),
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
          Image.asset('assets/images/ygca_logo.jpg', width: 58),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "STUDENT CENTER",
              style: TextStyle(
                color: gold,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.people, color: Colors.black),
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
                  child: Icon(Icons.groups, color: maroon, size: 42),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "YGCA",
                        style: TextStyle(
                          color: gold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "STUDENT",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 31,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      Text(
                        "APPROVAL",
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
          Text(
            title,
            style: TextStyle(
              color: maroon,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 42, height: 2, color: gold),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return TextField(
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: "Search by name, phone, parent, batch or roll no",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: border),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
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
    String dateText = "Recently Registered";

    if (registeredAt is Timestamp) {
      final date = registeredAt.toDate();
      dateText = "${date.day}/${date.month}/${date.year}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.orange.withOpacity(0.35)),
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
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.orange,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
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
                    const SizedBox(height: 4),
                    Text(
                      "Parent: $parentName",
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Phone: $phone",
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        _chip(
                          Icons.pending_actions,
                          "Pending Approval",
                          Colors.orange,
                        ),
                        _chip(Icons.calendar_month, dateText, Colors.blueGrey),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    _rejectStudent(context: context, doc: doc);
                  },
                  icon: const Icon(Icons.close),
                  label: const Text("Reject"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroon,
                    foregroundColor: gold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    _showApprovalDialog(context: context, doc: doc);
                  },
                  icon: const Icon(Icons.assignment_turned_in),
                  label: const Text("Assign & Approve"),
                ),
              ),
            ],
          ),
        ],
      ),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
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
              radius: 28,
              backgroundColor: maroon,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : "?",
                style: TextStyle(
                  color: gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
                  const SizedBox(height: 4),
                  Text(
                    "$rollNo • $batch",
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
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
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
