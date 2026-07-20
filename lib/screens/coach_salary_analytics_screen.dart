import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';
import '../core/responsive/responsive_helper.dart';
import '../core/responsive/responsive_padding.dart';
import '../core/responsive/responsive_text.dart';

class CoachSalaryAnalyticsScreen extends StatelessWidget {
  const CoachSalaryAnalyticsScreen({super.key});

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

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString()) ?? 0;
  }

  String _money(int value) {
    return "₹$value";
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
          resizeToAvoidBottomInset: true,
          backgroundColor: _bg(isDark),
          body: SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('coaches')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Column(
                    children: [
                      _topHeader(context, isDark),
                      Expanded(
                        child: _messageCard(
                          isDark: isDark,
                          icon: Icons.error_outline_rounded,
                          title: AppStrings.somethingWentWrong,
                          message: snapshot.error.toString(),
                        ),
                      ),
                    ],
                  );
                }

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

                final coaches = snapshot.data?.docs ?? [];

                int totalExpense = 0;
                int highestSalary = 0;
                String highestCoach = AppStrings.notAvailable;

                final sortedCoaches = coaches.toList();

                for (final doc in coaches) {
                  final data = doc.data() as Map<String, dynamic>;
                  final salary = _toInt(data['salary']);

                  totalExpense += salary;

                  if (salary > highestSalary) {
                    highestSalary = salary;
                    highestCoach = data['name']?.toString() ?? AppStrings.unknownCoach;
                  }
                }

                sortedCoaches.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  return _toInt(bData['salary']).compareTo(_toInt(aData['salary']));
                });

                final averageSalary =
                    coaches.isEmpty ? 0 : (totalExpense / coaches.length).round();

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _topHeader(context, isDark),
                      _heroBanner(
                        context: context,
                        isDark: isDark,
                        totalCoaches: coaches.length,
                        totalExpense: totalExpense,
                        highestSalary: highestSalary,
                        averageSalary: averageSalary,
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsivePadding.horizontal(context),
                        ),
                        child: GridView.count(
                          crossAxisCount: ResponsiveHelper.isTablet(context) ||
                                  ResponsiveHelper.isDesktop(context)
                              ? 4
                              : 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.12,
                          children: [
                            _statCard(
                              isDark: isDark,
                              title: AppStrings.totalCoaches,
                              value: coaches.length.toString(),
                              subtitle: AppStrings.activeRecords,
                              icon: Icons.people_alt_rounded,
                              color: Colors.blueAccent,
                            ),
                            _statCard(
                              isDark: isDark,
                              title: AppStrings.monthlyExpense,
                              value: _money(totalExpense),
                              subtitle: AppStrings.totalSalary,
                              icon: Icons.payments_rounded,
                              color: Colors.green,
                            ),
                            _statCard(
                              isDark: isDark,
                              title: AppStrings.highestSalary,
                              value: _money(highestSalary),
                              subtitle: highestCoach,
                              icon: Icons.workspace_premium_rounded,
                              color: Colors.orange,
                            ),
                            _statCard(
                              isDark: isDark,
                              title: AppStrings.averageSalary,
                              value: _money(averageSalary),
                              subtitle: AppStrings.perCoach,
                              icon: Icons.analytics_rounded,
                              color: Colors.purpleAccent,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      _sectionTitle(AppStrings.coachSalaryRanking.toUpperCase(), isDark),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: sortedCoaches.isEmpty
                            ? _emptyCard(isDark)
                            : Column(
                                children: sortedCoaches.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final doc = entry.value;
                                  final data = doc.data() as Map<String, dynamic>;

                                  final name =
                                      data['name']?.toString() ?? AppStrings.unknownCoach;
                                  final batch = data['batch']?.toString() ?? '';
                                  final salary = _toInt(data['salary']);

                                  return _coachSalaryCard(
                                    isDark: isDark,
                                    rank: index + 1,
                                    name: name,
                                    batch: batch,
                                    salary: salary,
                                    highestSalary: highestSalary,
                                  );
                                }).toList(),
                              ),
                      ),
                      const SizedBox(height: 28),
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
                Text(
                  AppStrings.salaryAnalytics.toUpperCase(),
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
                  AppStrings.coachSalaryExpenseOverview,
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
    required BuildContext context,
    required bool isDark,
    required int totalCoaches,
    required int totalExpense,
    required int highestSalary,
    required int averageSalary,
  }) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final horizontalPadding = ResponsivePadding.horizontal(context);

    return Container(
      height: isMobile ? 215 : 235,
      margin: EdgeInsets.fromLTRB(
        horizontalPadding,
        12,
        horizontalPadding,
        0,
      ),
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
            right: -25,
            bottom: -25,
            child: Icon(
              Icons.payments_rounded,
              color: Colors.white.withOpacity(0.08),
              size: 155,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: isMobile ? 34 : 46,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.payments_rounded,
                    color: maroon,
                    size: isMobile ? 32 : 42,
                  ),
                ),
                SizedBox(width: isMobile ? 10 : 14),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: isMobile ? 205 : 235,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "YGCA",
                            style: TextStyle(
                              color: gold,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            AppStrings.coachLabel.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveText.hero(context),
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          Text(
                            AppStrings.salaryAnalytics.toUpperCase(),
                            style: TextStyle(
                              color: gold,
                              fontSize: ResponsiveText.pageTitle(context),
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _heroChip("${AppStrings.coaches}: $totalCoaches"),
                              _heroChip("${AppStrings.expense}: ${_money(totalExpense)}"),
                              _heroChip("${AppStrings.highest}: ${_money(highestSalary)}"),
                              _heroChip("${AppStrings.averageShort}: ${_money(averageSalary)}"),
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
      constraints: const BoxConstraints(maxWidth: 165),
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
        style: const TextStyle(
          color: gold,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _statCard({
    required bool isDark,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? color.withOpacity(0.35) : _border(isDark),
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
          width: 140,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.16),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 9),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
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

  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? gold : maroon,
              fontSize: 15,
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

  Widget _coachSalaryCard({
    required bool isDark,
    required int rank,
    required String name,
    required String batch,
    required int salary,
    required int highestSalary,
  }) {
    final bool isTop = salary == highestSalary && highestSalary > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isTop
              ? gold.withOpacity(0.75)
              : isDark
                  ? red.withOpacity(0.25)
                  : _border(isDark),
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
            radius: 25,
            backgroundColor: isTop ? gold : maroon,
            child: isTop
                ? const Icon(
                    Icons.workspace_premium_rounded,
                    color: maroon,
                    size: 22,
                  )
                : Text(
                    rank.toString(),
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
                  name.isEmpty ? AppStrings.unknownCoach : name,
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
                if (isTop) ...[
                  const SizedBox(height: 7),
                  _topCoachChip(),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _money(salary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _topCoachChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: gold.withOpacity(0.13),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gold.withOpacity(0.35)),
      ),
      child: Text(
        AppStrings.topPaidCoach,
        style: TextStyle(
          color: gold,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
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
            Icons.sports_cricket_rounded,
            size: 38,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.noCoachesFound,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.coachSalaryRecordsWillAppearHere,
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText(isDark)),
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
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText(isDark),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
