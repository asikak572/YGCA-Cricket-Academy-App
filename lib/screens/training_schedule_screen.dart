import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingScheduleScreen extends StatelessWidget {
  const TrainingScheduleScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

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
            onPressed: () {
              dayController.dispose();
              timeController.dispose();
              batchController.dispose();
              typeController.dispose();
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

              dayController.dispose();
              timeController.dispose();
              batchController.dispose();
              typeController.dispose();

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
        content: const Text(
          "Are you sure you want to delete this training schedule?",
        ),
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

  IconData _typeIcon(String type) {
    final lower = type.toLowerCase();

    if (lower.contains("fitness")) return Icons.fitness_center;
    if (lower.contains("bat")) return Icons.sports_cricket;
    if (lower.contains("bowl")) return Icons.sports_baseball;
    if (lower.contains("field")) return Icons.sports_handball;

    return Icons.calendar_month;
  }

  Color _typeColor(String type) {
    final lower = type.toLowerCase();

    if (lower.contains("fitness")) return Colors.green;
    if (lower.contains("bat")) return Colors.orange;
    if (lower.contains("bowl")) return Colors.blue;
    if (lower.contains("field")) return Colors.purple;

    return Colors.teal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
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

          return SingleChildScrollView(
            child: Column(
              children: [
                _topHeader(context),
                _heroBanner(total: schedules.length),
                const SizedBox(height: 18),
                _sectionTitle("TRAINING SCHEDULES"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: schedules.isEmpty
                      ? _emptyCard()
                      : Column(
                          children: schedules.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;

                            final day = data['day']?.toString() ?? '';
                            final time = data['time']?.toString() ?? '';
                            final batch = data['batch']?.toString() ?? '';
                            final type = data['type']?.toString() ?? '';

                            return _trainingCard(
                              day: day,
                              time: time,
                              batch: batch,
                              type: type,
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
        onPressed: () => _showAddTrainingDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("Add Training"),
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
              "TRAINING SCHEDULE",
              style: TextStyle(
                color: gold,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.calendar_month, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _heroBanner({required int total}) {
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
                  child: Icon(Icons.fitness_center, color: maroon, size: 42),
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
                        "TRAINING",
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
                          _heroChip("Schedules: $total"),
                          _heroChip("Cricket • Fitness • Skills"),
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

  Widget _trainingCard({
    required String day,
    required String time,
    required String batch,
    required String type,
    required VoidCallback onDelete,
  }) {
    final color = _typeColor(type);
    final icon = _typeIcon(type);

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
                  day,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$time • $batch",
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                _typeChip(type, color),
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

  Widget _typeChip(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type,
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
          Icon(Icons.calendar_month, size: 38, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No training schedule found",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text("Click Add Training to create one"),
        ],
      ),
    );
  }
}