import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'coach_details_screen.dart';

class CoachManagementScreen extends StatelessWidget {
  const CoachManagementScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

  Future<void> _addCoachDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    String selectedSpecialization = "Batting Coach";

    final specializations = [
      "Batting Coach",
      "Bowling Coach",
      "Fielding Coach",
      "Fitness Coach",
      "Head Coach",
      "Assistant Coach",
    ];

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Coach"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _field("Coach Name", nameController),
                    _field(
                      "Phone",
                      phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedSpecialization,
                      decoration: const InputDecoration(
                        labelText: "Specialization",
                        border: OutlineInputBorder(),
                      ),
                      items: specializations.map((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedSpecialization = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    nameController.dispose();
                    phoneController.dispose();
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
                    if (nameController.text.trim().isEmpty ||
                        phoneController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill all fields")),
                      );
                      return;
                    }

                    try {
                      await FirebaseFirestore.instance
                          .collection('coaches')
                          .add({
                        'name': nameController.text.trim(),
                        'role': 'Coach',
                        'phone': phoneController.text.trim(),
                        'specialization': selectedSpecialization,
                        'status': 'Active',
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      nameController.dispose();
                      phoneController.dispose();

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Coach added successfully"),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
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

  static Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ).copyWith(labelText: label),
      ),
    );
  }

  Future<void> _deleteCoach(BuildContext context, String coachId) async {
    await FirebaseFirestore.instance.collection('coaches').doc(coachId).delete();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Coach deleted")),
      );
    }
  }

  void _confirmDelete(BuildContext context, String coachId, String coachName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Coach"),
        content: Text("Are you sure you want to delete $coachName?"),
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
              await _deleteCoach(context, coachId);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _openCoachDetails({
    required BuildContext context,
    required String coachId,
    required String name,
    required String role,
    required String phone,
    required String batch,
    required String status,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoachDetailsScreen(
          coachId: coachId,
          name: name,
          role: role,
          phone: phone,
          batch: batch,
          status: status,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    if (status == "Active") return Colors.green;
    if (status == "Inactive") return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('coaches')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final coaches = snapshot.data?.docs ?? [];

          int active = 0;
          final Set<String> specializations = {};

          for (final doc in coaches) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status']?.toString() ?? 'Active';
            final specialization = data['specialization']?.toString() ??
                data['batch']?.toString() ??
                '';

            if (status == "Active") active++;
            if (specialization.isNotEmpty) specializations.add(specialization);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _topHeader(context),
                _heroBanner(
                  total: coaches.length,
                  active: active,
                  batches: specializations.length,
                ),
                const SizedBox(height: 18),
                _sectionTitle("COACH OVERVIEW"),
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
                      _statCard(Icons.sports, "COACHES",
                          coaches.length.toString(), "Total", Colors.blue),
                      _statCard(Icons.verified, "ACTIVE", active.toString(),
                          "Working", Colors.green),
                      _statCard(Icons.category, "SPECIAL", specializations.length.toString(),
                          "Types", Colors.orange),
                      _statCard(Icons.phone, "CONTACTS",
                          coaches.length.toString(), "Available", Colors.purple),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _sectionTitle("COACH LIST"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _searchBox(),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: coaches.isEmpty
                      ? _emptyCard()
                      : Column(
                          children: coaches.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;

                            final name = data['name']?.toString() ?? 'No Name';
                            final role = data['role']?.toString() ?? 'Coach';
                            final phone =
                                data['phone']?.toString() ?? 'No Phone';
                            final specialization =
                                data['specialization']?.toString() ??
                                    data['batch']?.toString() ??
                                    'No Specialization';
                            final status =
                                data['status']?.toString() ?? 'Active';

                            return _coachCard(
                              context: context,
                              coachId: doc.id,
                              name: name,
                              role: role,
                              phone: phone,
                              batch: specialization,
                              status: status,
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
        onPressed: () => _addCoachDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("Add Coach"),
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
              "COACH CENTER",
              style: TextStyle(
                color: gold,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.sports, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _heroBanner({
    required int total,
    required int active,
    required int batches,
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
                  child: Icon(Icons.sports, color: maroon, size: 42),
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
                        "COACH",
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
                          _heroChip("Active: $active"),
                          _heroChip("Types: $batches"),
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

  Widget _searchBox() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search Coach",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: border),
        ),
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

  Widget _coachCard({
    required BuildContext context,
    required String coachId,
    required String name,
    required String role,
    required String phone,
    required String batch,
    required String status,
  }) {
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: () {
          _openCoachDetails(
            context: context,
            coachId: coachId,
            name: name,
            role: role,
            phone: phone,
            batch: batch,
            status: status,
          );
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: maroon,
              child: Icon(Icons.sports, color: gold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$role • $batch",
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _chip(Icons.phone, phone, Colors.blue),
                      _chip(Icons.verified, status, color),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, coachId, name),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
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
          Icon(Icons.sports, size: 40, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No Coaches Found",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}