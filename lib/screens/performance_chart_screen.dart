import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';
import '../core/responsive/responsive_helper.dart';
import '../core/responsive/responsive_padding.dart';

class PerformanceChartScreen extends StatefulWidget {
  const PerformanceChartScreen({super.key});

  @override
  State<PerformanceChartScreen> createState() => _PerformanceChartScreenState();
}

class _PerformanceChartScreenState extends State<PerformanceChartScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  String role = '';
  String uid = '';
  String email = '';
  bool userLoaded = false;

  List<String> assignedBatches = [];
  List<String> linkedChildrenIds = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  Future<void> _loadUserData() async {
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

    final coachBatches = _listFromDynamic(data['assignedBatches']);

    final oldBatch = _text(data['assignedBatch']).isNotEmpty
        ? _text(data['assignedBatch'])
        : _text(data['batch']);

    if (oldBatch.isNotEmpty && !coachBatches.contains(oldBatch)) {
      coachBatches.add(oldBatch);
    }

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
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  double _average(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, String key) {
    if (docs.isEmpty) return 0;

    int total = 0;

    for (final doc in docs) {
      total += _toInt(doc.data()[key]);
    }

    return total / docs.length;
  }

  String _topPerformer(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    if (docs.isEmpty) return AppStrings.noData;

    String topName = AppStrings.noData;
    double topScore = -1;

    for (final doc in docs) {
      final data = doc.data();

      final batting = _toInt(data['batting']);
      final bowling = _toInt(data['bowling']);
      final fielding = _toInt(data['fielding']);
      final fitness = _toInt(data['fitness']);

      final avg = (batting + bowling + fielding + fitness) / 4;

      if (avg > topScore) {
        topScore = avg;
        topName = _text(data['studentName']).isNotEmpty
            ? _text(data['studentName'])
            : _text(data['name']).isNotEmpty
                ? _text(data['name'])
                : AppStrings.unknown;
      }
    }

    return topName;
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortedDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final sorted = docs.toList();

    sorted.sort((a, b) {
      final aTime = a.data()['createdAt'];
      final bTime = b.data()['createdAt'];

      if (aTime is Timestamp && bTime is Timestamp) {
        return bTime.compareTo(aTime);
      }

      return 0;
    });

    return sorted;
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _topFivePlayers(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final sorted = docs.toList();

    sorted.sort((a, b) {
      final aData = a.data();
      final bData = b.data();

      final aAvg = (
            _toInt(aData['batting']) +
            _toInt(aData['bowling']) +
            _toInt(aData['fielding']) +
            _toInt(aData['fitness'])
          ) /
          4;

      final bAvg = (
            _toInt(bData['batting']) +
            _toInt(bData['bowling']) +
            _toInt(bData['fielding']) +
            _toInt(bData['fitness'])
          ) /
          4;

      return bAvg.compareTo(aAvg);
    });

    return sorted.take(5).toList();
  }

  String _ratingText(int avg) {
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
                      _topBar(context, isDark),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  )
                : role == 'Coach' && assignedBatches.isEmpty
                    ? Column(
                        children: [
                          _topBar(context, isDark),
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
                                _topBar(context, isDark),
                                Expanded(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Text(
                                        "${AppStrings.error}: ${snapshot.error}",
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
                                _topBar(context, isDark),
                                const Expanded(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ],
                            );
                          }

                          final docs = _sortedDocs(snapshot.data?.docs ?? []);

                          final battingAvg = _average(docs, 'batting');
                          final bowlingAvg = _average(docs, 'bowling');
                          final fieldingAvg = _average(docs, 'fielding');
                          final fitnessAvg = _average(docs, 'fitness');

                          final topPlayer = _topPerformer(docs);
                          final topDocs = _topFivePlayers(docs);

                          return SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              ResponsivePadding.horizontal(context),
                              0,
                              ResponsivePadding.horizontal(context),
                              24,
                            ),
                            child: Column(
                              children: [
                                _topBar(context, isDark),
                                _heroCard(
                                  isDark: isDark,
                                  totalReports: docs.length,
                                  topPlayer: topPlayer,
                                ),
                                const SizedBox(height: 14),
                                _cricHeroesInfoCard(isDark),
                                const SizedBox(height: 16),
                                _summaryGrid(
                                  isDark: isDark,
                                  batting: battingAvg,
                                  bowling: bowlingAvg,
                                  fielding: fieldingAvg,
                                  fitness: fitnessAvg,
                                ),
                                const SizedBox(height: 18),
                                _sectionTitle(AppStrings.skillAverageChart, isDark),
                                _barChart(
                                  isDark: isDark,
                                  batting: battingAvg,
                                  bowling: bowlingAvg,
                                  fielding: fieldingAvg,
                                  fitness: fitnessAvg,
                                ),
                                const SizedBox(height: 18),
                                _sectionTitle(AppStrings.topPerformers, isDark),
                                docs.isEmpty
                                    ? _emptyCard(isDark)
                                    : Column(
                                        children: topDocs.map((doc) {
                                          final data = doc.data();

                                          final name =
                                              _text(data['studentName'])
                                                      .isNotEmpty
                                                  ? _text(data['studentName'])
                                                  : _text(data['name'])
                                                          .isNotEmpty
                                                      ? _text(data['name'])
                                                      : AppStrings.unknown;

                                          final batting = _toInt(data['batting']);
                                          final bowling = _toInt(data['bowling']);
                                          final fielding =
                                              _toInt(data['fielding']);
                                          final fitness = _toInt(data['fitness']);

                                          final avg =
                                              ((batting + bowling + fielding + fitness) /
                                                      4)
                                                  .round();

                                          final rating = _ratingText(avg);

                                          return _topPlayerTile(
                                            isDark: isDark,
                                            name: name,
                                            avg: avg,
                                            batch: _text(data['batch']),
                                            rating: rating,
                                            ratingColor: _ratingColor(rating),
                                          );
                                        }).toList(),
                                      ),
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

  Widget _topBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
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
                    AppStrings.analytics.toUpperCase(),
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
                  AppStrings.performanceInsightCenter,
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

  Widget _heroCard({
    required bool isDark,
    required int totalReports,
    required String topPlayer,
  }) {
    return Container(
      height: 215,
      width: double.infinity,
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
            right: -24,
            bottom: -24,
            child: Icon(
              Icons.insights_rounded,
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
                    Icons.insights_rounded,
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
                      width: 235,
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
                            AppStrings.analytics.toUpperCase(),
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
                              _heroChip("${AppStrings.top}: $topPlayer"),
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
      constraints: const BoxConstraints(maxWidth: 210),
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
      width: double.infinity,
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
              AppStrings.analyticsViewOnlyCricHeroesLater,
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

  Widget _summaryGrid({
    required bool isDark,
    required double batting,
    required double bowling,
    required double fielding,
    required double fitness,
  }) {
    return GridView.count(
      crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio:
          ResponsiveHelper.isMobile(context) ? 1.22 : 1.10,
      children: [
        _statCard(
          isDark: isDark,
          title: AppStrings.battingAverage,
          value: batting.round().toString(),
          icon: Icons.sports_cricket_rounded,
          color: Colors.green,
        ),
        _statCard(
          isDark: isDark,
          title: AppStrings.bowlingAverage,
          value: bowling.round().toString(),
          icon: Icons.sports_baseball_rounded,
          color: Colors.blueAccent,
        ),
        _statCard(
          isDark: isDark,
          title: AppStrings.fieldingAverage,
          value: fielding.round().toString(),
          icon: Icons.sports_handball_rounded,
          color: Colors.orange,
        ),
        _statCard(
          isDark: isDark,
          title: AppStrings.fitnessAverage,
          value: fitness.round().toString(),
          icon: Icons.fitness_center_rounded,
          color: Colors.purpleAccent,
        ),
      ],
    );
  }

  Widget _statCard({
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
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
                  color.withOpacity(0.16),
                ]
              : [
                  Colors.white,
                  const Color(0xFFFFFBF2),
                  color.withOpacity(0.08),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? red.withOpacity(0.30) : gold.withOpacity(0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? color.withOpacity(0.10)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 135,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.18),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                "$value%",
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

  Widget _barChart({
    required bool isDark,
    required double batting,
    required double bowling,
    required double fielding,
    required double fitness,
  }) {
    return Container(
      height: 285,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : _border(isDark),
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: BarChart(
        BarChartData(
          maxY: 100,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: _secondaryText(isDark),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  String title = "";

                  switch (value.toInt()) {
                    case 0:
                      title = AppStrings.batShort;
                      break;
                    case 1:
                      title = AppStrings.bowlShort;
                      break;
                    case 2:
                      title = AppStrings.fieldShort;
                      break;
                    case 3:
                      title = AppStrings.fitShort;
                      break;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      title,
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            _bar(0, batting, Colors.green),
            _bar(1, bowling, Colors.blueAccent),
            _bar(2, fielding, Colors.orange),
            _bar(3, fitness, Colors.purpleAccent),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y.clamp(0, 100).toDouble(),
          color: color,
          width: 24,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  Widget _topPlayerTile({
    required bool isDark,
    required String name,
    required int avg,
    required String batch,
    required String rating,
    required Color ratingColor,
  }) {
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
            radius: 25,
            backgroundColor: maroon,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
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
                const SizedBox(height: 4),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$avg%",
                style: TextStyle(
                  color: isDark ? gold : maroon,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ratingColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ratingColor.withOpacity(0.25)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    rating,
                    maxLines: 1,
                    style: TextStyle(
                      color: ratingColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 2),
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
            AppStrings.noPerformanceRecordsAvailable,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.analyticsDataSyncCricHeroesLater,
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
