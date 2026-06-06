import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingFeesScreen extends StatelessWidget {
  const PendingFeesScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Fees"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('fees')
            .where('pendingAmount', isGreaterThan: 0)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pendingStudents = snapshot.data?.docs ?? [];

          int totalPending = 0;

          for (final doc in pendingStudents) {
            final data = doc.data() as Map<String, dynamic>;
            totalPending += (data['pendingAmount'] ?? 0) as int;
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: maroon,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      "Total Pending Amount",
                      style: TextStyle(
                        color: gold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "₹$totalPending",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: pendingStudents.isEmpty
                    ? const Center(
                        child: Text("No pending fees found"),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: pendingStudents.length,
                        itemBuilder: (context, index) {
                          final data = pendingStudents[index].data()
                              as Map<String, dynamic>;

                          final name =
                              data['studentName']?.toString() ?? 'Unknown';
                          final studentId =
                              data['studentId']?.toString() ?? '';
                          final pendingAmount =
                              (data['pendingAmount'] ?? 0).toString();

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: maroon,
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                                  style: TextStyle(
                                    color: gold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text("ID: $studentId"),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "₹$pendingAmount",
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    "Pending",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}