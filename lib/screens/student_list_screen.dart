import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_student_screen.dart';
import 'student_details_screen.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

  int _percentValue(String value) {
    return int.tryParse(value.replaceAll("%", "").trim()) ?? 0;
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

          final students = snapshot.data?.docs ?? [];

          int activeCount = 0;
          int pendingFees = 0;
          int totalAttendance = 0;

          for (final doc in students) {
            final data = doc.data() as Map<String, dynamic>;

            final status = data['status']?.toString() ?? 'Active';
            final feeStatus = data['feeStatus']?.toString() ?? 'Pending';
            final attendance = data['attendance']?.toString() ?? '0%';

            if (status == 'Active') activeCount++;
            if (feeStatus != 'Paid') pendingFees++;
            totalAttendance += _percentValue(attendance);
          }

          final avgAttendance = students.isEmpty
              ? 0
              : (totalAttendance / students.length).round();

          return SingleChildScrollView(
            child: Column(
              children: [
                _topHeader(context),
                _heroBanner(
                  totalStudents: students.length,
                  activeStudents: activeCount,
                  pendingFees: pendingFees,
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
                        "TOTAL",
                        students.length.toString(),
                        "Students",
                        Colors.blue,
                      ),
                      _statCard(
                        Icons.verified,
                        "ACTIVE",
                        activeCount.toString(),
                        "Players",
                        Colors.green,
                      ),
                      _statCard(
                        Icons.warning_amber,
                        "PENDING",
                        pendingFees.toString(),
                        "Fees",
                        Colors.orange,
                      ),
                      _statCard(
                        Icons.bar_chart,
                        "AVG ATTENDANCE",
                        "$avgAttendance%",
                        "Overall",
                        Colors.purple,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                _sectionTitle("STUDENT LIST"),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _searchBox(),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: students.isEmpty
                      ? _emptyCard()
                      : Column(
                          children: students.map((doc) {
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
            MaterialPageRoute(
              builder: (context) => const AddStudentScreen(),
            ),
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
          Image.asset(
            'assets/images/ygca_logo.jpg',
            width: 58,
          ),
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
    required int pendingFees,
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
                        "CENTER",
                        style: TextStyle(
                          color: gold,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _heroChip("Total: $totalStudents"),
                          _heroChip("Active: $activeStudents"),
                          _heroChip("Pending Fees: $pendingFees"),
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
      decoration: InputDecoration(
        hintText: "Search Student",
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
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
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
                      _chip(
                        Icons.check_circle,
                        attendance,
                        Colors.green,
                      ),
                      _chip(
                        Icons.payments,
                        feeStatus,
                        feeStatus == "Paid"
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(
    IconData icon,
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
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

  Widget _emptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: const Column(
        children: [
          Icon(Icons.people_outline, size: 40, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No Students Found",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}