import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class FeeManagementScreen extends StatelessWidget {
  const FeeManagementScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

  Future<void> _addPaymentDialog(BuildContext context) async {
    String? selectedStudentId;
    String selectedStudentName = '';
    String selectedBatch = '';

    final totalFeeController = TextEditingController();
    final paidAmountController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Fee Payment"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('students')
                          .orderBy('name')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text("No students found");
                        }

                        final students = snapshot.data!.docs;

                        return DropdownButtonFormField<String>(
                          value: selectedStudentId,
                          decoration: const InputDecoration(
                            labelText: "Select Student",
                            border: OutlineInputBorder(),
                          ),
                          items: students.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final name = data['name']?.toString() ?? 'No Name';
                            final batch = data['batch']?.toString() ?? 'No Batch';

                            return DropdownMenuItem(
                              value: doc.id,
                              child: Text("$name - $batch"),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;

                            final selectedDoc = students.firstWhere(
                              (doc) => doc.id == value,
                            );

                            final data = selectedDoc.data() as Map<String, dynamic>;

                            setDialogState(() {
                              selectedStudentId = selectedDoc.id;
                              selectedStudentName = data['name']?.toString() ?? '';
                              selectedBatch = data['batch']?.toString() ?? '';
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _dialogField(
                      "Total Fee",
                      totalFeeController,
                      keyboardType: TextInputType.number,
                    ),
                    _dialogField(
                      "Paid Amount",
                      paidAmountController,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroon,
                    foregroundColor: gold,
                  ),
                  onPressed: () async {
                    if (selectedStudentId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select a student")),
                      );
                      return;
                    }

                    final totalFee = int.tryParse(totalFeeController.text.trim()) ?? 0;
                    final paidAmount = int.tryParse(paidAmountController.text.trim()) ?? 0;
                    final pending = totalFee - paidAmount;
                    final status = pending <= 0 ? 'Paid' : 'Pending';

                    await FirebaseFirestore.instance.collection('fees').add({
                      'studentId': selectedStudentId,
                      'studentName': selectedStudentName,
                      'batch': selectedBatch,
                      'totalFee': totalFee,
                      'paidAmount': paidAmount,
                      'pendingAmount': pending < 0 ? 0 : pending,
                      'status': status,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    await FirebaseFirestore.instance
                        .collection('students')
                        .doc(selectedStudentId)
                        .update({
                      'totalFee': totalFee,
                      'paidAmount': paidAmount,
                      'pendingAmount': pending < 0 ? 0 : pending,
                      'feeStatus': status,
                      'lastFeeUpdatedAt': FieldValue.serverTimestamp(),
                    });
                    if (pending > 0) {
  await NotificationService.feeReminder(
    studentName: selectedStudentName,
    studentId: selectedStudentId!,
    pendingAmount: pending,
  );
}

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Fee payment saved")),
                      );
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _dialogField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
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

          final fees = snapshot.data?.docs ?? [];

          int totalCollection = 0;
          int totalPending = 0;

          for (final doc in fees) {
            final data = doc.data() as Map<String, dynamic>;
            totalCollection += _toInt(data['paidAmount']);
            totalPending += _toInt(data['pendingAmount']);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _topHeader(context),
                _heroCard(
                  totalCollection: totalCollection,
                  totalPending: totalPending,
                  records: fees.length,
                ),
                const SizedBox(height: 18),
                _sectionTitle("FEE RECORDS"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: fees.isEmpty
                      ? _emptyCard()
                      : Column(
                          children: fees.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;

                            final name =
                                data['studentName']?.toString() ?? 'Unknown Student';
                            final batch = data['batch']?.toString() ?? '';
                            final total = _toInt(data['totalFee']);
                            final paid = _toInt(data['paidAmount']);
                            final pending = _toInt(data['pendingAmount']);
                            final status = data['status']?.toString() ?? 'Pending';

                            return _feeTile(
                              name: name,
                              batch: batch,
                              total: "₹$total",
                              paid: "₹$paid",
                              pending: "₹$pending",
                              status: status,
                              statusColor:
                                  status == "Paid" ? Colors.green : Colors.orange,
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
        onPressed: () => _addPaymentDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("Add Payment"),
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
              "FEE MANAGEMENT",
              style: TextStyle(
                color: gold,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.payments, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _heroCard({
    required int totalCollection,
    required int totalPending,
    required int records,
  }) {
    return Container(
      height: 240,
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
                  child: Icon(Icons.currency_rupee, color: maroon, size: 42),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "THIS MONTH",
                        style: TextStyle(
                          color: gold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "₹$totalCollection",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        "Total Collection",
                        style: TextStyle(
                          color: gold,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _heroChip("Pending: ₹$totalPending"),
                          _heroChip("Records: $records"),
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
          Icon(Icons.receipt_long, size: 38, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No fee records found",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text("Click Add Payment to create one"),
        ],
      ),
    );
  }

  Widget _feeTile({
    required String name,
    required String batch,
    required String total,
    required String paid,
    required String pending,
    required String status,
    required Color statusColor,
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
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: maroon,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                  style: TextStyle(color: gold, fontWeight: FontWeight.bold),
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
                    Text(
                      batch,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _amountBox("Total", total, Colors.blue)),
              Expanded(child: _amountBox("Paid", paid, Colors.green)),
              Expanded(child: _amountBox("Pending", pending, Colors.orange)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amountBox(String title, String amount, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}