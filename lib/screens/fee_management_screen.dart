import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeeManagementScreen extends StatelessWidget {
  const FeeManagementScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: CircularProgressIndicator(),
                          );
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
                            final name =
                                data['name']?.toString() ?? 'No Name';
                            final batch =
                                data['batch']?.toString() ?? 'No Batch';

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

                            final data =
                                selectedDoc.data() as Map<String, dynamic>;

                            setDialogState(() {
                              selectedStudentId = selectedDoc.id;
                              selectedStudentName =
                                  data['name']?.toString() ?? '';
                              selectedBatch =
                                  data['batch']?.toString() ?? '';
                            });
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 10),

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

                    final totalFee =
                        int.tryParse(totalFeeController.text.trim()) ?? 0;
                    final paidAmount =
                        int.tryParse(paidAmountController.text.trim()) ?? 0;
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
      appBar: AppBar(
        title: const Text("Fee Management"),
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

          final fees = snapshot.data?.docs ?? [];

          int totalCollection = 0;
          int totalPending = 0;

          for (final doc in fees) {
            final data = doc.data() as Map<String, dynamic>;
            totalCollection += _toInt(data['paidAmount']);
            totalPending += _toInt(data['pendingAmount']);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _summaryCard(
                  totalCollection: totalCollection,
                  totalPending: totalPending,
                  students: fees.length,
                ),
                const SizedBox(height: 16),

                if (fees.isEmpty)
                  const Card(
                    child: ListTile(
                      title: Text("No fee records found"),
                      subtitle: Text("Click Add Payment to create one"),
                    ),
                  )
                else
                  ...fees.map((doc) {
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
                  }),
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

  Widget _summaryCard({
    required int totalCollection,
    required int totalPending,
    required int students,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: maroon,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Text(
            "This Month Collection",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            "₹$totalCollection",
            style: TextStyle(
              color: gold,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _miniStat("Paid", "₹$totalCollection")),
              Expanded(child: _miniStat("Pending", "₹$totalPending")),
              Expanded(child: _miniStat("Records", students.toString())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                CircleAvatar(
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
                      Text(name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(batch, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                Expanded(child: _amountBox("Total", total)),
                Expanded(child: _amountBox("Paid", paid)),
                Expanded(child: _amountBox("Pending", pending)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _amountBox(String title, String amount) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}