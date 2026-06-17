import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'performance_chart_screen.dart';
import 'notification_service.dart';

class PerformanceReportScreen extends StatefulWidget {
  const PerformanceReportScreen({super.key});

  @override
  State<PerformanceReportScreen> createState() =>
      _PerformanceReportScreenState();
}

class _PerformanceReportScreenState extends State<PerformanceReportScreen> {
  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

  String role = '';
  String uid = '';
  List<String> linkedChildrenIds = [];

  Query _performanceQuery() {
    Query query =
        FirebaseFirestore.instance.collection('performance_reports');

    if (role == 'Student') {
      query = query.where('studentId', isEqualTo: uid);
    } else if (role == 'Parent') {
      if (linkedChildrenIds.isNotEmpty) {
        query = query.where(
          'studentId',
          whereIn: linkedChildrenIds.take(10).toList(),
        );
      } else {
        query = query.where('studentId', isEqualTo: 'NO_CHILD');
      }
    }

    return query.orderBy('createdAt', descending: true);
  }

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    uid = user.uid;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!userDoc.exists) return;

    final data = userDoc.data() ?? {};

    if (!mounted) return;

    setState(() {
      role = data['role']?.toString() ?? '';
      linkedChildrenIds = List<String>.from(data['linkedChildrenIds'] ?? []);
    });
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  String _ratingText(int batting, int bowling, int fielding, int fitness) {
    final avg = ((batting + bowling + fielding + fitness) / 4).round();

    if (avg >= 90) return "ELITE";
    if (avg >= 75) return "EXCELLENT";
    if (avg >= 60) return "GOOD";
    if (avg >= 40) return "AVERAGE";
    return "NEEDS WORK";
  }

  Color _ratingColor(String rating) {
    if (rating == "ELITE") return Colors.purple;
    if (rating == "EXCELLENT") return Colors.green;
    if (rating == "GOOD") return Colors.blue;
    if (rating == "AVERAGE") return Colors.orange;
    return Colors.red;
  }

  void _openAnalytics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PerformanceChartScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: StreamBuilder<QuerySnapshot>(
        stream: _performanceQuery().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data?.docs ?? [];

          int excellent = 0;
          int average = 0;

          for (final doc in reports) {
            final data = doc.data() as Map<String, dynamic>;
            final batting = _toInt(data['batting']);
            final bowling = _toInt(data['bowling']);
            final fielding = _toInt(data['fielding']);
            final fitness = _toInt(data['fitness']);

            final rating = _ratingText(batting, bowling, fielding, fitness);

            if (rating == "ELITE" || rating == "EXCELLENT") {
              excellent++;
            } else if (rating == "GOOD") {
              average++;
            }
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _topHeader(context),
                _heroBanner(
                  totalReports: reports.length,
                  excellent: excellent,
                  average: average,
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: maroon,
                        foregroundColor: gold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _openAnalytics(context),
                      icon: const Icon(Icons.analytics),
                      label: const Text(
                        "View Performance Analytics",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),
                _sectionTitle("PERFORMANCE REPORTS"),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: reports.isEmpty
                      ? _emptyCard()
                      : Column(
                          children: reports.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;

                            final name =
                                data['studentName']?.toString() ??
                                    data['name']?.toString() ??
                                    'Unknown Student';

                            final batch = data['batch']?.toString() ?? '';

                            final batting = _toInt(data['batting']);
                            final bowling = _toInt(data['bowling']);
                            final fielding = _toInt(data['fielding']);
                            final fitness = _toInt(data['fitness']);

                            final remarks = data['remarks']?.toString() ?? '';
                            final rating = _ratingText(
                              batting,
                              bowling,
                              fielding,
                              fitness,
                            );
                            final ratingColor = _ratingColor(rating);

                            return _performanceCard(
                              name: name,
                              batch: batch,
                              batting: batting,
                              bowling: bowling,
                              fielding: fielding,
                              fitness: fitness,
                              remarks: remarks,
                              rating: rating,
                              ratingColor: ratingColor,
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
      floatingActionButton: role == 'Admin' || role == 'Coach'
          ? FloatingActionButton.extended(
              backgroundColor: maroon,
              foregroundColor: gold,
              onPressed: () {
                _showAddDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Report"),
            )
          : null,
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
              "PERFORMANCE REPORTS",
              style: TextStyle(
                color: gold,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.bar_chart, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _heroBanner({
    required int totalReports,
    required int excellent,
    required int average,
  }) {
    return Container(
      height: 240,
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
                    maroon.withOpacity(0.72),
                    Colors.black.withOpacity(0.40),
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
                  child: Icon(
                    Icons.emoji_events,
                    color: maroon,
                    size: 42,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PLAYER",
                        style: TextStyle(
                          color: gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "PERFORMANCE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      Text(
                        "CENTER",
                        style: TextStyle(
                          color: gold,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _heroChip("Reports: $totalReports"),
                          _heroChip("Excellent: $excellent"),
                          _heroChip("Average: $average"),
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

  Widget _performanceCard({
    required String name,
    required String batch,
    required int batting,
    required int bowling,
    required int fielding,
    required int fitness,
    required String remarks,
    required String rating,
    required Color ratingColor,
  }) {
    final initials = name
        .split(" ")
        .where((part) => part.isNotEmpty)
        .map((part) => part[0])
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: maroon,
                child: Text(
                  initials.isNotEmpty ? initials : "?",
                  style: TextStyle(color: gold, fontWeight: FontWeight.bold),
                ),
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
                    Text(
                      batch,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _ratingChip(rating, ratingColor),
            ],
          ),
          const SizedBox(height: 16),
          _skillBar("Batting", batting, Colors.green),
          _skillBar("Bowling", bowling, Colors.blue),
          _skillBar("Fielding", fielding, Colors.orange),
          _skillBar("Fitness", fitness, Colors.purple),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                Icon(Icons.rate_review, color: gold, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    remarks.isEmpty
                        ? "Coach Remarks: No remarks added"
                        : "Coach Remarks: $remarks",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingChip(String rating, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        rating,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    String? selectedStudentId;
    String selectedStudentName = '';
    String selectedBatch = '';

    final battingController = TextEditingController();
    final bowlingController = TextEditingController();
    final fieldingController = TextEditingController();
    final fitnessController = TextEditingController();
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Performance Report"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('students')
                          .orderBy('name')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text("No students found");
                        }

                        final students = snapshot.data!.docs;

                        return DropdownButtonFormField<String>(
                          value: selectedStudentId,
                          decoration: const InputDecoration(
                            labelText: "Select Student",
                            border: OutlineInputBorder(),
                          ),
                          items: students.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final name = data['name']?.toString() ?? 'No Name';
                            final batch =
                                data['batch']?.toString() ?? 'No Batch';

                            return DropdownMenuItem(
                              value: doc.id,
                              child: Text("$name - $batch"),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;

                            final selectedDoc = students.firstWhere(
                              (doc) => doc.id == value,
                            );

                            final data =
                                selectedDoc.data() as Map<String, dynamic>;

                            setDialogState(() {
                              selectedStudentId = selectedDoc.id;
                              selectedStudentName =
                                  data['name']?.toString() ?? '';
                              selectedBatch = data['batch']?.toString() ?? '';
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _field(
                      "Batting %",
                      battingController,
                      keyboardType: TextInputType.number,
                    ),
                    _field(
                      "Bowling %",
                      bowlingController,
                      keyboardType: TextInputType.number,
                    ),
                    _field(
                      "Fielding %",
                      fieldingController,
                      keyboardType: TextInputType.number,
                    ),
                    _field(
                      "Fitness %",
                      fitnessController,
                      keyboardType: TextInputType.number,
                    ),
                    _field("Coach Remarks", remarksController),
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
                    if (selectedStudentId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a student"),
                        ),
                      );
                      return;
                    }

                    final batting =
                        int.tryParse(battingController.text.trim()) ?? 0;
                    final bowling =
                        int.tryParse(bowlingController.text.trim()) ?? 0;
                    final fielding =
                        int.tryParse(fieldingController.text.trim()) ?? 0;
                    final fitness =
                        int.tryParse(fitnessController.text.trim()) ?? 0;

                    await FirebaseFirestore.instance
                        .collection('performance_reports')
                        .add({
                      'studentId': selectedStudentId,
                      'studentName': selectedStudentName,
                      'batch': selectedBatch,
                      'batting': batting,
                      'bowling': bowling,
                      'fielding': fielding,
                      'fitness': fitness,
                      'remarks': remarksController.text.trim(),
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    await FirebaseFirestore.instance
                        .collection('students')
                        .doc(selectedStudentId)
                        .update({
                      'latestBatting': batting,
                      'latestBowling': bowling,
                      'latestFielding': fielding,
                      'latestFitness': fitness,
                      'latestPerformanceRemarks':
                          remarksController.text.trim(),
                      'latestPerformanceUpdatedAt':
                          FieldValue.serverTimestamp(),
                    });

                    await NotificationService.performanceUpdate(
  studentName: selectedStudentName,
  studentId: selectedStudentId!,
  batch: selectedBatch,
);

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Performance report saved"),
                        ),
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

  Widget _field(
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

  Widget _skillBar(String title, int value, Color color) {
    final safeValue = value.clamp(0, 100);

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                "$safeValue%",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: safeValue / 100,
              backgroundColor: const Color(0xFFE2E8F0),
              color: color,
              minHeight: 8,
            ),
          ),
        ],
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
          Icon(Icons.bar_chart, size: 38, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No performance reports found",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text("Click Add Report to create one"),
        ],
      ),
    );
  }
}