import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeeReportScreen extends StatelessWidget {
  const FeeReportScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Fee Reports"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('fees')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final feeDocs = snapshot.data?.docs ?? [];

          int totalFee = 0;
          int collected = 0;
          int pending = 0;
          int paidStudents = 0;

          for (final doc in feeDocs) {
            final data = doc.data() as Map<String, dynamic>;

            final total = (data['totalFee'] ?? 0) as int;
            final paid = (data['paidAmount'] ?? 0) as int;
            final pendingAmount = (data['pendingAmount'] ?? 0) as int;
            final status = data['status']?.toString() ?? 'Pending';

            totalFee += total;
            collected += paid;
            pending += pendingAmount;

            if (status == "Paid") {
              paidStudents++;
            }
          }

          final collectionPercent =
              totalFee == 0 ? 0 : ((collected / totalFee) * 100).round();

          final pendingStudents = feeDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final pendingAmount = (data['pendingAmount'] ?? 0) as int;
            return pendingAmount > 0;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _heroCard(collectionPercent),
                const SizedBox(height: 16),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.35,
                  children: [
                    _statCard(
                      "Total Fee",
                      "₹$totalFee",
                      Icons.account_balance_wallet,
                      gold,
                    ),
                    _statCard(
                      "Collected",
                      "₹$collected",
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _statCard(
                      "Pending",
                      "₹$pending",
                      Icons.warning,
                      Colors.orange,
                    ),
                    _statCard(
                      "Paid Records",
                      paidStudents.toString(),
                      Icons.people,
                      Colors.blue,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _sectionTitle("Payment Records"),

                if (feeDocs.isEmpty)
                  const Card(
                    child: ListTile(
                      title: Text("No fee records found"),
                      subtitle: Text("Add payments from Fee Management"),
                    ),
                  )
                else
                  ...feeDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final name =
                        data['studentName']?.toString() ?? 'Unknown Student';
                    final studentId = data['studentId']?.toString() ?? '';
                    final total = (data['totalFee'] ?? 0) as int;
                    final paid = (data['paidAmount'] ?? 0) as int;
                    final pendingAmount = (data['pendingAmount'] ?? 0) as int;

                    final progress =
                        total == 0 ? 0.0 : (paid / total).clamp(0.0, 1.0);

                    return _collectionTile(
                      title: name,
                      subtitle: "ID: $studentId",
                      amount: "Paid ₹$paid / ₹$total",
                      progress: progress,
                      pending: "Pending ₹$pendingAmount",
                    );
                  }),

                const SizedBox(height: 18),

                _sectionTitle("Pending Fee Students"),

                if (pendingStudents.isEmpty)
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text("No pending fees"),
                      subtitle: Text("All fee records are completed"),
                    ),
                  )
                else
                  ...pendingStudents.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return _pendingStudentCard(
                      name: data['studentName']?.toString() ?? 'Unknown',
                      batch: "ID: ${data['studentId']?.toString() ?? ''}",
                      amount: "₹${data['pendingAmount'] ?? 0}",
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _heroCard(int collectionPercent) {
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
            "Firebase Fee Report",
            style: TextStyle(
              color: gold,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Academy fee collection summary",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: collectionPercent / 100,
            backgroundColor: Colors.white24,
            color: gold,
            minHeight: 7,
          ),
          const SizedBox(height: 8),
          Text(
            "$collectionPercent% fee collection completed",
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _collectionTile({
    required String title,
    required String subtitle,
    required String amount,
    required double progress,
    required String pending,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    color: maroon,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE2E8F0),
              color: gold,
              minHeight: 6,
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                pending,
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pendingStudentCard({
    required String name,
    required String batch,
    required String amount,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: maroon,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : "?",
            style: TextStyle(color: gold, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(batch),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            amount,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}