import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchScheduleScreen extends StatelessWidget {
  const MatchScheduleScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Match Schedule"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
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

          if (matches.isEmpty) {
            return const Center(child: Text("No matches scheduled"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final doc = matches[index];
              final data = doc.data() as Map<String, dynamic>;

              final title = data['title']?.toString() ?? 'No Title';
              final opponent = data['opponent']?.toString() ?? '';
              final date = data['date']?.toString() ?? '';
              final time = data['time']?.toString() ?? '';
              final venue = data['venue']?.toString() ?? '';
              final status = data['status']?.toString() ?? 'Upcoming';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: maroon,
                        child: Icon(Icons.sports_cricket, color: gold),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (opponent.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text("Opponent: $opponent"),
                            ],
                            const SizedBox(height: 4),
                            Text("$date • $time"),
                            Text(
                              venue,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              status,
                              style: TextStyle(
                                color: _statusColor(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
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
}