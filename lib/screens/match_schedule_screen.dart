import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchScheduleScreen extends StatelessWidget {
  const MatchScheduleScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

  Future<void> _deleteMatch(BuildContext context, String docId) async {
    await FirebaseFirestore.instance.collection('matches').doc(docId).delete();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Match deleted")),
      );
    }
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Match"),
        content: const Text("Are you sure you want to delete this match?"),
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
              await _deleteMatch(context, docId);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showAddMatchDialog(BuildContext context) {
    final titleController = TextEditingController();
    final opponentController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final venueController = TextEditingController();

    String status = "Upcoming";

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Match"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    _field("Match Title", titleController),
                    _field("Opponent", opponentController),
                    _field("Date", dateController),
                    _field("Time", timeController),
                    _field("Venue", venueController),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(
                        labelText: "Status",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "Upcoming",
                          child: Text("Upcoming"),
                        ),
                        DropdownMenuItem(
                          value: "Completed",
                          child: Text("Completed"),
                        ),
                        DropdownMenuItem(
                          value: "Cancelled",
                          child: Text("Cancelled"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => status = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    titleController.dispose();
                    opponentController.dispose();
                    dateController.dispose();
                    timeController.dispose();
                    venueController.dispose();
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
                    if (titleController.text.trim().isEmpty ||
                        dateController.text.trim().isEmpty ||
                        timeController.text.trim().isEmpty ||
                        venueController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill required fields"),
                        ),
                      );
                      return;
                    }

                    await FirebaseFirestore.instance.collection('matches').add({
                      'title': titleController.text.trim(),
                      'opponent': opponentController.text.trim(),
                      'date': dateController.text.trim(),
                      'time': timeController.text.trim(),
                      'venue': venueController.text.trim(),
                      'status': status,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    titleController.dispose();
                    opponentController.dispose();
                    dateController.dispose();
                    timeController.dispose();
                    venueController.dispose();

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Match added")),
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

  Widget _field(String label, TextEditingController controller) {
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

  Color _statusColor(String status) {
    if (status == "Completed") return Colors.green;
    if (status == "Cancelled") return Colors.red;
    return Colors.orange;
  }

  IconData _statusIcon(String status) {
    if (status == "Completed") return Icons.verified;
    if (status == "Cancelled") return Icons.cancel;
    return Icons.schedule;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('matches')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final matches = snapshot.data?.docs ?? [];

          int upcoming = 0;
          int completed = 0;
          int cancelled = 0;

          for (final doc in matches) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status']?.toString() ?? 'Upcoming';

            if (status == "Completed") {
              completed++;
            } else if (status == "Cancelled") {
              cancelled++;
            } else {
              upcoming++;
            }
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _topHeader(context),
                _heroBanner(
                  total: matches.length,
                  upcoming: upcoming,
                  completed: completed,
                ),
                const SizedBox(height: 18),
                _sectionTitle("MATCH SCHEDULES"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: matches.isEmpty
                      ? _emptyCard()
                      : Column(
                          children: matches.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;

                            final title =
                                data['title']?.toString() ?? 'No Title';
                            final opponent =
                                data['opponent']?.toString() ?? '';
                            final date = data['date']?.toString() ?? '';
                            final time = data['time']?.toString() ?? '';
                            final venue = data['venue']?.toString() ?? '';
                            final status =
                                data['status']?.toString() ?? 'Upcoming';

                            return _matchCard(
                              title: title,
                              opponent: opponent,
                              date: date,
                              time: time,
                              venue: venue,
                              status: status,
                              onDelete: () => _confirmDelete(context, doc.id),
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
        onPressed: () => _showAddMatchDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("Add Match"),
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
              "MATCH SCHEDULE",
              style: TextStyle(
                color: gold,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.sports_cricket, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _heroBanner({
    required int total,
    required int upcoming,
    required int completed,
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
                  child: Icon(Icons.sports_cricket, color: maroon, size: 42),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "YGCA",
                        style: TextStyle(
                          color: gold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "MATCH",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 31,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      Text(
                        "CENTER",
                        style: TextStyle(
                          color: gold,
                          fontSize: 26,
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
                          _heroChip("Upcoming: $upcoming"),
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

  Widget _matchCard({
    required String title,
    required String opponent,
    required String date,
    required String time,
    required String venue,
    required String status,
    required VoidCallback onDelete,
  }) {
    final color = _statusColor(status);
    final icon = _statusIcon(status);

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
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                if (opponent.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    "vs $opponent",
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  "$date • $time",
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  venue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 7),
                _statusChip(status, color),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
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
          Icon(Icons.sports_cricket, size: 38, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No matches scheduled",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text("Click Add Match to create one"),
        ],
      ),
    );
  }
}