import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  Future<Map<String, dynamic>> _loadStats() async {
    final firestore = FirebaseFirestore.instance;

    final students = await firestore.collection('students').get();
    final fees = await firestore.collection('fees').get();
    final attendance = await firestore.collection('attendance').get();
    final performance = await firestore.collection('performance_reports').get();
    final leaves = await firestore.collection('leave_requests').get();
    final matches = await firestore.collection('matches').get();
    final salaries = await firestore.collection('coach_salaries').get();

    int collected = 0;
    int pending = 0;
    int salaryBudget = 0;

    for (final doc in fees.docs) {
      final data = doc.data();
      collected += int.tryParse(data['paidAmount'].toString()) ?? 0;
      pending += int.tryParse(data['pendingAmount'].toString()) ?? 0;
    }

    for (final doc in salaries.docs) {
      final data = doc.data();
      salaryBudget += int.tryParse(data['salary'].toString()) ?? 0;
    }

    return {
      'students': students.docs.length,
      'collected': collected,
      'pending': pending,
      'attendance': attendance.docs.length,
      'performance': performance.docs.length,
      'leaves': leaves.docs.length,
      'matches': matches.docs.length,
      'salaryBudget': salaryBudget,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Reports Dashboard"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? {};

          return GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _card("Students", data['students'].toString(), Icons.people),
              _card("Collected", "₹${data['collected']}", Icons.payments),
              _card("Pending Fees", "₹${data['pending']}", Icons.warning),
              _card("Attendance", data['attendance'].toString(), Icons.check_circle),
              _card("Performance", data['performance'].toString(), Icons.bar_chart),
              _card("Leave Requests", data['leaves'].toString(), Icons.event_note),
              _card("Matches", data['matches'].toString(), Icons.sports_cricket),
              _card("Salary Budget", "₹${data['salaryBudget']}", Icons.wallet),
            ],
          );
        },
      ),
    );
  }

  Widget _card(String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: gold, size: 34),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}