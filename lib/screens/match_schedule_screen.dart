import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchScheduleScreen extends StatelessWidget {
  const MatchScheduleScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);

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
            return const Center(
              child: Text("Something went wrong"),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final matches = snapshot.data!.docs;

          if (matches.isEmpty) {
            return const Center(
              child: Text("No matches scheduled"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final data =
                  matches[index].data() as Map<String, dynamic>;

              final title =
                  data['title']?.toString() ?? '';

              final date =
                  data['date']?.toString() ?? '';

              final time =
                  data['time']?.toString() ?? '';

              final venue =
                  data['venue']?.toString() ?? '';

              final status =
                  data['status']?.toString() ?? 'Upcoming';

              final isUpcoming =
                  status == "Upcoming";

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: maroon,
                    child: Icon(
                      Icons.sports_cricket,
                      color: gold,
                    ),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "$date • $time\n$venue",
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    status,
                    style: TextStyle(
                      color: isUpcoming
                          ? Colors.orange
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
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
        onPressed: () {
          _showAddMatchDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Match"),
      ),
    );
  }

  void _showAddMatchDialog(BuildContext context) {
    final titleController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final venueController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Match"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Match Title",
                ),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: "Date",
                ),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: "Time",
                ),
              ),
              TextField(
                controller: venueController,
                decoration: const InputDecoration(
                  labelText: "Venue",
                ),
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
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('matches')
                  .add({
                'title': titleController.text,
                'date': dateController.text,
                'time': timeController.text,
                'venue': venueController.text,
                'status': 'Upcoming',
                'createdAt':
                    FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}