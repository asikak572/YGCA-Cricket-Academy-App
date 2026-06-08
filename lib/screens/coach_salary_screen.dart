import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoachSalaryScreen extends StatelessWidget {
  const CoachSalaryScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);

  Future<void> _addSalaryDialog(BuildContext context) async {
    final coachNameController = TextEditingController();
    final roleController = TextEditingController();
    final salaryController = TextEditingController();

    String status = "Pending";

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Add Coach Salary"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _field("Coach Name", coachNameController),
                  _field("Role", roleController),
                  _field(
                    "Salary Amount",
                    salaryController,
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: const InputDecoration(
                      labelText: "Status",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "Paid", child: Text("Paid")),
                      DropdownMenuItem(
                        value: "Pending",
                        child: Text("Pending"),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        status = value;
                      });
                    },
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
                  if (coachNameController.text.trim().isEmpty ||
                      roleController.text.trim().isEmpty ||
                      salaryController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all fields")),
                    );
                    return;
                  }

                  final salary =
                      int.tryParse(salaryController.text.trim()) ?? 0;

                  await FirebaseFirestore.instance
                      .collection('coach_salaries')
                      .add({
                    'coachName': coachNameController.text.trim(),
                    'role': roleController.text.trim(),
                    'salary': salary,
                    'status': status,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Coach salary saved")),
                    );
                  }
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateSalaryStatus(
    BuildContext context,
    String docId,
    String status,
  ) async {
    await FirebaseFirestore.instance
        .collection('coach_salaries')
        .doc(docId)
        .update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Salary marked as $status")),
      );
    }
  }

  Future<void> _deleteSalary(BuildContext context, String docId) async {
    await FirebaseFirestore.instance
        .collection('coach_salaries')
        .doc(docId)
        .delete();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Salary record deleted")),
      );
    }
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Salary Record"),
        content: const Text("Are you sure you want to delete this salary record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _deleteSalary(context, docId);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  static Widget _field(
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
      appBar: AppBar(
        title: const Text("Coach Salary"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('coach_salaries')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final salaryDocs = snapshot.data?.docs ?? [];

          int totalBudget = 0;
          int paidBudget = 0;
          int pendingBudget = 0;

          for (final doc in salaryDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final salary = _toInt(data['salary']);
            final status = data['status']?.toString() ?? 'Pending';

            totalBudget += salary;

            if (status == "Paid") {
              paidBudget += salary;
            } else {
              pendingBudget += salary;
            }
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
                      "Monthly Salary Budget",
                      style: TextStyle(color: gold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "₹$totalBudget",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _miniStat("Paid", "₹$paidBudget")),
                        Expanded(
                          child: _miniStat("Pending", "₹$pendingBudget"),
                        ),
                        Expanded(
                          child: _miniStat(
                            "Records",
                            salaryDocs.length.toString(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: salaryDocs.isEmpty
                    ? const Center(
                        child: Text("No coach salary records found"),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: salaryDocs.length,
                        itemBuilder: (context, index) {
                          final doc = salaryDocs[index];
                          final data = doc.data() as Map<String, dynamic>;

                          final name =
                              data['coachName']?.toString() ?? 'Unknown Coach';
                          final role = data['role']?.toString() ?? 'No Role';
                          final salary = _toInt(data['salary']);
                          final status =
                              data['status']?.toString() ?? 'Pending';

                          final isPaid = status == "Paid";

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: maroon,
                                    child: Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : "?",
                                      style: TextStyle(
                                        color: gold,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          role,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "₹$salary",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        status,
                                        style: TextStyle(
                                          color: isPaid
                                              ? Colors.green
                                              : Colors.orange,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == "Paid" ||
                                          value == "Pending") {
                                        await _updateSalaryStatus(
                                          context,
                                          doc.id,
                                          value,
                                        );
                                      }

                                      if (value == "Delete") {
                                        _confirmDelete(context, doc.id);
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(
                                        value: "Paid",
                                        child: Text("Mark Paid"),
                                      ),
                                      PopupMenuItem(
                                        value: "Pending",
                                        child: Text("Mark Pending"),
                                      ),
                                      PopupMenuItem(
                                        value: "Delete",
                                        child: Text("Delete"),
                                      ),
                                    ],
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: maroon,
        foregroundColor: gold,
        onPressed: () => _addSalaryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("Add Salary"),
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
}