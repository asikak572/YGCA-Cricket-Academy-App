import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

  Future<Map<String, dynamic>> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return {};
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      return {};
    }

    return {
      'uid': user.uid,
      ...doc.data()!,
    };
  }

  Query<Map<String, dynamic>> _attendanceQuery(Map<String, dynamic> userData) {
    final role = userData['role']?.toString() ?? '';
    final uid = userData['uid']?.toString() ?? '';

    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('attendance');

    if (role == 'Student') {
      query = query.where('studentId', isEqualTo: uid);
    } else if (role == 'Coach') {
      final batch = userData['assignedBatch']?.toString().isNotEmpty == true
          ? userData['assignedBatch'].toString()
          : userData['batch']?.toString() ?? '';

      if (batch.isNotEmpty) {
        query = query.where('batch', isEqualTo: batch);
      }
    } else if (role == 'Parent') {
      final linkedChildrenIds = userData['linkedChildrenIds'];

      if (linkedChildrenIds is List && linkedChildrenIds.isNotEmpty) {
        query = query.where(
          'studentId',
          whereIn: linkedChildrenIds.take(10).toList(),
        );
      } else if (userData['childId'] != null &&
          userData['childId'].toString().isNotEmpty) {
        query = query.where(
          'studentId',
          isEqualTo: userData['childId'].toString(),
        );
      } else if (userData['childName'] != null &&
          userData['childName'].toString().isNotEmpty) {
        query = query.where(
          'studentName',
          isEqualTo: userData['childName'].toString(),
        );
      }
    }

    return query.orderBy('date', descending: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserData(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || userSnapshot.data!.isEmpty) {
            return const Center(child: Text("User data not found"));
          }

          final userData = userSnapshot.data!;
          final role = userData['role']?.toString() ?? 'User';

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _attendanceQuery(userData).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final records = snapshot.data?.docs ?? [];

              int present = 0;
              int absent = 0;
              int leave = 0;

              for (final doc in records) {
                final data = doc.data();
                final status = data['status']?.toString() ?? 'Absent';

                if (status == "Present") {
                  present++;
                } else if (status == "Leave") {
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
                    _topHeader(context),
                    _heroBanner(
                      role: role,
                      total: total,
                      present: present,
                      absent: absent,
                      leave: leave,
                      percentage: percentage,
                    ),
                    const SizedBox(height: 18),
                    _sectionTitle("ATTENDANCE SUMMARY"),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _calendarGraph(records),
                    ),
                    const SizedBox(height: 18),
                    _sectionTitle("RECENT RECORDS"),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: records.isEmpty
                          ? _emptyCard()
                          : Column(
                              children: records.map((doc) {
                                final data = doc.data();

                                return _historyCard(
                                  studentName:
                                      data['studentName']?.toString() ??
                                          'Unknown Student',
                                  batch: data['batch']?.toString() ??
                                      'Unknown Batch',
                                  date: data['date']?.toString() ?? 'No Date',
                                  status:
                                      data['status']?.toString() ?? 'Absent',
                                );
                              }).toList(),
                            ),
                    ),
                    const SizedBox(height: 26),
                  ],
                ),
              );
            },
          );
        },
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
      final date = data['date']?.toString() ?? '';
      final status = data['status']?.toString() ?? 'Absent';

      if (date.isNotEmpty) {
        statusByDate[date] = status;
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
              final dateId =
                  "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

              final status = statusByDate[dateId] ?? 'No Record';

              Color color;
              if (status == "Present") {
                color = Colors.green;
              } else if (status == "Leave") {
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

    if (status == "Present") {
      statusColor = Colors.green;
      icon = Icons.check_circle;
    } else if (status == "Leave") {
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