import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/pdf_service.dart';
import '../services/excel_service.dart';

class FeeReportScreen extends StatefulWidget {
  const FeeReportScreen({super.key});

  @override
  State<FeeReportScreen> createState() => _FeeReportScreenState();
}

class _FeeReportScreenState extends State<FeeReportScreen> {
  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  Future<Map<String, dynamic>> _getUserAccess() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return {'role': '', 'allowedIds': <String>[]};
    }

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      return {'role': '', 'allowedIds': <String>[]};
    }

    final data = userDoc.data() ?? {};
    final role = data['role']?.toString() ?? '';

    if (role == 'Admin') {
      return {'role': role, 'allowedIds': <String>['ALL']};
    }

    if (role == 'Student') {
      return {'role': role, 'allowedIds': <String>[user.uid]};
    }

    if (role == 'Parent') {
      final linkedChildrenIds = data['linkedChildrenIds'];

      if (linkedChildrenIds is List && linkedChildrenIds.isNotEmpty) {
        return {
          'role': role,
          'allowedIds': linkedChildrenIds.map((e) => e.toString()).toList(),
        };
      }
    }

    return {'role': role, 'allowedIds': <String>[]};
  }

  List<QueryDocumentSnapshot> _filterDocs(
    List<QueryDocumentSnapshot> docs,
    List<String> allowedIds,
  ) {
    if (allowedIds.contains('ALL')) return docs;

    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final studentId = data['studentId']?.toString() ?? '';
      return allowedIds.contains(studentId);
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _getFeeRecords() async {
    final access = await _getUserAccess();
    final allowedIds = List<String>.from(access['allowedIds'] ?? []);

    final snapshot = await FirebaseFirestore.instance.collection('fees').get();

    final docs = _filterDocs(snapshot.docs, allowedIds);

    return docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> _generatePdf() async {
    final records = await _getFeeRecords();

    int totalFee = 0;
    int collected = 0;
    int pending = 0;
    int paidStudents = 0;

    for (final data in records) {
      totalFee += _toInt(data['totalFee']);
      collected += _toInt(data['paidAmount']);
      pending += _toInt(data['pendingAmount']);

      if (data['status']?.toString() == "Paid") {
        paidStudents++;
      }
    }

    await PdfService.generateFeeReportPdf(
      totalFee: totalFee,
      collected: collected,
      pending: pending,
      paidStudents: paidStudents,
      feeRecords: records,
    );
  }

  Future<void> _generateExcel() async {
    final records = await _getFeeRecords();

    await ExcelService.generateFeeReportExcel(
      feeRecords: records,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          "Fee Reports",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: "Export PDF",
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
          ),
          IconButton(
            tooltip: "Export Excel",
            icon: const Icon(Icons.table_chart),
            onPressed: _generateExcel,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserAccess(),
        builder: (context, accessSnapshot) {
          if (accessSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!accessSnapshot.hasData) {
            return const Center(child: Text("User access not found"));
          }

          final accessData = accessSnapshot.data!;
          final allowedIds = List<String>.from(accessData['allowedIds'] ?? []);

          return StreamBuilder<QuerySnapshot>(
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

              final allDocs = snapshot.data?.docs ?? [];
              final feeDocs = _filterDocs(allDocs, allowedIds);

              int totalFee = 0;
              int collected = 0;
              int pending = 0;
              int paidStudents = 0;

              for (final doc in feeDocs) {
                final data = doc.data() as Map<String, dynamic>;

                final total = _toInt(data['totalFee']);
                final paid = _toInt(data['paidAmount']);
                final pendingAmount = _toInt(data['pendingAmount']);
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
                final pendingAmount = _toInt(data['pendingAmount']);
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
                          subtitle: Text("No fee record available for this user"),
                        ),
                      )
                    else
                      ...feeDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        final name = data['studentName']?.toString() ??
                            'Unknown Student';
                        final studentId = data['studentId']?.toString() ?? '';
                        final total = _toInt(data['totalFee']);
                        final paid = _toInt(data['paidAmount']);
                        final pendingAmount = _toInt(data['pendingAmount']);

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
                          amount: "₹${_toInt(data['pendingAmount'])}",
                        );
                      }),
                  ],
                ),
              );
            },
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