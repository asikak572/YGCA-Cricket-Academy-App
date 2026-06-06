import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CancelSessionScreen extends StatelessWidget {
  const CancelSessionScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final batchController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final reasonController = TextEditingController();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Cancel Session"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _warningBox(),
            const SizedBox(height: 16),

            _inputBox("Select Batch", batchController),
            _inputBox("Session Date", dateController),
            _inputBox("Session Time", timeController),
            _inputBox("Reason", reasonController),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroon,
                  foregroundColor: gold,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('cancelled_sessions')
                      .add({
                    'batch': batchController.text.trim(),
                    'date': dateController.text.trim(),
                    'time': timeController.text.trim(),
                    'reason': reasonController.text.trim(),
                    'makeup': 'Not scheduled',
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  await FirebaseFirestore.instance
                      .collection('notifications')
                      .add({
                    'title': 'Session Cancelled',
                    'message':
                        '${batchController.text.trim()} session on ${dateController.text.trim()} has been cancelled. Reason: ${reasonController.text.trim()}',
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Session cancelled and parents notified"),
                      ),
                    );

                    batchController.clear();
                    dateController.clear();
                    timeController.clear();
                    reasonController.clear();
                  }
                },
                icon: const Icon(Icons.notifications_active),
                label: const Text("Cancel & Notify Parents"),
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle("Recently Cancelled Sessions"),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cancelled_sessions')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text("Something went wrong");
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  );
                }

                final sessions = snapshot.data?.docs ?? [];

                if (sessions.isEmpty) {
                  return const Card(
                    child: ListTile(
                      title: Text("No cancelled sessions found"),
                    ),
                  );
                }

                return Column(
                  children: sessions.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return _cancelledCard(
                      batch: data['batch']?.toString() ?? '',
                      date: data['date']?.toString() ?? '',
                      reason: data['reason']?.toString() ?? '',
                      makeup: data['makeup']?.toString() ?? 'Not scheduled',
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _warningBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        border: Border.all(color: const Color(0xFFFECACA)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Cancel a training session only when required. Parents and students should be notified immediately. A makeup session can be scheduled after cancellation.",
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBox(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: border),
          ),
        ),
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  Widget _cancelledCard({
    required String batch,
    required String date,
    required String reason,
    required String makeup,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFEF2F2),
          child: Icon(Icons.event_busy, color: Colors.red.shade700),
        ),
        title: Text(batch, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$date • $reason\nMakeup: $makeup"),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios, size: 15),
      ),
    );
  }
}