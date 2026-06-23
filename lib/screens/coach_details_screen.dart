import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'coach_salary_screen.dart';

class CoachDetailsScreen extends StatefulWidget {
  final String coachId;
  final String name;
  final String role;
  final String phone;
  final String batch;
  final String status;

  const CoachDetailsScreen({
    super.key,
    required this.coachId,
    required this.name,
    required this.role,
    required this.phone,
    required this.batch,
    required this.status,
  });

  @override
  State<CoachDetailsScreen> createState() => _CoachDetailsScreenState();
}

class _CoachDetailsScreenState extends State<CoachDetailsScreen> {
  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

  static const List<String> academyBatches = [
    "Monday: 6:00 AM – 8:00 AM",
    "Monday: 4:00 PM – 6:00 PM",
    "Tuesday: 6:00 AM – 8:00 AM",
    "Tuesday: 4:00 PM – 6:00 PM",
    "Wednesday: 6:00 AM – 8:00 AM",
    "Wednesday: 4:00 PM – 6:00 PM",
    "Thursday: 6:00 AM – 8:00 AM",
    "Thursday: 4:00 PM – 6:00 PM",
    "Friday: 6:00 AM – 8:00 AM",
    "Friday: 6:00 PM – 8:00 PM",
    "Saturday: 7:00 AM – 9:00 AM",
    "Saturday: 4:00 PM – 6:00 PM",
    "Sunday: 7:00 AM – 9:00 AM",
    "Sunday: 4:00 PM – 6:00 PM",
  ];

  String _cleanEmail(String value) => value.trim().toLowerCase();

  List<String> _assignedBatches(Map<String, dynamic> data) {
    final raw = data['assignedBatches'];

    if (raw is List && raw.isNotEmpty) {
      return raw
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final oldBatch = data['batch']?.toString().trim() ?? widget.batch.trim();
    if (oldBatch.isNotEmpty && oldBatch != 'No Batch Assigned') {
      return [oldBatch];
    }

    return [];
  }

  String _batchesText(List<String> batches) {
    if (batches.isEmpty) return "No Batch Assigned";
    return batches.join(', ');
  }

  Future<void> _syncCoachUserByEmail({
    required String email,
    required Map<String, dynamic> data,
  }) async {
    final emailLower = _cleanEmail(email);
    if (emailLower.isEmpty) return;

    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('emailLower', isEqualTo: emailLower)
        .limit(1)
        .get();

    if (userSnapshot.docs.isEmpty) {
      userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
    }

    if (userSnapshot.docs.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userSnapshot.docs.first.id)
        .set(data, SetOptions(merge: true));
  }

  Future<void> _deleteCoach() async {
    await FirebaseFirestore.instance
        .collection('coaches')
        .doc(widget.coachId)
        .delete();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Coach deleted successfully")),
    );
    Navigator.pop(context);
  }

