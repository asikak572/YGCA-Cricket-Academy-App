import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'coach_details_screen.dart';

class CoachManagementScreen extends StatelessWidget {
  const CoachManagementScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  Future<void> _addCoachDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final phoneController = TextEditingController();
    final batchController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Coach"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _field("Coach Name", nameController),
              _field("Role", roleController),
              _field(
                "Phone",
                phoneController,
                keyboardType: TextInputType.phone,
              ),
              _field("Assigned Batch", batchController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              nameController.dispose();
              roleController.dispose();
              phoneController.dispose();
              batchController.dispose();
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: maroon,
              foregroundColor: gold,
            ),
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  roleController.text.trim().isEmpty ||
                  phoneController.text.trim().isEmpty ||
                  batchController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all fields")),
                );
                return;
              }

              await FirebaseFirestore.instance.collection('coaches').add({
                'name': nameController.text.trim(),
                'role': roleController.text.trim(),
                'phone': phoneController.text.trim(),
                'batch': batchController.text.trim(),
                'status': 'Active',
                'createdAt': FieldValue.serverTimestamp(),
              });

              nameController.dispose();
              roleController.dispose();
              phoneController.dispose();
              batchController.dispose();

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Coach added successfully")),
                );
              }
            },
            child: const Text("Save"),
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

  Future<void> _deleteCoach(BuildContext context, String coachId) async {
    await FirebaseFirestore.instance.collection('coaches').doc(coachId).delete();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Coach deleted")),
      );
    }
  }

  void _confirmDelete(BuildContext context, String coachId, String coachName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Coach"),
        content: Text("Are you sure you want to delete $coachName?"),
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
              await _deleteCoach(context, coachId);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _openCoachDetails({
    required BuildContext context,
    required String coachId,
    required String name,
    required String role,
    required String phone,
    required String batch,
    required String status,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoachDetailsScreen(
          coachId: coachId,
          name: name,
          role: role,
          phone: phone,
          batch: batch,
          status: status,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Coach Management"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('coaches')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final coaches = snapshot.data?.docs ?? [];

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: maroon,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      "Total Coaches",
                      style: TextStyle(color: gold, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      coaches.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: coaches.isEmpty
                    ? const Center(
                        child: Text("No coaches found. Click Add Coach."),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: coaches.length,
                        itemBuilder: (context, index) {
                          final doc = coaches[index];
                          final data = doc.data() as Map<String, dynamic>;

                          final name =
                              data['name']?.toString() ?? 'No Name';
                          final role =
                              data['role']?.toString() ?? 'No Role';
                          final phone =
                              data['phone']?.toString() ?? 'No Phone';
                          final batch =
                              data['batch']?.toString() ?? 'No Batch';
                          final status =
                              data['status']?.toString() ?? 'Active';

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: border),
                            ),
                            child: ListTile(
                              onTap: () {
                                _openCoachDetails(
                                  context: context,
                                  coachId: doc.id,
                                  name: name,
                                  role: role,
                                  phone: phone,
                                  batch: batch,
                                  status: status,
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: maroon,
                                child: Icon(Icons.sports, color: gold),
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text("$role\n$batch • $phone"),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey.shade500,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        _confirmDelete(context, doc.id, name),
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
        onPressed: () => _addCoachDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("Add Coach"),
      ),
    );
  }
}