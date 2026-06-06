import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingScheduleScreen extends StatelessWidget {
  const TrainingScheduleScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Training Schedule"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('training_schedules')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final schedules = snapshot.data?.docs ?? [];

          if (schedules.isEmpty) {
            return const Center(child: Text("No training schedule found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final data = schedules[index].data() as Map<String, dynamic>;

              final day = data['day']?.toString() ?? '';
              final time = data['time']?.toString() ?? '';
              final batch = data['batch']?.toString() ?? '';
              final type = data['type']?.toString() ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: maroon,
                    child: Icon(Icons.calendar_month, color: gold),
                  ),
                  title: Text(
                    day,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("$time\n$batch • $type"),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
          _showAddTrainingDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Training"),
      ),
    );
  }

  void _showAddTrainingDialog(BuildContext context) {
    final dayController = TextEditingController();
    final timeController = TextEditingController();
    final batchController = TextEditingController();
    final typeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Training"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _input("Day", dayController),
              _input("Time", timeController),
              _input("Batch", batchController),
              _input("Training Type", typeController),
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
                  .collection('training_schedules')
                  .add({
                'day': dayController.text.trim(),
                'time': timeController.text.trim(),
                'batch': batchController.text.trim(),
                'type': typeController.text.trim(),
                'createdAt': FieldValue.serverTimestamp(),
              });

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Training schedule added")),
                );
              }
            },
            child: const Text("Save"),
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
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}