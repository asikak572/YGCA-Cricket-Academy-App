import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MakeupSessionScreen extends StatelessWidget {
  const MakeupSessionScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

  Future<void> _scheduleMakeup(
    BuildContext context,
    String docId,
    String cancelledSessionId,
  ) async {
    final dateController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Schedule Makeup Session"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _input("Makeup Date", dateController),
            _input("Makeup Time", timeController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              dateController.dispose();
              timeController.dispose();
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
              final date = dateController.text.trim();
              final time = timeController.text.trim();

              if (date.isEmpty || time.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill date and time")),
                );
                return;
              }

              await FirebaseFirestore.instance
                  .collection('makeup_sessions')
                  .doc(docId)
                  .update({
                'makeupDate': date,
                'makeupTime': time,
                'status': 'Scheduled',
                'updatedAt': FieldValue.serverTimestamp(),
              });

              if (cancelledSessionId.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('cancelled_sessions')
                    .doc(cancelledSessionId)
                    .update({
                  'makeup': "$date • $time",
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              }

              await FirebaseFirestore.instance.collection('notifications').add({
                'title': 'Makeup Session Scheduled',
                'message': 'Makeup session scheduled on $date at $time',
                'targetRole': 'All',
                'createdAt': FieldValue.serverTimestamp(),
              });

              dateController.dispose();
              timeController.dispose();

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
      ),
    );
  }

  Future<void> _markCompleted(BuildContext context, String docId) async {
    await FirebaseFirestore.instance
        .collection('makeup_sessions')
        .doc(docId)
        .update({
      'status': 'Completed',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Makeup session marked as completed")),
      );
    }
  }

  Future<void> _deleteSession(BuildContext context, String docId) async {
    await FirebaseFirestore.instance
        .collection('makeup_sessions')
        .doc(docId)
        .delete();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Makeup session deleted")),
      );
    }
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Makeup Session"),
        content: const Text("Are you sure you want to delete this session?"),
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
              await _deleteSession(context, docId);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ).copyWith(labelText: label),
      ),
    );
  }

  Color _statusColor(String status) {
    if (status == "Completed") return Colors.blue;
    if (status == "Pending") return Colors.orange;
    return Colors.green;
  }

  IconData _statusIcon(String status) {
    if (status == "Completed") return Icons.check_circle;
    if (status == "Pending") return Icons.pending_actions;
    return Icons.calendar_month;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: StreamBuilder<QuerySnapshot>(
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

          int scheduled = 0;
          int completed = 0;
          int pending = 0;

          for (final doc in sessions) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status']?.toString() ?? 'Pending';

            if (status == "Completed") {
              completed++;
            } else if (status == "Pending") {
              pending++;
            } else {
              scheduled++;
            }
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _topHeader(context),
                _heroBanner(
                  total: sessions.length,
                  scheduled: scheduled,
                  completed: completed,
                  pending: pending,
                ),
                const SizedBox(height: 18),
                _sectionTitle("MAKEUP OVERVIEW"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.25,
                    children: [
                      _statCard(Icons.event_repeat, "TOTAL",
                          sessions.length.toString(), "Sessions", Colors.blue),
                      _statCard(Icons.calendar_month, "SCHEDULED",
                          scheduled.toString(), "Planned", Colors.green),
                      _statCard(Icons.pending_actions, "PENDING",
                          pending.toString(), "Waiting", Colors.orange),
                      _statCard(Icons.check_circle, "COMPLETED",
                          completed.toString(), "Done", Colors.purple),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _infoBanner(),
                ),
                const SizedBox(height: 18),
                _sectionTitle("MAKEUP SESSION LIST"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: sessions.isEmpty
                      ? _emptyCard()
                      : Column(
                          children: sessions.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;

                            final batch = data['batch']?.toString() ?? '';
                            final cancelledDate =
                                data['cancelledDate']?.toString() ?? '';
                            final cancelledTime =
                                data['cancelledTime']?.toString() ?? '';
                            final reason = data['reason']?.toString() ?? '';
                            final makeupDate =
                                data['makeupDate']?.toString() ?? '';
                            final makeupTime =
                                data['makeupTime']?.toString() ?? '';
                            final status =
                                data['status']?.toString() ?? 'Pending';
                            final cancelledSessionId =
                                data['cancelledSessionId']?.toString() ?? '';

                            return _makeupCard(
                              context: context,
                              docId: doc.id,
                              cancelledSessionId: cancelledSessionId,
                              batch: batch,
                              cancelledDate: cancelledDate,
                              cancelledTime: cancelledTime,
                              reason: reason,
                              makeupDate: makeupDate,
                              makeupTime: makeupTime,
                              status: status,
                              statusColor: _statusColor(status),
                              icon: _statusIcon(status),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
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
          Image.asset('assets/images/ygca_logo.jpg', width: 58),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "MAKEUP SESSIONS",
              style: TextStyle(
                color: gold,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.event_repeat, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _heroBanner({
    required int total,
    required int scheduled,
    required int completed,
    required int pending,
  }) {
    return Container(
      height: 230,
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
                  child: Icon(Icons.event_repeat, color: maroon, size: 42),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ACADEMY",
                        style: TextStyle(
                          color: gold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "MAKEUP",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 31,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      Text(
                        "SESSIONS",
                        style: TextStyle(
                          color: gold,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _heroChip("Total: $total"),
                          _heroChip("Scheduled: $scheduled"),
                          _heroChip("Pending: $pending"),
                          _heroChip("Completed: $completed"),
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

  Widget _statCard(
    IconData icon,
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
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
              "Makeup sessions are automatically created when a training session is cancelled. Schedule a makeup date and notify parents/students.",
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
    required String cancelledSessionId,
    required String batch,
    required String cancelledDate,
    required String cancelledTime,
    required String reason,
    required String makeupDate,
    required String makeupTime,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    final isPending = status == "Pending";
    final makeupText = makeupDate.isEmpty
        ? "Not scheduled"
        : makeupTime.isEmpty
            ? makeupDate
            : "$makeupDate • $makeupTime";

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
                radius: 26,
                backgroundColor: maroon,
                child: Icon(icon, color: gold, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  batch.isEmpty ? "Unknown Batch" : batch,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              _statusChip(status, statusColor),
            ],
          ),
          const SizedBox(height: 14),
          _detailRow("Cancelled Date", cancelledDate),
          _detailRow("Cancelled Time", cancelledTime),
          _detailRow("Reason", reason),
          _detailRow("Makeup Date", makeupText),
          const SizedBox(height: 12),
          Row(
            children: [
              if (isPending)
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroon,
                      foregroundColor: gold,
                    ),
                    onPressed: () => _scheduleMakeup(
                      context,
                      docId,
                      cancelledSessionId,
                    ),
                    icon: const Icon(Icons.calendar_month, size: 16),
                    label: const Text("Schedule"),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _markCompleted(context, docId),
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text("Complete"),
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context, docId),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value.isEmpty ? "Not added" : value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_repeat, size: 40, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No Makeup Sessions Found",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text("Cancel a session to automatically create makeup session"),
        ],
      ),
    );
  }
}