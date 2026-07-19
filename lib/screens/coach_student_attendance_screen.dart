import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';
import '../core/responsive/responsive_text.dart';

class CoachStudentAttendanceScreen extends StatelessWidget {
  const CoachStudentAttendanceScreen({super.key});

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
    return int.tryParse(value.toString()) ?? 0;
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

  double _attendancePercentage({
    required int present,
    required int absent,
    required int leave,
  }) {
    final total = present + absent + leave;
    if (total == 0) return 0;
    return (present / total) * 100;
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

      final assignedCoachId = data['coachId']?.toString().trim() ?? '';
      final status = data['status']?.toString().toLowerCase().trim() ?? '';
      final session = data['session']?.toString().trim() ?? '';

      if (assignedCoachId == coachUid &&
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

  Map<String, int> _studentAttendanceCounts(Map<String, dynamic> data) {
    final present = _safeInt(
      data['presentDays'] ?? data['presentCount'] ?? data['present'] ?? 0,
    );

    final leave = _safeInt(
      data['leaveDays'] ?? data['leaveCount'] ?? data['leave'] ?? 0,
    );

    final directAbsent = _safeInt(
      data['absentDays'] ?? data['absentCount'] ?? data['absent'] ?? 0,
    );

    final total = _safeInt(
      data['totalAttendanceCount'] ?? data['attendanceTotal'] ?? 0,
    );

    int absent = directAbsent;

    if (absent == 0 && total > 0) {
      final calculatedAbsent = total - present - leave;
      absent = calculatedAbsent < 0 ? 0 : calculatedAbsent;
    }

    return {
      'present': present,
      'absent': absent,
      'leave': leave,
    };
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
                        context: context,
                      isDark: isDark,
                      icon: Icons.lock_outline_rounded,
                      title: AppStrings.noCoachLoggedIn,
                      message:
                          AppStrings.loginAsCoachToViewAttendance,
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
                if (weeklySnapshot.connectionState ==
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

                if (weeklySnapshot.hasError) {
                  return Column(
                    children: [
                      _topHeader(context, isDark),
                      Expanded(
                        child: _messageCard(
                        context: context,
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
                final coachName =
                    weeklyData['coachName']?.toString() ?? AppStrings.coachLabel;

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
                        context: context,
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
                        context: context,
                              isDark: isDark,
                              icon: Icons.error_outline_rounded,
                              title: AppStrings.studentsLoadingError,
                              message: studentSnapshot.error.toString(),
                            ),
                          ),
                        ],
                      );
                    }

                    final students = studentSnapshot.data?.docs ?? [];

                    int totalPresent = 0;
                    int totalAbsent = 0;
                    int totalLeave = 0;

                    for (final student in students) {
                      final counts = _studentAttendanceCounts(student.data());
                      totalPresent += counts['present'] ?? 0;
                      totalAbsent += counts['absent'] ?? 0;
                      totalLeave += counts['leave'] ?? 0;
                    }

                    final percentage = _attendancePercentage(
                      present: totalPresent,
                      absent: totalAbsent,
                      leave: totalLeave,
                    );

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _topHeader(context, isDark),
                        ),
                        SliverToBoxAdapter(
                          child: _heroBanner(
                             context: context,
                            isDark: isDark,
                            coachName: coachName,
                            sessionCount: assignedSessions.length,
                            studentCount: students.length,
                            percentage: percentage,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        SliverToBoxAdapter(
                          child: _sectionTitle(
                             context,
                            AppStrings.currentWeekSessionsTitle,
                            isDark,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _sessionCard(
                               context: context,
                              isDark: isDark,
                              sessions: assignedSessions,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 18)),
                        SliverToBoxAdapter(
                          child: _summaryCards(
                             context: context,
                            isDark: isDark,
                            present: totalPresent,
                            absent: totalAbsent,
                            leave: totalLeave,
                            percentage: percentage,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 18)),
                        SliverToBoxAdapter(
                          child: _sectionTitle(
                             context,
                            AppStrings.studentAttendanceTitle.toUpperCase(),
                            isDark,
                          ),
                        ),
                        students.isEmpty
                            ? SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: _emptyCard(context, isDark),
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

                                      final name = _text(
                                        data['name'],
                                        AppStrings.student,
                                      );
                                      final rollNo = _text(
                                        data['rollNo'],
                                        '-',
                                      );
                                      final batch = _text(
                                        data['batch'],
                                        '-',
                                      );
                                      final status = _text(
                                        data['status'],
                                        AppStrings.active,
                                      );

                                      final counts =
                                          _studentAttendanceCounts(data);

                                      final present =
                                          counts['present'] ?? 0;
                                      final absent =
                                          counts['absent'] ?? 0;
                                      final leave = counts['leave'] ?? 0;

                                      final studentPercentage =
                                          _attendancePercentage(
                                        present: present,
                                        absent: absent,
                                        leave: leave,
                                      );

                                      return _attendanceStudentCard(
                                         context: context,
                                        isDark: isDark,
                                        name: name,
                                        rollNo: rollNo,
                                        batch: batch,
                                        status: status,
                                        present: present,
                                        absent: absent,
                                        leave: leave,
                                        percentage: studentPercentage,
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
                  AppStrings.studentAttendanceTitle.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontFamily: ResponsiveText.fontFamily,
                    fontSize: ResponsiveText.heading(context),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  AppStrings.currentWeekAssignedSessionOverview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontFamily: ResponsiveText.fontFamily,
                    fontSize: ResponsiveText.small(context),
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
    required BuildContext context,
    required bool isDark,
    required String coachName,
    required int sessionCount,
    required int studentCount,
    required double percentage,
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
                Icons.fact_check_rounded,
                color: Colors.white.withOpacity(0.08),
                size: 150,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.fact_check_rounded,
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
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: ResponsiveText.fontFamily,
                                fontSize: ResponsiveText.hero(context),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.currentWeekAttendance,
                              style: TextStyle(
                                color: gold,
                                fontFamily: ResponsiveText.fontFamily,
                                fontSize: ResponsiveText.body(context),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _heroChip(context, "${AppStrings.sessions}: $sessionCount"),
                                _heroChip(context, "${AppStrings.students}: $studentCount"),
                                _heroChip(
                                  context,
                                  "${AppStrings.avg}: ${percentage.toStringAsFixed(0)}%",
                                ),
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

  Widget _heroChip(BuildContext context, String text) {
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
          fontFamily: ResponsiveText.fontFamily,
          fontSize: ResponsiveText.small(context),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _sessionCard({
    required BuildContext context,
    required bool isDark,
    required List<String> sessions,
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
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: sessions.map((session) {
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
              session,
              style: TextStyle(
                color: isDark ? gold : maroon,
                fontFamily: ResponsiveText.fontFamily,
                fontSize: ResponsiveText.small(context),
                fontWeight: FontWeight.w900,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _summaryCards({
    required BuildContext context,
    required bool isDark,
    required int present,
    required int absent,
    required int leave,
    required double percentage,
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
            context: context,
            isDark: isDark,
            icon: Icons.check_circle_rounded,
            title: AppStrings.present,
            value: present.toString(),
            color: Colors.green,
          ),
          _summaryCard(
            context: context,
            isDark: isDark,
            icon: Icons.cancel_rounded,
            title: AppStrings.absent,
            value: absent.toString(),
            color: Colors.redAccent,
          ),
          _summaryCard(
            context: context,
            isDark: isDark,
            icon: Icons.event_busy_rounded,
            title: AppStrings.leave,
            value: leave.toString(),
            color: Colors.orange,
          ),
          _summaryCard(
            context: context,
            isDark: isDark,
            icon: Icons.percent_rounded,
            title: AppStrings.average,
            value: "${percentage.toStringAsFixed(0)}%",
            color: Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required BuildContext context,
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
                    fontFamily: ResponsiveText.fontFamily,
                    fontSize: ResponsiveText.heading(context),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontWeight: FontWeight.w700,
                    fontFamily: ResponsiveText.fontFamily,
                    fontSize: ResponsiveText.small(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? gold : maroon,
              fontFamily: ResponsiveText.fontFamily,
              fontSize: ResponsiveText.title(context),
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

  Widget _attendanceStudentCard({
    required BuildContext context,
    required bool isDark,
    required String name,
    required String rollNo,
    required String batch,
    required String status,
    required int present,
    required int absent,
    required int leave,
    required double percentage,
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
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 29,
            backgroundColor: maroon,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: TextStyle(
                color: gold,
                fontFamily: ResponsiveText.fontFamily,
                fontSize: ResponsiveText.pageTitle(context),
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
                    fontFamily: ResponsiveText.fontFamily,
                    fontSize: ResponsiveText.title(context),
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
                    fontFamily: ResponsiveText.fontFamily,
                    fontSize: ResponsiveText.bodySmall(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _chip(
                            context: context,
                      isDark: isDark,
                      icon: Icons.check_circle_rounded,
                      text: "${AppStrings.presentShort} $present",
                      color: Colors.green,
                    ),
                    _chip(
                            context: context,
                      isDark: isDark,
                      icon: Icons.cancel_rounded,
                      text: "${AppStrings.absentShort} $absent",
                      color: Colors.redAccent,
                    ),
                    _chip(
                            context: context,
                      isDark: isDark,
                      icon: Icons.event_busy_rounded,
                      text: "${AppStrings.leaveShort} $leave",
                      color: Colors.orange,
                    ),
                    _chip(
                            context: context,
                      isDark: isDark,
                      icon: Icons.percent_rounded,
                      text: "${percentage.toStringAsFixed(0)}%",
                      color: Colors.blueAccent,
                    ),
                    _chip(
                            context: context,
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
    required BuildContext context,
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
              fontFamily: ResponsiveText.fontFamily,
              fontSize: ResponsiveText.small(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(BuildContext context, bool isDark) {
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
            Icons.fact_check_rounded,
            size: 42,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.noAttendanceDataFound,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.w900,
              fontFamily: ResponsiveText.fontFamily,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.noStudentsForCoachCurrentWeek,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondaryText(isDark),
              fontFamily: ResponsiveText.fontFamily,
              fontSize: ResponsiveText.bodySmall(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageCard({
    required BuildContext context,
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
                  fontFamily: ResponsiveText.fontFamily,
                  fontSize: ResponsiveText.title(context),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontFamily: ResponsiveText.fontFamily,
                  fontSize: ResponsiveText.bodySmall(context),
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
