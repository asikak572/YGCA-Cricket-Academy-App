import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';

class CoachStudentPerformanceScreen extends StatelessWidget {
  const CoachStudentPerformanceScreen({super.key});

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

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

  String _text(dynamic value, String fallback) {
    if (value == null || value.toString().trim().isEmpty) return fallback;
    return value.toString().trim();
  }

  int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString()) ?? 0;
  }

  List<String> _getAssignedBatches(Map<String, dynamic> coachData) {
    final assignedBatches = coachData['assignedBatches'];

    if (assignedBatches is List && assignedBatches.isNotEmpty) {
      return assignedBatches
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final singleBatch = coachData['batch']?.toString().trim() ?? '';
    if (singleBatch.isNotEmpty) return [singleBatch];

    final assignedBatch = coachData['assignedBatch']?.toString().trim() ?? '';
    if (assignedBatch.isNotEmpty) return [assignedBatch];

    return [];
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _studentStream(
    List<String> assignedBatches,
  ) {
    final studentsRef = FirebaseFirestore.instance.collection('students');

    if (assignedBatches.length == 1) {
      return studentsRef
          .where('batch', isEqualTo: assignedBatches.first)
          .snapshots();
    }

    return studentsRef.where('batch', whereIn: assignedBatches).snapshots();
  }

  int _overallScore({
    required int batting,
    required int bowling,
    required int fielding,
    required int fitness,
  }) {
    return ((batting + bowling + fielding + fitness) / 4).round();
  }

  String _grade(int score) {
    if (score >= 90) return "Excellent";
    if (score >= 75) return "Good";
    if (score >= 60) return "Average";
    if (score >= 40) return "Needs Work";
    return "No Data";
  }

  Color _gradeColor(int score) {
    if (score >= 90) return Colors.greenAccent;
    if (score >= 75) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.deepOrange;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final coachUid = FirebaseAuth.instance.currentUser?.uid;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        if (coachUid == null) {
          return Scaffold(
            backgroundColor: _bg(isDark),
            body: SafeArea(
              child: Column(
                children: [
                  _topHeader(context, isDark),
                  Expanded(
                    child: _messageCard(
                      isDark: isDark,
                      icon: Icons.lock_outline_rounded,
                      title: "No Coach Logged In",
                      message:
                          "Please login as coach to view student performance.",
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: _bg(isDark),
          body: SafeArea(
            child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(coachUid)
                  .get(),
              builder: (context, coachSnapshot) {
                if (coachSnapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      _topHeader(context, isDark),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }

                if (coachSnapshot.hasError) {
                  return Column(
                    children: [
                      _topHeader(context, isDark),
                      Expanded(
                        child: _messageCard(
                          isDark: isDark,
                          icon: Icons.error_outline_rounded,
                          title: "Something Went Wrong",
                          message: coachSnapshot.error.toString(),
                        ),
                      ),
                    ],
                  );
                }

                if (!coachSnapshot.hasData || !coachSnapshot.data!.exists) {
                  return Column(
                    children: [
                      _topHeader(context, isDark),
                      Expanded(
                        child: _messageCard(
                          isDark: isDark,
                          icon: Icons.person_off_rounded,
                          title: "Coach Data Not Found",
                          message:
                              "Coach profile is not available in users collection.",
                        ),
                      ),
                    ],
                  );
                }

                final coachData = coachSnapshot.data!.data() ?? {};
                final assignedBatches = _getAssignedBatches(coachData);
                final coachName = _text(coachData['name'], 'Coach');

                if (assignedBatches.isEmpty) {
                  return Column(
                    children: [
                      _topHeader(context, isDark),
                      Expanded(
                        child: _messageCard(
                          isDark: isDark,
                          icon: Icons.groups_2_outlined,
                          title: "No Batch Assigned",
                          message: "No batch is assigned to this coach yet.",
                        ),
                      ),
                    ],
                  );
                }

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _studentStream(assignedBatches),
                  builder: (context, studentSnapshot) {
                    if (studentSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Column(
                        children: [
                          _topHeader(context, isDark),
                          const Expanded(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ],
                      );
                    }

                    if (studentSnapshot.hasError) {
                      return Column(
                        children: [
                          _topHeader(context, isDark),
                          Expanded(
                            child: _messageCard(
                              isDark: isDark,
                              icon: Icons.error_outline_rounded,
                              title: "Students Loading Error",
                              message: studentSnapshot.error.toString(),
                            ),
                          ),
                        ],
                      );
                    }

                    final students = studentSnapshot.data?.docs ?? [];

                    int totalBatting = 0;
                    int totalBowling = 0;
                    int totalFielding = 0;
                    int totalFitness = 0;

                    for (final student in students) {
                      final data = student.data();

                      totalBatting += _safeInt(
                        data['battingScore'] ?? data['batting'] ?? 0,
                      );
                      totalBowling += _safeInt(
                        data['bowlingScore'] ?? data['bowling'] ?? 0,
                      );
                      totalFielding += _safeInt(
                        data['fieldingScore'] ?? data['fielding'] ?? 0,
                      );
                      totalFitness += _safeInt(
                        data['fitnessScore'] ?? data['fitness'] ?? 0,
                      );
                    }

                    final count = students.isEmpty ? 1 : students.length;

                    final avgBatting = (totalBatting / count).round();
                    final avgBowling = (totalBowling / count).round();
                    final avgFielding = (totalFielding / count).round();
                    final avgFitness = (totalFitness / count).round();

                    final overall = _overallScore(
                      batting: avgBatting,
                      bowling: avgBowling,
                      fielding: avgFielding,
                      fitness: avgFitness,
                    );

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(child: _topHeader(context, isDark)),
                        SliverToBoxAdapter(
                          child: _heroBanner(
                            isDark: isDark,
                            coachName: coachName,
                            studentCount: students.length,
                            overall: overall,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        SliverToBoxAdapter(
                          child: _summaryCards(
                            isDark: isDark,
                            batting: avgBatting,
                            bowling: avgBowling,
                            fielding: avgFielding,
                            fitness: avgFitness,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 18)),
                        SliverToBoxAdapter(
                          child: _sectionTitle(
                            "STUDENT PERFORMANCE",
                            isDark,
                          ),
                        ),
                        students.isEmpty
                            ? SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: _emptyCard(isDark),
                                ),
                              )
                            : SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final data = students[index].data();

                                      final name = _text(data['name'], 'Student');
                                      final rollNo = _text(data['rollNo'], '-');
                                      final batch = _text(data['batch'], '-');

                                      final batting = _safeInt(
                                        data['battingScore'] ??
                                            data['batting'] ??
                                            0,
                                      );
                                      final bowling = _safeInt(
                                        data['bowlingScore'] ??
                                            data['bowling'] ??
                                            0,
                                      );
                                      final fielding = _safeInt(
                                        data['fieldingScore'] ??
                                            data['fielding'] ??
                                            0,
                                      );
                                      final fitness = _safeInt(
                                        data['fitnessScore'] ??
                                            data['fitness'] ??
                                            0,
                                      );

                                      final score = _overallScore(
                                        batting: batting,
                                        bowling: bowling,
                                        fielding: fielding,
                                        fitness: fitness,
                                      );

                                      return _performanceStudentCard(
                                        isDark: isDark,
                                        name: name,
                                        rollNo: rollNo,
                                        batch: batch,
                                        batting: batting,
                                        bowling: bowling,
                                        fielding: fielding,
                                        fitness: fitness,
                                        overall: score,
                                      );
                                    },
                                    childCount: students.length,
                                  ),
                                ),
                              ),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    );
                  },
                );
              },
            ),
          ),
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
              "STUDENT PERFORMANCE",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : gold,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
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

  Widget _heroBanner({
    required bool isDark,
    required String coachName,
    required int studentCount,
    required int overall,
  }) {
    return Container(
      height: 190,
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
              right: -28,
              bottom: -28,
              child: Icon(
                Icons.analytics_rounded,
                color: Colors.white.withOpacity(0.08),
                size: 150,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.analytics_rounded,
                      color: maroon,
                      size: 42,
                    ),
                  ),
                  const SizedBox(width: 15),
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
                              coachName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Assigned Student Performance",
                              style: TextStyle(
                                color: gold,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _heroChip("Students: $studentCount"),
                                _heroChip("Overall: $overall"),
                              ],
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

  Widget _heroChip(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.75)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: gold,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _summaryCards({
    required bool isDark,
    required int batting,
    required int bowling,
    required int fielding,
    required int fitness,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.45,
        children: [
          _summaryCard(
            isDark: isDark,
            icon: Icons.sports_cricket_rounded,
            title: "Batting Avg",
            value: batting.toString(),
            color: Colors.green,
          ),
          _summaryCard(
            isDark: isDark,
            icon: Icons.sports_baseball_rounded,
            title: "Bowling Avg",
            value: bowling.toString(),
            color: Colors.orange,
          ),
          _summaryCard(
            isDark: isDark,
            icon: Icons.sports_handball_rounded,
            title: "Fielding Avg",
            value: fielding.toString(),
            color: Colors.blueAccent,
          ),
          _summaryCard(
            isDark: isDark,
            icon: Icons.fitness_center_rounded,
            title: "Fitness Avg",
            value: fitness.toString(),
            color: Colors.purpleAccent,
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : _border(isDark),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: color.withOpacity(0.14),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? gold : maroon,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              color: isDark ? red.withOpacity(0.45) : gold.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _performanceStudentCard({
    required bool isDark,
    required String name,
    required String rollNo,
    required String batch,
    required int batting,
    required int bowling,
    required int fielding,
    required int fitness,
    required int overall,
  }) {
    final color = _gradeColor(overall);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : _border(isDark),
        ),
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
              CircleAvatar(
                radius: 29,
                backgroundColor: maroon,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                  style: const TextStyle(
                    color: gold,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
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
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Roll No: $rollNo • Batch: $batch",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.13 : 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.30)),
                ),
                child: Text(
                  "$overall",
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _scoreChip(
                  isDark: isDark,
                  label: "Bat",
                  value: batting,
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _scoreChip(
                  isDark: isDark,
                  label: "Bowl",
                  value: bowling,
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _scoreChip(
                  isDark: isDark,
                  label: "Field",
                  value: fielding,
                  color: Colors.blueAccent,
                ),
              ),
              Expanded(
                child: _scoreChip(
                  isDark: isDark,
                  label: "Fit",
                  value: fitness,
                  color: Colors.purpleAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _grade(overall),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreChip({
    required bool isDark,
    required String label,
    required int value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.13 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              color: _primaryText(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.analytics_rounded,
            size: 42,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            "No Performance Data Found",
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "No students are available in this coach assigned batch.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondaryText(isDark),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: _card(isDark),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border(isDark)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 46,
                color: isDark ? gold : maroon,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}