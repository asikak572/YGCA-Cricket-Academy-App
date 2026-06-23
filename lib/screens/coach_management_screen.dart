import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'coach_details_screen.dart';

class CoachManagementScreen extends StatelessWidget {
  const CoachManagementScreen({super.key});

  static const List<String> academyBatches = [
    "Friday: 6:00 PM – 8:00 PM",
    "Saturday: 7:00 AM – 9:00 AM",
    "Saturday: 4:00 PM – 6:00 PM",
    "Saturday: 6:00 PM – 8:00 PM",
  ];

  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

  String _cleanEmail(String value) => value.trim().toLowerCase();

  bool _isPendingStatus(String status) {
    final value = status.toLowerCase().trim();
    return value == 'pending' || value == 'waiting' || value == 'inactive';
  }

  bool _isApproved(Map<String, dynamic> data) {
    final approvalStatus =
        data['approvalStatus']?.toString().toLowerCase().trim() ?? '';
    final status = data['status']?.toString().toLowerCase().trim() ?? '';
    final isApproved = data['isApproved'] == true;

    return approvalStatus == 'approved' || status == 'active' || isApproved;
  }

  List<String> _batchesFromData(Map<String, dynamic> data) {
    final assignedBatches = data['assignedBatches'];

    if (assignedBatches is List && assignedBatches.isNotEmpty) {
      return assignedBatches
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final oldBatch = data['batch']?.toString().trim() ?? '';
    if (oldBatch.isNotEmpty) return [oldBatch];

    return [];
  }

  String _batchesText(Map<String, dynamic> data) {
    final batches = _batchesFromData(data);
    if (batches.isEmpty) return 'No Batch Assigned';
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

  Future<void> _addCoachDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    String selectedSpecialization = "Batting Coach";
    final selectedBatches = <String>{};

    final specializations = [
      "Batting Coach",
      "Bowling Coach",
      "Fielding Coach",
      "Fitness Coach",
      "Head Coach",
      "Assistant Coach",
    ];

    await showDialog(
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
                      "Coach Email",
                      emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _field(
                      "Phone",
                      phoneController,
                      keyboardType: TextInputType.phone,
                    ),
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
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Assign Batches",
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
                    final emailLower = _cleanEmail(email);
                    final phone = phoneController.text.trim();
                    final batches = selectedBatches.toList();

                    if (name.isEmpty ||
                        email.isEmpty ||
                        phone.isEmpty ||
                        batches.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please fill name, email, phone and select batch",
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      final coachData = {
                        'name': name,
                        'email': email,
                        'emailLower': emailLower,
                        'role': 'Coach',
                        'phone': phone,
                        'specialization': selectedSpecialization,
                        'assignedBatches': batches,
                        'batch': batches.first,
                        'batchText': batches.join(', '),
                        'approvalStatus': 'Approved',
                        'status': 'Active',
                        'isApproved': true,
                        'createdAt': FieldValue.serverTimestamp(),
                        'updatedAt': FieldValue.serverTimestamp(),
                      };

                      await FirebaseFirestore.instance
                          .collection('coaches')
                          .add(coachData);

                      await _syncCoachUserByEmail(
                        email: email,
                        data: {
                          'name': name,
                          'email': email,
                          'emailLower': emailLower,
                          'role': 'Coach',
                          'phone': phone,
                          'specialization': selectedSpecialization,
                          'assignedBatches': batches,
                          'batch': batches.first,
                          'batchText': batches.join(', '),
                          'approvalStatus': 'Approved',
                          'status': 'Active',
                          'isApproved': true,
                          'updatedAt': FieldValue.serverTimestamp(),
                        },
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Coach added and batch assigned"),
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

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
  }

  Future<void> _approveCoachDialog({
    required BuildContext context,
    required String coachId,
    required Map<String, dynamic> data,
  }) async {
    final selectedBatches = <String>{..._batchesFromData(data)};

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Approve Coach"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name']?.toString() ?? 'Coach',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(data['email']?.toString() ?? ''),
                    const SizedBox(height: 14),
                    Text(
                      "Assign Batches",
                      style: TextStyle(
                        color: maroon,
                        fontWeight: FontWeight.bold,
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
                    final batches = selectedBatches.toList();

                    if (batches.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select batch")),
                      );
                      return;
                    }

                    try {
                      final email = data['email']?.toString() ?? '';
                      final emailLower = _cleanEmail(email);

                      final approveData = {
                        'role': 'Coach',
                        'emailLower': emailLower,
                        'assignedBatches': batches,
                        'batch': batches.first,
                        'batchText': batches.join(', '),
                        'approvalStatus': 'Approved',
                        'status': 'Active',
                        'isApproved': true,
                        'updatedAt': FieldValue.serverTimestamp(),
                      };

                      await FirebaseFirestore.instance
                          .collection('coaches')
                          .doc(coachId)
                          .set(approveData, SetOptions(merge: true));

                      final userRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(coachId);
                      final userDoc = await userRef.get();

                      if (userDoc.exists) {
                        await userRef.set(approveData, SetOptions(merge: true));
                      } else {
                        await _syncCoachUserByEmail(
                          email: email,
                          data: approveData,
                        );
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Coach approved and batch assigned"),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Approve failed: $e")),
                        );
                      }
                    }
                  },
                  child: const Text("Approve"),
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
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
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
    if (status == "Pending") return Colors.orange;
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
          int pending = 0;
          final Set<String> specializations = {};

          for (final doc in coaches) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status']?.toString() ?? 'Pending';
            final specialization = data['specialization']?.toString() ?? '';

            if (_isApproved(data)) active++;
            if (_isPendingStatus(status) || !_isApproved(data)) pending++;
            if (specialization.isNotEmpty) specializations.add(specialization);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _topHeader(context),
                _heroBanner(
                  total: coaches.length,
                  active: active,
                  pending: pending,
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
                          "Approved", Colors.green),
                      _statCard(Icons.pending_actions, "PENDING",
                          pending.toString(), "Approval", Colors.orange),
                      _statCard(Icons.category, "SPECIAL",
                          specializations.length.toString(), "Types", Colors.purple),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _sectionTitle("COACH LIST"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: coaches.isEmpty
                      ? _emptyCard()
                      : Column(
                          children: coaches.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;

                            final name = data['name']?.toString() ?? 'No Name';
                            final role = data['role']?.toString() ?? 'Coach';
                            final phone = data['phone']?.toString() ?? 'No Phone';
                            final batch = _batchesText(data);
                            final status = data['status']?.toString() ?? 'Pending';

                            return _coachCard(
                              context: context,
                              coachId: doc.id,
                              data: data,
                              name: name,
                              role: role,
                              phone: phone,
                              batch: batch,
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
    required int pending,
  }) {
    return Container(
      height: 190,
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
                  radius: 43,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.sports, color: maroon, size: 38),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "YGCA COACH CENTER",
                        style: TextStyle(
                          color: gold,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _heroChip("Total: $total"),
                          _heroChip("Active: $active"),
                          _heroChip("Pending: $pending"),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
    required Map<String, dynamic> data,
    required String name,
    required String role,
    required String phone,
    required String batch,
    required String status,
  }) {
    final color = _statusColor(status);
    final needsApproval = !_isApproved(data) || _batchesFromData(data).isEmpty;

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
        child: Column(
          children: [
            Row(
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
            if (needsApproval) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroon,
                    foregroundColor: gold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _approveCoachDialog(
                    context: context,
                    coachId: coachId,
                    data: data,
                  ),
                  icon: const Icon(Icons.verified_user),
                  label: const Text(
                    "Approve & Assign Batch",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
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
