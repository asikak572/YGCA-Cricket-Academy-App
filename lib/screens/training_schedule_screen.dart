import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingScheduleScreen extends StatelessWidget {
  const TrainingScheduleScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);

  Future<void> _deleteTraining(BuildContext context, String docId) async {
    await FirebaseFirestore.instance
        .collection('training_schedules')
        .doc(docId)
        .delete();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Training schedule deleted")),
      );
    }
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
              if (dayController.text.trim().isEmpty ||
                  timeController.text.trim().isEmpty ||
                  batchController.text.trim().isEmpty ||
                  typeController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all fields")),
                );
                return;
              }

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

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Training"),
        content: const Text("Are you sure you want to delete this training schedule?"),
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
              await _deleteTraining(context, docId);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

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
              final doc = schedules[index];
              final data = doc.data() as Map<String, dynamic>;

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
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, doc.id),
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
        onPressed: () => _showAddTrainingDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("Add Training"),
      ),
    );
  }
}