import 'package:flutter/material.dart';

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _infoBanner(),

          const SizedBox(height: 14),

          _makeupCard(
            title: "Friday, 6 Jun 2026",
            batch: "Fri Eve Batch",
            reason: "Heavy Rain",
            makeupDate: "Tuesday, 10 Jun 2026",
            status: "Scheduled",
            statusColor: Colors.green,
            icon: Icons.calendar_month,
          ),

          _makeupCard(
            title: "Saturday, 18 May 2026",
            batch: "Sat Morning Batch",
            reason: "Ground Unavailable",
            makeupDate: "Wednesday, 22 May 2026",
            status: "Completed",
            statusColor: Colors.blue,
            icon: Icons.check_circle,
          ),

          _makeupCard(
            title: "Sunday, 8 Jun 2026",
            batch: "Sunday Batch",
            reason: "Coach Unavailable",
            makeupDate: "Not Scheduled",
            status: "Pending",
            statusColor: Colors.orange,
            icon: Icons.pending_actions,
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
                    onPressed: () {},
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text("Edit"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroon,
                      foregroundColor: gold,
                    ),
                    onPressed: () {},
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Schedule Makeup Session"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              TextField(
                decoration: InputDecoration(
                  labelText: "Batch",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: "Reason",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: "Makeup Date",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
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
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Makeup session scheduled")),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}