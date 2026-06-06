import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MakeupSessionScreen extends StatelessWidget {
  const MakeupSessionScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Makeup Sessions"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _infoBanner(),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('makeup_sessions')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final sessions = snapshot.data?.docs ?? [];

                if (sessions.isEmpty) {
                  return const Center(child: Text("No makeup sessions found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final data = sessions[index].data() as Map<String, dynamic>;

                    final title = data['title']?.toString() ?? '';
                    final batch = data['batch']?.toString() ?? '';
                    final reason = data['reason']?.toString() ?? '';
                    final makeupDate = data['makeupDate']?.toString() ?? '';
                    final status = data['status']?.toString() ?? 'Scheduled';

                    Color statusColor = Colors.green;
                    IconData icon = Icons.calendar_month;

                    if (status == "Completed") {
                      statusColor = Colors.blue;
                      icon = Icons.check_circle;
                    } else if (status == "Pending") {
                      statusColor = Colors.orange;
                      icon = Icons.pending_actions;
                    }

                    return _makeupCard(
                      context: context,
                      docId: sessions[index].id,
                      title: title,
                      batch: batch,
                      reason: reason,
                      makeupDate: makeupDate,
                      status: status,
                      statusColor: statusColor,
                      icon: icon,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: maroon,
        foregroundColor: gold,
        onPressed: () {
          _showScheduleDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text("Schedule Makeup"),
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Makeup sessions are used when a regular training session is cancelled or missed. Parents and students should be notified after scheduling.",
              style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _makeupCard({
    required BuildContext context,
    required String docId,
    required String title,
    required String batch,
    required String reason,
    required String makeupDate,
    required String status,
    required Color statusColor,
    required IconData icon,
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
                  child: Icon(icon, color: gold, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(batch, style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _row("Cancel / Missed Reason", reason),
            _row("Makeup Date", makeupDate),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showStatusDialog(context, docId);
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text("Update"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroon,
                      foregroundColor: gold,
                    ),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('notifications')
                          .add({
                        'title': 'Makeup Session',
                        'message': '$batch makeup session scheduled on $makeupDate',
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Notification added")),
                        );
                      }
                    },
                    icon: const Icon(Icons.notifications_active, size: 16),
                    label: const Text("Notify"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Update Status"),
        actions: [
          TextButton(
            onPressed: () async {
              await _updateStatus(docId, "Pending");
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Pending"),
          ),
          TextButton(
            onPressed: () async {
              await _updateStatus(docId, "Scheduled");
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Scheduled"),
          ),
          TextButton(
            onPressed: () async {
              await _updateStatus(docId, "Completed");
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Completed"),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String docId, String status) async {
    await FirebaseFirestore.instance
        .collection('makeup_sessions')
        .doc(docId)
        .update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog(BuildContext context) {
    final titleController = TextEditingController();
    final batchController = TextEditingController();
    final reasonController = TextEditingController();
    final makeupDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Schedule Makeup Session"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _input("Missed Session Date / Title", titleController),
                _input("Batch", batchController),
                _input("Reason", reasonController),
                _input("Makeup Date", makeupDateController),
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
                await FirebaseFirestore.instance
                    .collection('makeup_sessions')
                    .add({
                  'title': titleController.text.trim(),
                  'batch': batchController.text.trim(),
                  'reason': reasonController.text.trim(),
                  'makeupDate': makeupDateController.text.trim(),
                  'status': 'Scheduled',
                  'createdAt': FieldValue.serverTimestamp(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Makeup session scheduled")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}