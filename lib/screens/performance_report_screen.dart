import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';

import 'performance_chart_screen.dart';

class PerformanceReportScreen extends StatefulWidget {
  const PerformanceReportScreen({super.key});

  @override
  State<PerformanceReportScreen> createState() =>
      _PerformanceReportScreenState();
}

class _PerformanceReportScreenState extends State<PerformanceReportScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  String role = '';
  String uid = '';
  String email = '';
  bool userLoaded = false;

  List<String> linkedChildrenIds = [];
  List<String> assignedBatches = [];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  String _text(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String _lower(String value) {
    return value.trim().toLowerCase();
  }

  List<String> _listFromDynamic(dynamic value) {
    final result = <String>[];

    if (value is List) {
      for (final item in value) {
        final text = _text(item);
        if (text.isNotEmpty) {
          result.add(text);
        }
      }
    }

    return result;
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

  Future<List<String>> _loadCoachCurrentWeekAssignments(
    String coachUid,
  ) async {
    final weekId = _dateId(_startOfWeek(DateTime.now()));

    final snapshot = await FirebaseFirestore.instance
        .collection('coach_session_assignments')
        .where('weekStartDate', isEqualTo: weekId)
        .get();

    final sessions = <String>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final assignedCoachId = _text(data['coachId']);
      final status = _lower(_text(data['status']));
      final session = _text(data['session']);
      final batch = _text(data['batch']);
      final value = session.isNotEmpty ? session : batch;

      if (assignedCoachId == coachUid &&
          status == 'active' &&
          value.isNotEmpty &&
          !sessions.contains(value)) {
        sessions.add(value);
      }
    }

    return sessions;
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() => userLoaded = true);
      return;
    }

    uid = user.uid;
    email = _lower(user.email ?? '');

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!userDoc.exists) {
      if (!mounted) return;
      setState(() => userLoaded = true);
      return;
    }

    final data = userDoc.data() ?? {};
    final loadedRole = _text(data['role']);

    final coachBatches = loadedRole == 'Coach'
        ? await _loadCoachCurrentWeekAssignments(uid)
        : <String>[];

    final children = _listFromDynamic(data['linkedChildrenIds']);

    final childId = _text(data['childId']);
    if (childId.isNotEmpty && !children.contains(childId)) {
      children.add(childId);
    }

    final parentEmail = _lower(
      _text(data['email']).isNotEmpty ? _text(data['email']) : email,
    );

    if (loadedRole == 'Parent' && parentEmail.isNotEmpty) {
      final childByEmailLower = await FirebaseFirestore.instance
          .collection('students')
          .where('parentEmailLower', isEqualTo: parentEmail)
          .get();

      for (final doc in childByEmailLower.docs) {
        if (!children.contains(doc.id)) {
          children.add(doc.id);
        }
      }

      final childByEmail = await FirebaseFirestore.instance
          .collection('students')
          .where('parentEmail', isEqualTo: parentEmail)
          .get();

      for (final doc in childByEmail.docs) {
        if (!children.contains(doc.id)) {
          children.add(doc.id);
        }
      }
    }

    if (!mounted) return;

    setState(() {
      role = loadedRole;
      assignedBatches = coachBatches;
      linkedChildrenIds = children;
      userLoaded = true;
    });
  }

  Query<Map<String, dynamic>> _performanceQuery() {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('performance_reports');

    if (role == 'Admin') {
      return query;
    }

    if (role == 'Coach') {
      final batches = assignedBatches.take(10).toList();

      if (batches.isEmpty) {
        return query.where('batch', isEqualTo: 'NO_BATCH');
      }

      if (batches.length == 1) {
        return query.where('batch', isEqualTo: batches.first);
      }

      return query.where('batch', whereIn: batches);
    }

    if (role == 'Student') {
      return query.where('studentId', isEqualTo: uid);
    }

    if (role == 'Parent') {
      final children = linkedChildrenIds.take(10).toList();

      if (children.isEmpty) {
        return query.where('studentId', isEqualTo: 'NO_CHILD');
      }

      if (children.length == 1) {
        return query.where('studentId', isEqualTo: children.first);
      }

      return query.where('studentId', whereIn: children);
    }

    return query.where('studentId', isEqualTo: 'NO_ACCESS');
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  String _ratingText(int batting, int bowling, int fielding, int fitness) {
    final avg = ((batting + bowling + fielding + fitness) / 4).round();

    if (avg >= 90) return AppStrings.elite.toUpperCase();
    if (avg >= 75) return AppStrings.excellent.toUpperCase();
    if (avg >= 60) return AppStrings.good.toUpperCase();
    if (avg >= 40) return AppStrings.average.toUpperCase();
    return AppStrings.needsWork.toUpperCase();
  }

  Color _ratingColor(String rating) {
    if (rating == AppStrings.elite.toUpperCase()) {
      return Colors.purpleAccent;
    }
    if (rating == AppStrings.excellent.toUpperCase()) {
      return Colors.green;
    }
    if (rating == AppStrings.good.toUpperCase()) {
      return Colors.blueAccent;
    }
    if (rating == AppStrings.average.toUpperCase()) {
      return Colors.orange;
    }
    return Colors.redAccent;
  }

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

  void _openAnalytics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PerformanceChartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<String>(
          valueListenable: ThemeController.language,
          builder: (context, language, __) {
            final isDark = mode == ThemeMode.dark;

            return Scaffold(
          backgroundColor: _bg(isDark),
          body: SafeArea(
            child: !userLoaded
                ? Column(
                    children: [
                      _topHeader(context, isDark),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  )
                : role.isEmpty
                    ? Column(
                        children: [
                          _topHeader(context, isDark),
                          Expanded(
                            child: _messageCard(
                              isDark,
                              AppStrings.noUserLoggedIn,
                              Icons.lock_outline_rounded,
                            ),
                          ),
                        ],
                      )
                    : role == 'Coach' && assignedBatches.isEmpty
                    ? Column(
                        children: [
                          _topHeader(context, isDark),
                          Expanded(
                            child: _messageCard(
                              isDark,
                              AppStrings.noBatchAssignedToCoach,
                              Icons.groups_2_outlined,
                            ),
                          ),
                        ],
                      )
                    : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _performanceQuery().snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Column(
                              children: [
                                _topHeader(context, isDark),
                                Expanded(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Text(
                                        snapshot.error.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Column(
                              children: [
                                _topHeader(context, isDark),
                                const Expanded(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ],
                            );
                          }

                          final reports = (snapshot.data?.docs ?? []).toList();

                          reports.sort((a, b) {
                            final aData = a.data();
                            final bData = b.data();

                            final aTime = aData['createdAt'];
                            final bTime = bData['createdAt'];

                            if (aTime is Timestamp && bTime is Timestamp) {
                              return bTime.compareTo(aTime);
                            }

                            return 0;
                          });

                          int excellent = 0;
                          int good = 0;
                          int needsWork = 0;

                          for (final doc in reports) {
                            final data = doc.data();

                            final rating = _ratingText(
                              _toInt(data['batting']),
                              _toInt(data['bowling']),
                              _toInt(data['fielding']),
                              _toInt(data['fitness']),
                            );

                            if (rating == AppStrings.elite.toUpperCase() ||
                                rating == AppStrings.excellent.toUpperCase()) {
                              excellent++;
                            } else if (rating ==
                                AppStrings.good.toUpperCase()) {
                              good++;
                            } else {
                              needsWork++;
                            }
                          }

                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                _topHeader(context, isDark),
                                _heroBanner(
                                  isDark: isDark,
                                  totalReports: reports.length,
                                  excellent: excellent,
                                  good: good,
                                  needsWork: needsWork,
                                ),
                                const SizedBox(height: 14),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            isDark ? red : maroon,
                                        foregroundColor:
                                            isDark ? Colors.white : gold,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      onPressed: () => _openAnalytics(context),
                                      icon: const Icon(
                                        Icons.analytics_rounded,
                                      ),
                                      label: Text(
                                        AppStrings.viewPerformanceAnalytics,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _cricHeroesInfoCard(isDark),
                                const SizedBox(height: 18),
                                _sectionTitle(AppStrings.performanceReportsTitle, isDark),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: reports.isEmpty
                                      ? _emptyCard(isDark)
                                      : Column(
                                          children: reports.map((doc) {
                                            final data = doc.data();

                                            final name =
                                                _text(data['studentName'])
                                                        .isNotEmpty
                                                    ? _text(
                                                        data['studentName'],
                                                      )
                                                    : _text(data['name'])
                                                            .isNotEmpty
                                                        ? _text(data['name'])
                                                        : AppStrings.unknownStudent;

                                            final batch = _text(data['batch']);

                                            final batting =
                                                _toInt(data['batting']);
                                            final bowling =
                                                _toInt(data['bowling']);
                                            final fielding =
                                                _toInt(data['fielding']);
                                            final fitness =
                                                _toInt(data['fitness']);

                                            final remarks =
                                                _text(data['remarks']);

                                            final rating = _ratingText(
                                              batting,
                                              bowling,
                                              fielding,
                                              fitness,
                                            );

                                            final ratingColor =
                                                _ratingColor(rating);

                                            return _performanceCard(
                                              isDark: isDark,
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
                                const SizedBox(height: 30),
                              ],
                            ),
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.performance.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Text(
                  AppStrings.reportsPlayerAnalytics,
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
                icon: dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
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
    required int totalReports,
    required int excellent,
    required int good,
    required int needsWork,
  }) {
    return Container(
      height: 225,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? red.withOpacity(0.55) : gold.withOpacity(0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.20) : maroon.withOpacity(0.16),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
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
                  colors: isDark
                      ? [
                          Colors.black.withOpacity(0.90),
                          darkMaroon.withOpacity(0.88),
                          red.withOpacity(0.35),
                        ]
                      : [
                          maroon.withOpacity(0.92),
                          maroon.withOpacity(0.72),
                          Colors.black.withOpacity(0.25),
                        ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Positioned(
            right: -22,
            bottom: -22,
            child: Icon(
              Icons.emoji_events_rounded,
              color: Colors.white.withOpacity(0.08),
              size: 150,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: maroon,
                    size: 42,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 230,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.cricHeroes.toUpperCase(),
                            style: TextStyle(
                              color: gold,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            AppStrings.performance.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          Text(
                            AppStrings.center.toUpperCase(),
                            style: TextStyle(
                              color: gold,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _heroChip("${AppStrings.reports}: $totalReports"),
                              _heroChip("${AppStrings.excellent}: $excellent"),
                              _heroChip("${AppStrings.good}: $good"),
                              _heroChip("${AppStrings.needsWork}: $needsWork"),
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
    );
  }

  Widget _heroChip(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
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

  Widget _cricHeroesInfoCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? gold.withOpacity(0.45) : gold.withOpacity(0.75),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.sync_rounded,
            color: isDark ? gold : maroon,
            size: 26,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.performanceReportsViewOnlyCricHeroesLater,
              style: TextStyle(
                color: _secondaryText(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
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
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? gold : maroon,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
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

  Widget _performanceCard({
    required bool isDark,
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
        color: _card(isDark),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : _border(isDark),
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.28)
                : Colors.black.withOpacity(0.04),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
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
                  style: const TextStyle(
                    color: gold,
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
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      batch.isEmpty ? AppStrings.noBatch : batch,
                      maxLines: 1,
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
              _ratingChip(rating, ratingColor),
            ],
          ),
          const SizedBox(height: 16),
          _skillBar(isDark, AppStrings.batting, batting, Colors.green),
          _skillBar(isDark, AppStrings.bowling, bowling, Colors.blue),
          _skillBar(isDark, AppStrings.fielding, fielding, Colors.orange),
          _skillBar(isDark, AppStrings.fitness, fitness, Colors.purpleAccent),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF180808) : const Color(0xFFFFFBF2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? gold.withOpacity(0.35)
                    : const Color(0xFFFDE68A),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.rate_review_rounded, color: gold, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    remarks.isEmpty
                        ? AppStrings.coachRemarksNoRemarks
                        : "${AppStrings.coachRemarks}: $remarks",
                    style: TextStyle(
                      color: _primaryText(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          rating,
          maxLines: 1,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _skillBar(bool isDark, String title, int value, Color color) {
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
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                "$safeValue%",
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: safeValue / 100,
              backgroundColor:
                  isDark ? Colors.white12 : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 38,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.noPerformanceReportsFound,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.performanceDataSyncCricHeroesLater,
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText(isDark)),
          ),
        ],
      ),
    );
  }

  Widget _messageCard(bool isDark, String message, IconData icon) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _card(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border(isDark)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _secondaryText(isDark), size: 42),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}