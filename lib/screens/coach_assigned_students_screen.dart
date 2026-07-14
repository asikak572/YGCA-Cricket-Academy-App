import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';

class CoachAssignedStudentsScreen extends StatelessWidget {
  const CoachAssignedStudentsScreen({super.key});

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

  DateTime _startOfWeek(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day - (date.weekday - 1),
    );
  }

  String _dateId(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _currentWeekId() {
    return _dateId(_startOfWeek(DateTime.now()));
  }

  Future<Map<String, dynamic>> _loadCoachWeeklyData(String coachUid) async {
    final firestore = FirebaseFirestore.instance;
    final weekId = _currentWeekId();

    final coachDoc = await firestore.collection('users').doc(coachUid).get();
    final coachData = coachDoc.data() ?? {};
    final coachName = _text(coachData['name'], AppStrings.coachLabel);

    final assignmentSnapshot = await firestore
        .collection('coach_session_assignments')
        .where('weekStartDate', isEqualTo: weekId)
        .get();

    final assignedSessions = <String>[];

    for (final doc in assignmentSnapshot.docs) {
      final data = doc.data();

      final coachId = data['coachId']?.toString().trim() ?? '';
      final status = data['status']?.toString().toLowerCase().trim() ?? '';
      final session = data['session']?.toString().trim() ?? '';

      if (coachId == coachUid &&
          status == 'active' &&
          session.isNotEmpty &&
          !assignedSessions.contains(session)) {
        assignedSessions.add(session);
      }
    }

    return {
      'coachName': coachName,
      'assignedSessions': assignedSessions,
      'weekStartDate': weekId,
    };
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _studentStream(
    List<String> assignedSessions,
  ) {
    final studentsRef = FirebaseFirestore.instance.collection('students');

    if (assignedSessions.length == 1) {
      return studentsRef
          .where('batch', isEqualTo: assignedSessions.first)
          .snapshots();
    }

    return studentsRef.where('batch', whereIn: assignedSessions).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final coachUid = FirebaseAuth.instance.currentUser?.uid;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<String>(
          valueListenable: ThemeController.language,
          builder: (context, language, __) {
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
                      title: AppStrings.noCoachLoggedIn,
                      message: AppStrings.loginAsCoachToViewStudents,
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
            child: FutureBuilder<Map<String, dynamic>>(
              future: _loadCoachWeeklyData(coachUid),
              builder: (context, weeklySnapshot) {
                if (weeklySnapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      _topHeader(context, isDark),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }

                if (weeklySnapshot.hasError) {
                  return Column(
                    children: [
                      _topHeader(context, isDark),
                      Expanded(
                        child: _messageCard(
                          isDark: isDark,
                          icon: Icons.error_outline_rounded,
                          title: AppStrings.weeklyAssignmentError,
                          message: weeklySnapshot.error.toString(),
                        ),
                      ),
                    ],
                  );
                }

                final weeklyData = weeklySnapshot.data ?? {};
                final coachName = weeklyData['coachName']?.toString() ?? AppStrings.coachLabel;

                final assignedSessions =
                    (weeklyData['assignedSessions'] as List?)
                            ?.map((e) => e.toString())
                            .where((e) => e.trim().isNotEmpty)
                            .toList() ??
                        [];

                if (assignedSessions.isEmpty) {
                  return Column(
                    children: [
                      _topHeader(context, isDark),
                      Expanded(
                        child: _messageCard(
                          isDark: isDark,
                          icon: Icons.event_busy_rounded,
                          title: AppStrings.noSessionAssigned,
                          message:
                              AppStrings.adminNotAssignedCurrentWeekSession,
                        ),
                      ),
                    ],
                  );
                }

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _studentStream(assignedSessions),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children: [
                          _topHeader(context, isDark),
                          const Expanded(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ],
                      );
                    }

                    if (snapshot.hasError) {
                      return Column(
                        children: [
                          _topHeader(context, isDark),
                          Expanded(
                            child: _messageCard(
                              isDark: isDark,
                              icon: Icons.error_outline_rounded,
                              title: AppStrings.studentsLoadingError,
                              message: snapshot.error.toString(),
                            ),
                          ),
                        ],
                      );
                    }

                    final students = snapshot.data?.docs ?? [];

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _topHeader(context, isDark),
                        ),
                        SliverToBoxAdapter(
                          child: _heroBanner(
                            isDark: isDark,
                            coachName: coachName,
                            batchCount: assignedSessions.length,
                            studentCount: students.length,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        SliverToBoxAdapter(
                          child: _sectionTitle(
                            AppStrings.currentWeekSessionsTitle,
                            isDark,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _batchCard(
                              isDark: isDark,
                              batches: assignedSessions,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 18)),
                        SliverToBoxAdapter(
                          child: _sectionTitle(
                            AppStrings.assignedStudentsTitle.toUpperCase(),
                            isDark,
                          ),
                        ),
                        students.isEmpty
                            ? SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: _emptyStudentsCard(
                                    isDark: isDark,
                                    batches: assignedSessions,
                                  ),
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

                                      final name = _text(data['name'], AppStrings.student);
                                      final rollNo = _text(data['rollNo'], '-');
                                      final batch = _text(data['batch'], '-');
                                      final phone = _text(data['phone'], '-');
                                      final status =
                                          _text(data['status'], AppStrings.active);

                                      return _studentCard(
                                        isDark: isDark,
                                        name: name,
                                        rollNo: rollNo,
                                        batch: batch,
                                        phone: phone,
                                        status: status,
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
      },
    );
  }

  Widget _topHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Row(
        children: [
          _circleButton(
            isDark: isDark,
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Image.asset(
            'assets/images/ygca_logo.jpg',
            width: 46,
            height: 46,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.assignedStudentsTitle.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  AppStrings.currentWeekCoachStudentCenter,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
          color: _card(isDark),
          shape: BoxShape.circle,
          border: Border.all(color: _border(isDark)),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? red.withOpacity(0.12)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : maroon,
          size: 21,
        ),
      ),
    );
  }

  Widget _heroBanner({
    required bool isDark,
    required String coachName,
    required int batchCount,
    required int studentCount,
  }) {
    return Container(
      height: 200,
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
                Icons.groups_rounded,
                color: Colors.white.withOpacity(0.08),
                size: 155,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.groups_rounded,
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
                              AppStrings.assignedStudentCenter,
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
                                _heroChip("${AppStrings.sessions}: $batchCount"),
                                _heroChip("${AppStrings.students}: $studentCount"),
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
      constraints: const BoxConstraints(maxWidth: 140),
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
        style: const TextStyle(
          color: gold,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
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

  Widget _batchCard({
    required bool isDark,
    required List<String> batches,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : gold.withOpacity(0.75),
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
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: batches.map((batch) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: isDark ? red.withOpacity(0.10) : gold.withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? red.withOpacity(0.25) : gold.withOpacity(0.65),
              ),
            ),
            child: Text(
              batch,
              style: TextStyle(
                color: isDark ? gold : maroon,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _studentCard({
    required bool isDark,
    required String name,
    required String rollNo,
    required String batch,
    required String phone,
    required String status,
  }) {
    final isActive = status.toLowerCase().trim() == 'active';

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
      child: Row(
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
                  "${AppStrings.rollNo}: $rollNo • ${AppStrings.session}: $batch",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _chip(
                      isDark: isDark,
                      icon: Icons.phone_rounded,
                      text: phone,
                      color: Colors.blue,
                    ),
                    _chip(
                      isDark: isDark,
                      icon: Icons.verified_rounded,
                      text: status.toLowerCase().trim() == 'active' ? AppStrings.active : status,
                      color: isActive ? Colors.green : Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required bool isDark,
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.13 : 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.20)),
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

  Widget _emptyStudentsCard({
    required bool isDark,
    required List<String> batches,
  }) {
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
            Icons.person_search_rounded,
            size: 42,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.noStudentsFound,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${AppStrings.noStudentsInCurrentWeekSessions}:\n${batches.join('\n')}",
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