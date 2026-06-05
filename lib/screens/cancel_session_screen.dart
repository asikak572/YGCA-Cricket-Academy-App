import 'package:flutter/material.dart';

class CancelSessionScreen extends StatelessWidget {
  const CancelSessionScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
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

            _inputBox("Select Batch", "Morning Batch"),
            _inputBox("Session Date", "12 Jun 2026"),
            _inputBox("Session Time", "7:00 AM - 9:00 AM"),
            _inputBox("Reason", "Heavy Rain / Ground Unavailable"),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroon,
                  foregroundColor: gold,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Session cancelled and parents notified"),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_active),
                label: const Text("Cancel & Notify Parents"),
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle("Recently Cancelled Sessions"),

            _cancelledCard(
              batch: "Fri Eve Batch",
              date: "6 Jun 2026",
              reason: "Heavy Rain",
              makeup: "Makeup scheduled: 10 Jun 2026",
            ),

            _cancelledCard(
              batch: "Sat Morning Batch",
              date: "18 May 2026",
              reason: "Ground Unavailable",
              makeup: "Makeup completed: 22 May 2026",
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

  Widget _inputBox(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: TextEditingController(text: value),
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
        subtitle: Text("$date • $reason\n$makeup"),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios, size: 15),
      ),
    );
  }
}