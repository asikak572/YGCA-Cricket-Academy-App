import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';

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
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  static const List<String> academyBatches = [
  "Friday: 6:00 PM – 8:00 PM",
  "Saturday: 7:00 AM – 9:00 AM",
  "Saturday: 4:00 PM – 6:00 PM",
  "Saturday: 6:00 PM – 8:00 PM",
];
  Color _bg(bool isDark) {
    return isDark ? const Color(0xFF070707) : const Color(0xFFFAFAFA);
  }

  Color _card(bool isDark) {
    return isDark ? const Color(0xFF111111) : Colors.white;
  }

  Color _border(bool isDark) {
    return isDark ? const Color(0xFF3A1515) : const Color(0xFFE2E8F0);
  }

  Color _primaryText(bool isDark) {
    return isDark ? Colors.white : const Color(0xFF111827);
  }

  Color _secondaryText(bool isDark) {
    return isDark ? Colors.white60 : const Color(0xFF64748B);
  }

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

  String _text(Map<String, dynamic> data, String key, String fallback) {
    final value = data[key];
    if (value == null || value.toString().trim().isEmpty) return fallback;
    return value.toString().trim();
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
      const SnackBar(
        content: Text("Coach deleted successfully"),
        backgroundColor: Colors.green,
      ),
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
      const SnackBar(
        content: Text("Coach updated and batch assigned"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _confirmDelete(bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          "Delete Coach",
          style: TextStyle(
            color: _primaryText(isDark),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          "Are you sure you want to delete ${widget.name}?",
          style: TextStyle(color: _secondaryText(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: isDark ? Colors.white70 : maroon),
            ),
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

  void _showEditDialog(Map<String, dynamic> data, bool isDark) {
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
            backgroundColor: _card(isDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: Text(
              "Edit Coach",
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _editField(
                    isDark: isDark,
                    label: "Coach Name",
                    controller: nameController,
                  ),
                  _editField(
                    isDark: isDark,
                    label: "Coach Email",
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _editField(
                    isDark: isDark,
                    label: "Role",
                    controller: roleController,
                  ),
                  _editField(
                    isDark: isDark,
                    label: "Phone Number",
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  _editField(
                    isDark: isDark,
                    label: "Experience",
                    controller: experienceController,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedSpecialization,
                    isExpanded: true,
                    dropdownColor:
                        isDark ? const Color(0xFF111111) : Colors.white,
                    style: TextStyle(
                      color: _primaryText(isDark),
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: _inputDecoration(
                      isDark: isDark,
                      label: "Specialization",
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
                    isExpanded: true,
                    dropdownColor:
                        isDark ? const Color(0xFF111111) : Colors.white,
                    style: TextStyle(
                      color: _primaryText(isDark),
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: _inputDecoration(
                      isDark: isDark,
                      label: "Status",
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
                        color: isDark ? gold : maroon,
                        fontWeight: FontWeight.w900,
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
                            color: selected
                                ? (isDark ? Colors.black : gold)
                                : _primaryText(isDark),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: selected,
                        selectedColor: isDark ? gold : maroon,
                        checkmarkColor:
                            selected ? (isDark ? Colors.black : gold) : null,
                        backgroundColor:
                            isDark ? const Color(0xFF151515) : Colors.white,
                        side: BorderSide(color: _border(isDark)),
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
                child: Text(
                  "Cancel",
                  style: TextStyle(color: isDark ? Colors.white70 : maroon),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? red : maroon,
                  foregroundColor: isDark ? Colors.white : gold,
                ),
                onPressed: () async {
                  final name = nameController.text.trim();
                  final email = emailController.text.trim();
                  final phone = phoneController.text.trim();
                  final batches = selectedBatches.toList();

                  if (name.isEmpty ||
                      email.isEmpty ||
                      phone.isEmpty ||
                      batches.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please fill name, email, phone and batches",
                        ),
                        backgroundColor: Colors.red,
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

                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text("Update"),
              ),
            ],
          );
        },
      ),
    ).then((_) {
      nameController.dispose();
      emailController.dispose();
      roleController.dispose();
      phoneController.dispose();
      statusController.dispose();
      experienceController.dispose();
    });
  }

  InputDecoration _inputDecoration({
    required bool isDark,
    required String label,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _secondaryText(isDark)),
      filled: true,
      fillColor: isDark ? const Color(0xFF0B0B0B) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _border(isDark)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? red : maroon, width: 1.4),
      ),
    );
  }

  Widget _editField({
    required bool isDark,
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: _primaryText(isDark),
          fontWeight: FontWeight.w700,
        ),
        decoration: _inputDecoration(isDark: isDark, label: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

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
            final specialization =
                _text(data, 'specialization', 'Batting Coach');
            final email = _text(data, 'email', 'No Email');

            final batches = _assignedBatches(data);
            final batchText = _batchesText(batches);
            final initial = name.isNotEmpty ? name[0].toUpperCase() : "?";
            final isActive = status.toLowerCase() == "active";

            return Scaffold(
              backgroundColor: _bg(isDark),
              body: SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _topHeader(context, isDark),
                    ),
                    SliverToBoxAdapter(
                      child: _profileHero(
                        isDark: isDark,
                        initial: initial,
                        name: name,
                        role: role,
                        status: status,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        delegate: SliverChildListDelegate(
                          [
                            _statCard(
                              isDark: isDark,
                              icon: Icons.groups_rounded,
                              title: "BATCHES",
                              value: batches.length.toString(),
                              subtitle: "Assigned",
                              color: Colors.blue,
                            ),
                            _statCard(
                              isDark: isDark,
                              icon: Icons.verified_rounded,
                              title: "STATUS",
                              value: status,
                              subtitle: isActive ? "Working" : "Inactive",
                              color: isActive ? Colors.green : Colors.orange,
                            ),
                            _statCard(
                              isDark: isDark,
                              icon: Icons.work_history_rounded,
                              title: "EXPERIENCE",
                              value: experience,
                              subtitle: "Coaching",
                              color: Colors.orange,
                            ),
                            _statCard(
                              isDark: isDark,
                              icon: Icons.sports_cricket_rounded,
                              title: "SPECIALITY",
                              value: specialization,
                              subtitle: "Skill Area",
                              color: Colors.purple,
                            ),
                          ],
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.07,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: _infoCard(
                          isDark: isDark,
                          title: "COACH INFORMATION",
                          children: [
                            _infoRow(
                              isDark: isDark,
                              title: "Coach Name",
                              value: name,
                            ),
                            _infoRow(
                              isDark: isDark,
                              title: "Email",
                              value: email,
                            ),
                            _infoRow(
                              isDark: isDark,
                              title: "Role",
                              value: role,
                            ),
                            _infoRow(
                              isDark: isDark,
                              title: "Phone Number",
                              value: phone,
                            ),
                            _infoRow(
                              isDark: isDark,
                              title: "Assigned Batches",
                              value: batchText,
                            ),
                            _infoRow(
                              isDark: isDark,
                              title: "Experience",
                              value: experience,
                            ),
                            _infoRow(
                              isDark: isDark,
                              title: "Specialization",
                              value: specialization,
                            ),
                            _infoRow(
                              isDark: isDark,
                              title: "Status",
                              value: status,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: _infoCard(
                          isDark: isDark,
                          title: "QUICK ACTIONS",
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _actionCard(
                                    isDark: isDark,
                                    icon: Icons.edit_rounded,
                                    title: "Edit\nCoach",
                                    color: Colors.blue,
                                    onTap: () => _showEditDialog(
                                      data,
                                      isDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _actionCard(
                                    isDark: isDark,
                                    icon: Icons.delete_rounded,
                                    title: "Delete\nCoach",
                                    color: Colors.red,
                                    onTap: () => _confirmDelete(isDark),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _actionCard(
                              isDark: isDark,
                              icon: Icons.account_balance_wallet_rounded,
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
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? red : maroon,
                                  foregroundColor:
                                      isDark ? Colors.white : gold,
                                  minimumSize: const Size.fromHeight(54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => _showEditDialog(data, isDark),
                                icon: const Icon(Icons.edit_rounded),
                                label: const Text(
                                  "EDIT COACH",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      isDark ? Colors.greenAccent : Colors.green,
                                  side: BorderSide(
                                    color: isDark
                                        ? Colors.greenAccent
                                        : Colors.green,
                                  ),
                                  minimumSize: const Size.fromHeight(54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const CoachSalaryScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                ),
                                label: const Text(
                                  "SALARY",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 30)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _topHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : maroon,
        border: Border(
          bottom: BorderSide(
            color: isDark ? red.withOpacity(0.35) : gold.withOpacity(0.55),
          ),
        ),
      ),
      child: Row(
        children: [
          _circleButton(
            isDark: isDark,
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Image.asset(
            'assets/images/ygca_logo.jpg',
            width: 46,
            height: 46,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "COACH DETAILS",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : gold,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeMode,
            builder: (context, mode, _) {
              final dark = mode == ThemeMode.dark;

              return _circleButton(
                isDark: isDark,
                icon: dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                onTap: ThemeController.toggleTheme,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color:
              isDark ? const Color(0xFF111111) : Colors.white.withOpacity(0.14),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? red.withOpacity(0.28) : gold.withOpacity(0.55),
          ),
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : gold,
          size: 22,
        ),
      ),
    );
  }

  Widget _profileHero({
    required bool isDark,
    required String initial,
    required String name,
    required String role,
    required String status,
  }) {
    return Container(
      height: 214,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? red.withOpacity(0.45) : gold.withOpacity(0.85),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.16) : maroon.withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/images/home_hero_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    Colors.black.withOpacity(0.92),
                    darkMaroon.withOpacity(0.88),
                    red.withOpacity(0.30),
                  ]
                : [
                    darkMaroon.withOpacity(0.92),
                    maroon.withOpacity(0.72),
                    Colors.black.withOpacity(0.26),
                  ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              bottom: -28,
              child: Icon(
                Icons.sports_cricket_rounded,
                color: Colors.white.withOpacity(0.08),
                size: 150,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: maroon,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 230,
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
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              role,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: gold,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _statusChip(status),
                            const SizedBox(height: 10),
                            const Text(
                              "Guiding players towards excellence.",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final isActive = status.toLowerCase() == "active";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.16)
            : Colors.orange.withOpacity(0.16),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isActive
              ? Colors.green.withOpacity(0.35)
              : Colors.orange.withOpacity(0.35),
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isActive ? Colors.greenAccent : Colors.orangeAccent,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _statCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF151515),
                  const Color(0xFF1A0808),
                  color.withOpacity(0.15),
                ]
              : [
                  Colors.white,
                  const Color(0xFFFFFBF2),
                  color.withOpacity(0.08),
                ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : gold.withOpacity(0.65),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 130,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 31),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: _secondaryText(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required bool isDark,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border(isDark)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.28)
                : Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? gold : maroon,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 1,
                  color: isDark ? red.withOpacity(0.45) : gold.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow({
    required bool isDark,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: _secondaryText(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 92,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(isDark ? 0.11 : 0.06),
          border: Border.all(color: color.withOpacity(0.30)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w900,
                fontSize: 12,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}