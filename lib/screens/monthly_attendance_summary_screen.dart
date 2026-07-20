import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';
import '../core/responsive/responsive_helper.dart';
import '../core/responsive/responsive_padding.dart';

class MonthlyAttendanceSummaryScreen extends StatefulWidget {
  const MonthlyAttendanceSummaryScreen({super.key});

  @override
  State<MonthlyAttendanceSummaryScreen> createState() =>
      _MonthlyAttendanceSummaryScreenState();
}

class _MonthlyAttendanceSummaryScreenState
    extends State<MonthlyAttendanceSummaryScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color gold = Color(0xFFD4AF37);

  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

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

  String _text(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  DateTime? _toDate(dynamic value) {
    try {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    } catch (_) {
      return null;
    }
  }

  String get _language =>
      ThemeController.language.value.trim().toLowerCase();

  bool get _isTamil =>
      _language.startsWith('ta') ||
      _language.contains('tamil') ||
      _language.contains('தமிழ்');

  bool get _isHindi =>
      _language.startsWith('hi') ||
      _language.contains('hindi') ||
      _language.contains('हिन्दी') ||
      _language.contains('हिंदी');

  String _monthName(int month) {
    const englishMonths = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    const tamilMonths = [
      "ஜனவரி",
      "பிப்ரவரி",
      "மார்ச்",
      "ஏப்ரல்",
      "மே",
      "ஜூன்",
      "ஜூலை",
      "ஆகஸ்ட்",
      "செப்டம்பர்",
      "அக்டோபர்",
      "நவம்பர்",
      "டிசம்பர்",
    ];

    const hindiMonths = [
      "जनवरी",
      "फ़रवरी",
      "मार्च",
      "अप्रैल",
      "मई",
      "जून",
      "जुलाई",
      "अगस्त",
      "सितंबर",
      "अक्टूबर",
      "नवंबर",
      "दिसंबर",
    ];

    final months = _isTamil
        ? tamilMonths
        : _isHindi
            ? hindiMonths
            : englishMonths;

    return months[month - 1];
  }

  String get _dayWiseRecordsLabel {
    if (_isTamil) return "நாள் வாரியான பதிவுகள்";
    if (_isHindi) return "दिनवार रिकॉर्ड";
    return "DAY WISE RECORDS";
  }

  void _previousMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    });
  }

  bool _isSameSelectedMonth(DateTime date) {
    return date.year == selectedMonth.year && date.month == selectedMonth.month;
  }

  Query<Map<String, dynamic>> _attendanceQuery() {
    return FirebaseFirestore.instance.collection('attendance');
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterCurrentMonthDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs.where((doc) {
      final data = doc.data();

      final date = _toDate(data['date']) ??
          _toDate(data['createdAt']) ??
          _toDate(data['attendanceDate']);

      if (date == null) return false;

      return _isSameSelectedMonth(date);
    }).toList();
  }

  Map<String, int> _buildDayWiseCount(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final Map<String, int> counts = {};

    for (final doc in docs) {
      final data = doc.data();

      final date = _toDate(data['date']) ??
          _toDate(data['createdAt']) ??
          _toDate(data['attendanceDate']);

      if (date == null) continue;

      final key =
          "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";

      counts[key] = (counts[key] ?? 0) + 1;
    }

    return counts;
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
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _attendanceQuery().snapshots(),
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

                final allDocs = snapshot.data?.docs ?? [];
                final monthDocs = _filterCurrentMonthDocs(allDocs);

                int present = 0;
                int absent = 0;
                int leave = 0;
                int makeup = 0;
                int cancelled = 0;

                for (final doc in monthDocs) {
                  final data = doc.data();
                  final status = _text(data['status']).toLowerCase();

                  if (status == 'present' || status == 'p') {
                    present++;
                  } else if (status == 'absent' || status == 'a') {
                    absent++;
                  } else if (status == 'leave' || status == 'l') {
                    leave++;
                  } else if (status == 'makeup' || status == 'm') {
                    makeup++;
                  } else if (status == 'cancelled' || status == 'c') {
                    cancelled++;
                  }
                }

                final total = present + absent + leave + makeup + cancelled;
                final percentage =
                    total == 0 ? 0.0 : (present / total) * 100;

                final dayWise = _buildDayWiseCount(monthDocs);

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _topHeader(context, isDark)),
                    SliverToBoxAdapter(
                      child: _monthSelector(isDark),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 14)),
                    SliverToBoxAdapter(
                      child: _summaryHeader(
                        isDark: isDark,
                        total: total,
                        present: present,
                        absent: absent,
                        leave: leave,
                        percentage: percentage,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    SliverToBoxAdapter(
                      child: _sectionTitle(
                        AppStrings.monthlySummary.toUpperCase(),
                        isDark,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsivePadding.horizontal(context),
                        ),
                        child: _summaryGrid(
                          isDark: isDark,
                          present: present,
                          absent: absent,
                          leave: leave,
                          makeup: makeup,
                          cancelled: cancelled,
                          total: total,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    SliverToBoxAdapter(
                      child: _sectionTitle(
                        _dayWiseRecordsLabel.toUpperCase(),
                        isDark,
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsivePadding.horizontal(context),
                      ),
                      sliver: dayWise.isEmpty
                          ? SliverToBoxAdapter(child: _emptyCard(isDark))
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final keys = dayWise.keys.toList();
                                  final key = keys[index];
                                  final count = dayWise[key] ?? 0;

                                  return _dayCard(
                                    isDark: isDark,
                                    date: key,
                                    count: count,
                                  );
                                },
                                childCount: dayWise.length,
                              ),
                            ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
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
                  AppStrings.monthlySummary.toUpperCase(),
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
                  "${AppStrings.monthlySummary} • ${AppStrings.attendance}",
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

  Widget _monthSelector(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : _border(isDark),
        ),
      ),
      child: Row(
        children: [
          _smallIconButton(
            isDark: isDark,
            icon: Icons.chevron_left_rounded,
            onTap: _previousMonth,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  "${_monthName(selectedMonth.month)} ${selectedMonth.year}",
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  AppStrings.tapArrowsChangeMonth,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _smallIconButton(
            isDark: isDark,
            icon: Icons.chevron_right_rounded,
            onTap: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _smallIconButton({
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF171717) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _border(isDark)),
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : maroon,
          size: 25,
        ),
      ),
    );
  }

  Widget _summaryHeader({
    required bool isDark,
    required int total,
    required int present,
    required int absent,
    required int leave,
    required double percentage,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsivePadding.horizontal(context),
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF130202),
                  const Color(0xFF1A0505),
                  red.withOpacity(0.18),
                ]
              : [
                  Colors.white,
                  const Color(0xFFFFFBF2),
                  gold.withOpacity(0.20),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? red.withOpacity(0.30) : gold.withOpacity(0.75),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: maroon,
            child: const Icon(
              Icons.calendar_view_month_rounded,
              color: gold,
              size: 31,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${AppStrings.monthlySummary} ${AppStrings.attendance}",
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${AppStrings.total} ${AppStrings.records}: $total • ${AppStrings.present}: $present • ${AppStrings.absent}: $absent • ${AppStrings.leave}: $leave",
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 8,
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.10)
                        : Colors.black.withOpacity(0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage >= 80 ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${percentage.toStringAsFixed(0)}% attendance",
                  style: TextStyle(
                    color: percentage >= 80 ? Colors.green : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryGrid({
    required bool isDark,
    required int present,
    required int absent,
    required int leave,
    required int makeup,
    required int cancelled,
    required int total,
  }) {
    return GridView.count(
      crossAxisCount: ResponsiveHelper.isDesktop(context)
          ? 6
          : ResponsiveHelper.isTablet(context)
              ? 3
              : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: ResponsiveHelper.isDesktop(context) ? 1.25 : 1.45,
      children: [
        _summaryCard(
          isDark: isDark,
          icon: Icons.check_circle_rounded,
          title: AppStrings.present,
          value: present.toString(),
          color: Colors.green,
        ),
        _summaryCard(
          isDark: isDark,
          icon: Icons.cancel_rounded,
          title: AppStrings.absent,
          value: absent.toString(),
          color: Colors.redAccent,
        ),
        _summaryCard(
          isDark: isDark,
          icon: Icons.event_busy_rounded,
          title: AppStrings.leave,
          value: leave.toString(),
          color: Colors.orange,
        ),
        _summaryCard(
          isDark: isDark,
          icon: Icons.event_repeat_rounded,
          title: AppStrings.makeup,
          value: makeup.toString(),
          color: Colors.teal,
        ),
        _summaryCard(
          isDark: isDark,
          icon: Icons.block_rounded,
          title: AppStrings.cancelled,
          value: cancelled.toString(),
          color: Colors.deepOrange,
        ),
        _summaryCard(
          isDark: isDark,
          icon: Icons.receipt_long_rounded,
          title: AppStrings.total,
          value: total.toString(),
          color: Colors.blueAccent,
        ),
      ],
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

  Widget _dayCard({
    required bool isDark,
    required String date,
    required int count,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            child: const Icon(
              Icons.calendar_today_rounded,
              color: gold,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              date,
              style: TextStyle(
                color: _primaryText(isDark),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(isDark ? 0.14 : 0.09),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.blueAccent.withOpacity(0.25),
              ),
            ),
            child: Text(
              "$count ${AppStrings.records}",
              style: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_view_month_rounded,
            size: 42,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.noAttendanceRecordsFound,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.noAttendanceDataAvailable,
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText(isDark)),
          ),
        ],
      ),
    );
  }
}
