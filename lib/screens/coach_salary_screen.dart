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
                      DropdownMenuItem(value: "Pending", child: Text("Pending")),
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

          for (final doc in salaryDocs) {
            final data = doc.data() as Map<String, dynamic>;
            totalBudget += (data['salary'] ?? 0) as int;
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
                          final data = salaryDocs[index].data()
                              as Map<String, dynamic>;

                          final name =
                              data['coachName']?.toString() ?? 'Unknown Coach';
                          final role =
                              data['role']?.toString() ?? 'No Role';
                          final salary =
                              (data['salary'] ?? 0).toString();
                          final status =
                              data['status']?.toString() ?? 'Pending';

                          final isPaid = status == "Paid";

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
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
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(role),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
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
}