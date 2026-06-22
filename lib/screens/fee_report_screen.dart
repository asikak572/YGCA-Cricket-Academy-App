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
    if (value is double) return value.round();

    final cleaned = value
        .toString()
        .replaceAll("₹", "")
        .replaceAll(",", "")
        .trim();

    return int.tryParse(cleaned) ?? 0;
  }

  String _text(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  int _amount(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      if (data.containsKey(key) && data[key] != null) {
        return _toInt(data[key]);
      }
    }
    return 0;
  }

  DateTime _createdAt(Map<String, dynamic> data) {
    final value = data['createdAt'];
    if (value is Timestamp) return value.toDate();
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  int _totalFee(Map<String, dynamic> data) {
    return _amount(data, [
      'totalFee',
      'feeAmount',
      'totalAmount',
      'amount',
    ]);
  }

  int _paidAmount(Map<String, dynamic> data) {
    return _amount(data, [
      'paidAmount',
      'amountPaid',
      'paid',
      'collectedAmount',
    ]);
  }

  int _pendingAmount(Map<String, dynamic> data) {
    final total = _totalFee(data);
    final paid = _paidAmount(data);

    final firebasePending = _amount(data, [
      'pendingAmount',
      'balanceAmount',
      'dueAmount',
      'remainingAmount',
    ]);

    if (firebasePending > 0) return firebasePending;

    final calculatedPending = total - paid;
    return calculatedPending < 0 ? 0 : calculatedPending;
  }

  String _studentName(Map<String, dynamic> data) {
    final name = _text(data['studentName']);
    if (name.isNotEmpty) return name;

    final name2 = _text(data['name']);
    if (name2.isNotEmpty) return name2;

    return 'Unknown Student';
  }

  String _studentId(Map<String, dynamic> data) {
    final id = _text(data['studentId']);
    if (id.isNotEmpty) return id;

    final id2 = _text(data['uid']);
    if (id2.isNotEmpty) return id2;

    return '';
  }

  String _paymentStatus(Map<String, dynamic> data) {
    final total = _totalFee(data);
    final paid = _paidAmount(data);
    final pending = _pendingAmount(data);

    final rawStatus = _text(
      data['paymentStatus'] ??
          data['feeStatus'] ??
          data['status'],
    ).toLowerCase();

    if (total > 0 && paid >= total) return 'Paid';
    if (paid > 0 && pending > 0) return 'Partial';
    if (paid == 0 && total > 0) return 'Pending';

    if (rawStatus.contains('paid') && !rawStatus.contains('unpaid')) {
      return 'Paid';
    }

    if (rawStatus.contains('partial')) return 'Partial';
    if (rawStatus.contains('pending')) return 'Pending';
    if (rawStatus.contains('unpaid')) return 'Unpaid';

    return 'Pending';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'unpaid':
        return Colors.red;
      case 'pending':
      default:
        return Colors.deepOrange;
    }
  }

  Future<Map<String, dynamic>> _getUserAccess() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return {
        'role': '',
        'allowedIds': <String>[],
      };
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      return {
        'role': '',
        'allowedIds': <String>[],
      };
    }

    final data = userDoc.data() ?? {};
    final role = _text(data['role']);

    if (role == 'Admin') {
      return {
        'role': role,
        'allowedIds': <String>['ALL'],
      };
    }

    if (role == 'Student') {
      final ids = <String>{user.uid};

      final studentId = _text(data['studentId']);
      if (studentId.isNotEmpty) ids.add(studentId);

      return {
        'role': role,
        'allowedIds': ids.toList(),
      };
    }

    if (role == 'Parent') {
      final ids = <String>{};

      final linkedChildrenIds = data['linkedChildrenIds'];

      if (linkedChildrenIds is List) {
        for (final id in linkedChildrenIds) {
          final value = _text(id);
          if (value.isNotEmpty) ids.add(value);
        }
      }

      final childId = _text(data['childId']);
      if (childId.isNotEmpty) ids.add(childId);

      final studentId = _text(data['studentId']);
      if (studentId.isNotEmpty) ids.add(studentId);

      return {
        'role': role,
        'allowedIds': ids.toList(),
      };
    }

    return {
      'role': role,
      'allowedIds': <String>[],
    };
  }

  Future<List<Map<String, dynamic>>> _getFeeRecords() async {
    final access = await _getUserAccess();
    final allowedIds = List<String>.from(access['allowedIds'] ?? []);

    if (allowedIds.isEmpty) return [];

    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = [];

    if (allowedIds.contains('ALL')) {
      final snapshot = await FirebaseFirestore.instance
          .collection('fees')
          .get();

      docs = snapshot.docs;
    } else {
      for (int i = 0; i < allowedIds.length; i += 10) {
        final end = (i + 10 > allowedIds.length) ? allowedIds.length : i + 10;
        final chunk = allowedIds.sublist(i, end);

        final snapshot = await FirebaseFirestore.instance
            .collection('fees')
            .where('studentId', whereIn: chunk)
            .get();

        docs.addAll(snapshot.docs);
      }
    }

    final records = docs.map((doc) {
      return {
        'docId': doc.id,
        ...doc.data(),
      };
    }).toList();

    records.sort((a, b) => _createdAt(b).compareTo(_createdAt(a)));

    return records;
  }

  Future<void> _generatePdf() async {
    final records = await _getFeeRecords();

    int totalFee = 0;
    int collected = 0;
    int pending = 0;
    int paidRecords = 0;

    for (final data in records) {
      final total = _totalFee(data);
      final paid = _paidAmount(data);
      final pendingAmount = _pendingAmount(data);
      final status = _paymentStatus(data);

      totalFee += total;
      collected += paid;
      pending += pendingAmount;

      if (status == 'Paid') {
        paidRecords++;
      }
    }

    await PdfService.generateFeeReportPdf(
      totalFee: totalFee,
      collected: collected,
      pending: pending,
      paidStudents: paidRecords,
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getFeeRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          final feeRecords = snapshot.data ?? [];

          int totalFee = 0;
          int collected = 0;
          int pending = 0;
          int paidRecords = 0;
          int partialRecords = 0;
          int pendingRecords = 0;

          for (final data in feeRecords) {
            final total = _totalFee(data);
            final paid = _paidAmount(data);
            final pendingAmount = _pendingAmount(data);
            final status = _paymentStatus(data);

            totalFee += total;
            collected += paid;
            pending += pendingAmount;

            if (status == 'Paid') {
              paidRecords++;
            } else if (status == 'Partial') {
              partialRecords++;
            } else {
              pendingRecords++;
            }
          }

          final collectionPercent =
              totalFee == 0 ? 0 : ((collected / totalFee) * 100).round();

          final pendingFeeRecords = feeRecords.where((data) {
            final status = _paymentStatus(data);
            final pendingAmount = _pendingAmount(data);

            return status != 'Paid' || pendingAmount > 0;
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
                      paidRecords.toString(),
                      Icons.verified,
                      Colors.blue,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _smallStatusCard(
                        title: "Partial",
                        value: partialRecords.toString(),
                        color: Colors.orange,
                        icon: Icons.timelapse,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _smallStatusCard(
                        title: "Pending",
                        value: pendingRecords.toString(),
                        color: Colors.red,
                        icon: Icons.pending_actions,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _sectionTitle("Payment Records"),

                if (feeRecords.isEmpty)
                  const Card(
                    child: ListTile(
                      title: Text("No fee records found"),
                      subtitle: Text("No fee record available for this user"),
                    ),
                  )
                else
                  ...feeRecords.map((data) {
                    final name = _studentName(data);
                    final studentId = _studentId(data);
                    final total = _totalFee(data);
                    final paid = _paidAmount(data);
                    final pendingAmount = _pendingAmount(data);
                    final status = _paymentStatus(data);
                    final color = _statusColor(status);

                    final progress =
                        total == 0 ? 0.0 : (paid / total).clamp(0.0, 1.0);

                    return _collectionTile(
                      title: name,
                      subtitle: studentId.isEmpty ? "Student ID not found" : "ID: $studentId",
                      status: status,
                      amount: "₹$paid / ₹$total",
                      progress: progress,
                      pending: status == 'Paid'
                          ? "Fully Paid"
                          : "Pending ₹$pendingAmount",
                      statusColor: color,
                    );
                  }),

                const SizedBox(height: 18),

                _sectionTitle("Pending Fee Records"),

                if (pendingFeeRecords.isEmpty)
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text("No pending fees"),
                      subtitle: Text("All fee records are completed"),
                    ),
                  )
                else
                  ...pendingFeeRecords.map((data) {
                    final status = _paymentStatus(data);
                    final color = _statusColor(status);

                    return _pendingStudentCard(
                      name: _studentName(data),
                      batch: _studentId(data).isEmpty
                          ? "Student ID not found"
                          : "ID: ${_studentId(data)}",
                      amount: "₹${_pendingAmount(data)}",
                      status: status,
                      color: color,
                    );
                  }),

                const SizedBox(height: 18),
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
            value: (collectionPercent / 100).clamp(0.0, 1.0),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

  Widget _smallStatusCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.w900,
            ),
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
    required String status,
    required String amount,
    required double progress,
    required String pending,
    required Color statusColor,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
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

            Row(
              children: [
                Expanded(
                  child: Text(
                    amount,
                    style: TextStyle(
                      color: maroon,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  pending,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE2E8F0),
              color: statusColor,
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
    required String status,
    required Color color,
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
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("$batch\n$status"),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}