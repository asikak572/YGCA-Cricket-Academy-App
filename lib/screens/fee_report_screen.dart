import 'package:flutter/material.dart';

class FeeReportScreen extends StatelessWidget {
  const FeeReportScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final pendingStudents = [
      {
        "name": "Kiran M",
        "batch": "Evening Batch",
        "pending": "₹4,000",
      },
      {
        "name": "Priya S",
        "batch": "Junior Batch",
        "pending": "₹5,000",
      },
      {
        "name": "Rahul K",
        "batch": "Senior Batch",
        "pending": "₹3,000",
      },
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Fee Reports"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _heroCard(),

            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.35,
              children: [
                _statCard("Total Fee", "₹60K", Icons.account_balance_wallet, gold),
                _statCard("Collected", "₹48K", Icons.check_circle, Colors.green),
                _statCard("Pending", "₹12K", Icons.warning, Colors.orange),
                _statCard("Paid Students", "7", Icons.people, Colors.blue),
              ],
            ),

            const SizedBox(height: 18),

            _sectionTitle("Monthly Collection"),

            _collectionTile("January", "₹42,000", 0.70),
            _collectionTile("February", "₹48,000", 0.80),
            _collectionTile("March", "₹55,000", 0.90),
            _collectionTile("April", "₹46,000", 0.76),

            const SizedBox(height: 18),

            _sectionTitle("Pending Fee Students"),

            ...pendingStudents.map((student) {
              return _pendingStudentCard(
                name: student["name"]!,
                batch: student["batch"]!,
                amount: student["pending"]!,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _heroCard() {
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
            "June 2026 Fee Report",
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
          const LinearProgressIndicator(
            value: 0.80,
            backgroundColor: Colors.white24,
            color: Color(0xFFD4AF37),
            minHeight: 7,
          ),
          const SizedBox(height: 8),
          const Text(
            "80% fee collection completed",
            style: TextStyle(color: Colors.white, fontSize: 12),
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

  Widget _collectionTile(String month, String amount, double progress) {
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
                    month,
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
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE2E8F0),
              color: gold,
              minHeight: 6,
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
            name[0],
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