  Future<void> _updateCoach({
    required String name,
    required String email,
    required String role,
    required String phone,
    required List<String> assignedBatches,
    required String status,
    required String experience,
    required String specialization,
  }) async {
    final emailLower = _cleanEmail(email);

    final updateData = {
      'name': name.trim(),
      'email': email.trim(),
      'emailLower': emailLower,
      'role': role.trim(),
      'phone': phone.trim(),
      'assignedBatches': assignedBatches,
      'batch': assignedBatches.isEmpty ? '' : assignedBatches.first,
      'batchText': assignedBatches.join(', '),
      'status': status.trim(),
      'experience': experience.trim(),
      'specialization': specialization.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('coaches')
        .doc(widget.coachId)
        .set(updateData, SetOptions(merge: true));

    await _syncCoachUserByEmail(
      email: email,
      data: {
        'name': name.trim(),
        'email': email.trim(),
        'emailLower': emailLower,
        'role': 'Coach',
        'phone': phone.trim(),
        'assignedBatches': assignedBatches,
        'batch': assignedBatches.isEmpty ? '' : assignedBatches.first,
        'batchText': assignedBatches.join(', '),
        'status': status.trim(),
        'specialization': specialization.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Coach updated and batch assigned")),
    );
    Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Coach"),
        content: Text("Are you sure you want to delete ${widget.name}?"),
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
              await _deleteCoach();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> data) {
    final nameController = TextEditingController(
      text: data['name']?.toString() ?? widget.name,
    );
    final emailController = TextEditingController(
      text: data['email']?.toString() ?? '',
    );
    final roleController = TextEditingController(
      text: data['role']?.toString() ?? widget.role,
    );
    final phoneController = TextEditingController(
      text: data['phone']?.toString() ?? widget.phone,
    );
    final statusController = TextEditingController(
      text: data['status']?.toString() ?? widget.status,
    );
    final experienceController = TextEditingController(
      text: data['experience']?.toString() ?? '5 Years',
    );

    String selectedSpecialization =
        data['specialization']?.toString() ?? 'Batting Coach';
    final selectedBatches = _assignedBatches(data).toSet();

    final specializations = [
      "Batting Coach",
      "Bowling Coach",
      "Fielding Coach",
      "Fitness Coach",
      "Head Coach",
      "Assistant Coach",
    ];

    final statusOptions = ["Active", "Inactive"];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Edit Coach"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _editField("Coach Name", nameController),
                  _editField(
                    "Coach Email",
                    emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _editField("Role", roleController),
                  _editField(
                    "Phone Number",
                    phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  _editField("Experience", experienceController),
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
                      if (value == null) return;
                      setDialogState(() => selectedSpecialization = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: statusOptions.contains(statusController.text)
                        ? statusController.text
                        : "Active",
                    decoration: const InputDecoration(
                      labelText: "Status",
                      border: OutlineInputBorder(),
                    ),
                    items: statusOptions.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => statusController.text = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Assigned Batches",
                      style: TextStyle(
                        color: maroon,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: academyBatches.map((batch) {
                      final selected = selectedBatches.contains(batch);

                      return FilterChip(
                        label: Text(
                          batch,
                          style: TextStyle(
                            fontSize: 11,
                            color: selected ? gold : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: selected,
                        selectedColor: maroon,
                        checkmarkColor: gold,
                        onSelected: (value) {
                          setDialogState(() {
                            if (value) {
                              selectedBatches.add(batch);
                            } else {
                              selectedBatches.remove(batch);
                            }
                          });
                        },
                      );
                    }).toList(),
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
                  final name = nameController.text.trim();
                  final email = emailController.text.trim();
                  final phone = phoneController.text.trim();
                  final batches = selectedBatches.toList();

                  if (name.isEmpty || email.isEmpty || phone.isEmpty || batches.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fill name, email, phone and batches"),
                      ),
                    );
                    return;
                  }

                  await _updateCoach(
                    name: name,
                    email: email,
                    role: roleController.text,
                    phone: phone,
                    assignedBatches: batches,
                    status: statusController.text,
                    experience: experienceController.text,
                    specialization: selectedSpecialization,
                  );

                  if (mounted) Navigator.pop(context);
                },
                child: const Text("Update"),
              ),
            ],
          );
        },
      ),
    );
  }

  String _text(Map<String, dynamic> data, String key, String fallback) {
    final value = data[key];
    if (value == null || value.toString().trim().isEmpty) return fallback;
    return value.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('coaches')
          .doc(widget.coachId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

        final name = _text(data, 'name', widget.name);
        final role = _text(data, 'role', widget.role);
        final phone = _text(data, 'phone', widget.phone);
        final status = _text(data, 'status', widget.status);
        final experience = _text(data, 'experience', '5 Years');
        final specialization = _text(data, 'specialization', 'Batting Coach');
        final batches = _assignedBatches(data);
        final batchText = _batchesText(batches);

        final initial = name.isNotEmpty ? name[0].toUpperCase() : "?";
        final isActive = status.toLowerCase() == "active";

        return Scaffold(
          backgroundColor: bg,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _topHeader(context),
                _profileHero(initial, name, role, status),
                const SizedBox(height: 18),
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
                      _statCard(Icons.groups, "BATCHES", batches.length.toString(), "Assigned", Colors.blue),
                      _statCard(Icons.verified, "STATUS", status, isActive ? "Working" : "Inactive", Colors.green),
                      _statCard(Icons.work_history, "EXPERIENCE", experience, "Coaching", Colors.orange),
                      _statCard(Icons.sports_cricket, "SPECIALITY", specialization, "Skill Area", Colors.purple),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _infoCard(
                    title: "COACH INFORMATION",
                    children: [
                      _infoRow("Coach Name", name),
                      _infoRow("Email", _text(data, 'email', 'No Email')),
                      _infoRow("Role", role),
                      _infoRow("Phone Number", phone),
                      _infoRow("Assigned Batches", batchText),
                      _infoRow("Experience", experience),
                      _infoRow("Specialization", specialization),
                      _infoRow("Status", status),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _infoCard(
                    title: "QUICK ACTIONS",
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _actionCard(
                              icon: Icons.edit,
                              title: "Edit\nCoach",
                              color: Colors.blue,
                              onTap: () => _showEditDialog(data),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _actionCard(
                              icon: Icons.delete,
                              title: "Delete\nCoach",
                              color: Colors.red,
                              onTap: _confirmDelete,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _actionCard(
                        icon: Icons.account_balance_wallet,
                        title: "Salary Details",
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CoachSalaryScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: maroon,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(55),
                          ),
                          onPressed: () => _showEditDialog(data),
                          icon: const Icon(Icons.edit),
                          label: const Text("EDIT COACH"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            minimumSize: const Size.fromHeight(55),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CoachSalaryScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.account_balance_wallet),
                          label: const Text("SALARY"),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
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
          Image.asset('assets/images/ygca_logo.jpg', width: 60),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "COACH DETAILS",
              style: TextStyle(
                color: gold,
                fontSize: 22,
                fontWeight: FontWeight.bold,
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

  Widget _profileHero(String initial, String name, String role, String status) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('assets/images/home_hero_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              darkMaroon.withOpacity(0.88),
              maroon.withOpacity(0.65),
              Colors.black.withOpacity(0.35),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,
                child: Text(
                  initial,
                  style: TextStyle(
                    color: maroon,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      role,
                      style: TextStyle(
                        color: gold,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _statusChip(status),
                    const SizedBox(height: 10),
                    const Text(
                      "Guiding players towards excellence.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final isActive = status.toLowerCase() == "active";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isActive ? Colors.green : Colors.orange,
          fontWeight: FontWeight.bold,
          fontSize: 12,
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: maroon,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _editField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
