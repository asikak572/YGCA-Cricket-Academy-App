import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  int _amount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.round();

    final cleaned = value
        .toString()
        .replaceAll('₹', '')
        .replaceAll(',', '')
        .trim();

    return double.tryParse(cleaned)?.round() ?? 0;
  }

  String _money(int value) {
    return '₹$value';
  }

  Future<Map<String, dynamic>> _loadStats() async {
    final firestore = FirebaseFirestore.instance;

    final results = await Future.wait([
      firestore.collection('students').get(),
      firestore.collection('fees').get(),
      firestore.collection('attendance').get(),
      firestore.collection('performance_reports').get(),
      firestore.collection('leave_requests').get(),
      firestore.collection('matches').get(),
      firestore.collection('coach_salaries').get(),
    ]);

    final students = results[0];
    final fees = results[1];
    final attendance = results[2];
    final performance = results[3];
    final leaves = results[4];
    final matches = results[5];
    final salaries = results[6];

    int collected = 0;
    int pending = 0;
    int salaryBudget = 0;

    for (final doc in fees.docs) {
      final data = doc.data();
      collected += _amount(data['paidAmount']);
      pending += _amount(data['pendingAmount']);
    }

    for (final doc in salaries.docs) {
      final data = doc.data();
      salaryBudget += _amount(data['salary']);
    }

    return {
      'students': students.docs.length,
      'collected': collected,
      'pending': pending,
      'attendance': attendance.docs.length,
      'performance': performance.docs.length,
      'leaves': leaves.docs.length,
      'matches': matches.docs.length,
      'salaryBudget': salaryBudget,
    };
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
        final isDark = mode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: _bg(isDark),
          body: SafeArea(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _loadStats(),
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
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Text(
                              'Unable to load reports.\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _primaryText(isDark),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                final data = snapshot.data ?? {};

                final students = data['students'] ?? 0;
                final collected = data['collected'] ?? 0;
                final pending = data['pending'] ?? 0;
                final attendance = data['attendance'] ?? 0;
                final performance = data['performance'] ?? 0;
                final leaves = data['leaves'] ?? 0;
                final matches = data['matches'] ?? 0;
                final salaryBudget = data['salaryBudget'] ?? 0;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _topHeader(context, isDark),
                      _heroBanner(
                        isDark: isDark,
                        students: students.toString(),
                        collected: _money(collected),
                        pending: _money(pending),
                      ),
                      const SizedBox(height: 18),
                      _sectionTitle('FINANCE SUMMARY', isDark),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _financeCard(
                                isDark: isDark,
                                title: 'Collected',
                                value: _money(collected),
                                icon: Icons.payments_rounded,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _financeCard(
                                isDark: isDark,
                                title: 'Pending',
                                value: _money(pending),
                                icon: Icons.warning_amber_rounded,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _sectionTitle('REPORT OVERVIEW', isDark),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.25,
                          children: [
                            _reportCard(
                              isDark: isDark,
                              title: 'Students',
                              value: students.toString(),
                              icon: Icons.people_alt_rounded,
                              color: Colors.blueAccent,
                              subtitle: 'Total registered',
                            ),
                            _reportCard(
                              isDark: isDark,
                              title: 'Attendance',
                              value: attendance.toString(),
                              icon: Icons.check_circle_rounded,
                              color: Colors.green,
                              subtitle: 'Records marked',
                            ),
                            _reportCard(
                              isDark: isDark,
                              title: 'Performance',
                              value: performance.toString(),
                              icon: Icons.bar_chart_rounded,
                              color: Colors.purpleAccent,
                              subtitle: 'Reports synced',
                            ),
                            _reportCard(
                              isDark: isDark,
                              title: 'Leave Requests',
                              value: leaves.toString(),
                              icon: Icons.event_note_rounded,
                              color: Colors.orange,
                              subtitle: 'Requests received',
                            ),
                            _reportCard(
                              isDark: isDark,
                              title: 'Matches',
                              value: matches.toString(),
                              icon: Icons.sports_cricket_rounded,
                              color: Colors.redAccent,
                              subtitle: 'Scheduled matches',
                            ),
                            _reportCard(
                              isDark: isDark,
                              title: 'Salary Budget',
                              value: _money(salaryBudget),
                              icon: Icons.account_balance_wallet_rounded,
                              color: Colors.brown,
                              subtitle: 'Coach salaries',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _insightCard(
                          isDark: isDark,
                          collected: collected,
                          pending: pending,
                          salaryBudget: salaryBudget,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _miniSummary(
                        isDark: isDark,
                        attendance: attendance,
                        performance: performance,
                        leaves: leaves,
                        matches: matches,
                      ),
                      const SizedBox(height: 22),
                      _footer(isDark),
                      const SizedBox(height: 26),
                    ],
                  ),
                );
              },
            ),
          ),
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
                  'REPORTS DASHBOARD',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Academy insights and summary',
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
              color:
                  isDark ? red.withOpacity(0.12) : Colors.black.withOpacity(0.08),
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
    required String students,
    required String collected,
    required String pending,
  }) {
    return Container(
      height: 230,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? red.withOpacity(0.55) : gold.withOpacity(0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.22) : maroon.withOpacity(0.18),
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
                          maroon.withOpacity(0.70),
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
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.analytics_rounded,
                    color: maroon,
                    size: 42,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 240,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACADEMY',
                            style: TextStyle(
                              color: gold,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          const Text(
                            'REPORTS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 31,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          Text(
                            'DASHBOARD',
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
                              _heroChip('Students: $students'),
                              _heroChip('Collected: $collected'),
                              _heroChip('Pending: $pending'),
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
      constraints: const BoxConstraints(maxWidth: 220),
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

  Widget _financeCard({
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(14),
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
        border: Border.all(
          color: isDark ? red.withOpacity(0.30) : gold.withOpacity(0.65),
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                isDark ? color.withOpacity(0.12) : Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
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
                backgroundColor: color.withOpacity(0.16),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reportCard({
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card(isDark),
        border: Border.all(color: _border(isDark)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.30)
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
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _insightCard({
    required bool isDark,
    required int collected,
    required int pending,
    required int salaryBudget,
  }) {
    final total = collected + pending;
    final collectionPercent = total == 0 ? 0 : ((collected / total) * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF180808),
                  const Color(0xFF0F0F0F),
                  red.withOpacity(0.18),
                ]
              : [
                  maroon,
                  red.withOpacity(0.85),
                  darkMaroon,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: red.withOpacity(0.16),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.insights_rounded, color: gold, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COLLECTION INSIGHT',
                  style: TextStyle(
                    color: gold,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Fee collection is $collectionPercent%. Salary budget is ${_money(salaryBudget)}.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniSummary({
    required bool isDark,
    required int attendance,
    required int performance,
    required int leaves,
    required int matches,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        children: [
          _miniRow(
            isDark: isDark,
            icon: Icons.check_circle_rounded,
            title: 'Attendance records',
            value: attendance.toString(),
            color: Colors.green,
          ),
          _miniRow(
            isDark: isDark,
            icon: Icons.bar_chart_rounded,
            title: 'Performance reports',
            value: performance.toString(),
            color: Colors.purpleAccent,
          ),
          _miniRow(
            isDark: isDark,
            icon: Icons.event_note_rounded,
            title: 'Leave requests',
            value: leaves.toString(),
            color: Colors.orange,
          ),
          _miniRow(
            isDark: isDark,
            icon: Icons.sports_cricket_rounded,
            title: 'Matches scheduled',
            value: matches.toString(),
            color: Colors.redAccent,
            last: true,
          ),
        ],
      ),
    );
  }

  Widget _miniRow({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool last = false,
  }) {
    return Container(
      padding: EdgeInsets.only(bottom: last ? 0 : 10, top: last ? 8 : 0),
      decoration: BoxDecoration(
        border: Border(
          bottom: last
              ? BorderSide.none
              : BorderSide(color: _border(isDark), width: 0.8),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.16),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: _primaryText(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDark ? gold : maroon,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  maroon,
                  darkMaroon,
                  Colors.black,
                ]
              : [
                  maroon,
                  red.withOpacity(0.85),
                  darkMaroon,
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gold.withOpacity(0.7), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _footerItem(Icons.favorite_rounded, 'Passion'),
          _footerItem(Icons.star_rounded, 'Discipline'),
          _footerItem(Icons.emoji_events_rounded, 'Success'),
        ],
      ),
    );
  }

  Widget _footerItem(IconData icon, String title) {
    return Column(
      children: [
        Icon(icon, color: gold, size: 25),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
