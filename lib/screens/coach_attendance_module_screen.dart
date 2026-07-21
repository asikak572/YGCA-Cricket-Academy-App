import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';
import '../core/responsive/responsive_text.dart';
import '../core/responsive/responsive_helper.dart';
import '../core/responsive/responsive_padding.dart';
import '../core/responsive/responsive_spacing.dart';

import 'attendance_screen.dart';
import 'attendance_history_screen.dart';
import 'attendance_calendar_screen.dart';

class CoachAttendanceModuleScreen extends StatefulWidget {
  const CoachAttendanceModuleScreen({super.key});

  @override
  State<CoachAttendanceModuleScreen> createState() =>
      _CoachAttendanceModuleScreenState();
}

class _CoachAttendanceModuleScreenState
    extends State<CoachAttendanceModuleScreen> {
  int _currentIndex = 0;

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

  String get _title {
    switch (_currentIndex) {
      case 0:
        return AppStrings.attendance;
      case 1:
        return AppStrings.records;
      case 2:
        return AppStrings.calendar;
      default:
        return AppStrings.attendance;
    }
  }

  String get _subtitle {
    switch (_currentIndex) {
      case 0:
        return AppStrings.coachAttendanceTodaySubtitle;
      case 1:
        return AppStrings.coachAttendanceHistorySubtitle;
      case 2:
        return AppStrings.coachAttendanceCalendarSubtitle;
      default:
        return "";
    }
  }

  IconData get _headerIcon {
    switch (_currentIndex) {
      case 0:
        return Icons.fact_check_rounded;
      case 1:
        return Icons.history_rounded;
      case 2:
        return Icons.calendar_month_rounded;
      default:
        return Icons.fact_check_rounded;
    }
  }

  void _openScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  List<_InfoItem> _itemsForCurrentTab() {
    if (_currentIndex == 0) {
      return [
        _InfoItem(
          icon: Icons.check_circle_rounded,
          title: AppStrings.markAttendanceTitleSingleLine,
          subtitle: AppStrings.takeTodayAttendanceCurrentWeek,
          color: Colors.green,
          screen: const AttendanceScreen(),
        ),
      ];
    }

    if (_currentIndex == 1) {
      return [
        _InfoItem(
          icon: Icons.history_rounded,
          title: AppStrings.attendanceHistory,
          subtitle: AppStrings.viewAssignedAttendanceHistory,
          color: Colors.redAccent,
          screen: const AttendanceHistoryScreen(),
        ),
      ];
    }

    return [
      _InfoItem(
        icon: Icons.calendar_month_rounded,
        title: AppStrings.attendanceCalendar,
        subtitle: AppStrings.viewAssignedAttendanceCalendar,
        color: Colors.orange,
        screen: const AttendanceCalendarScreen(),
      ),
    ];
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
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                ResponsivePadding.horizontal(context),
                ResponsiveSpacing.small(context),
                ResponsivePadding.horizontal(context),
                ResponsiveSpacing.large(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _pageHeader(context, isDark),
                  const SizedBox(height: 16),
                  _mainHeader(isDark),
                  const SizedBox(height: 16),
                  _infoCard(isDark),
                  const SizedBox(height: 18),
                  _moduleHeader(isDark),
                  const SizedBox(height: 18),
                  _sectionTitle(
                    title: _title.toUpperCase(),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _secondaryText(isDark),
                      fontFamily: ResponsiveText.fontFamily,
                      fontSize: ResponsiveText.bodySmall(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _contentList(isDark),
                  const SizedBox(height: 12),
                  _summaryRow(isDark),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: _bottomNavigation(isDark),
          ),
            );
          },
        );
      },
    );
  }

  Widget _pageHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        _circleButton(
          isDark: isDark,
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        Image.asset(
          'assets/images/ygca_logo_background.png',
          width: 42,
          height: 42,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            AppStrings.coachAttendanceTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _primaryText(isDark),
              fontFamily: ResponsiveText.fontFamily,
              fontSize: ResponsiveText.heading(context),
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
                  : Colors.black.withOpacity(0.07),
              blurRadius: 11,
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

  Widget _mainHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.black,
                  darkMaroon,
                  red.withOpacity(0.35),
                ]
              : [
                  maroon,
                  darkMaroon,
                  Colors.black.withOpacity(0.85),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? red.withOpacity(0.35) : gold.withOpacity(0.75),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.30),
              shape: BoxShape.circle,
              border: Border.all(color: gold.withOpacity(0.85)),
            ),
            child: const Icon(
              Icons.fact_check_rounded,
              color: gold,
              size: 35,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.attendanceModule.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: ResponsiveText.fontFamily,
                    fontSize: ResponsiveText.pageTitle(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  AppStrings.markReviewTrackAttendance,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: gold,
                    fontFamily: ResponsiveText.fontFamily,
                    fontSize: ResponsiveText.body(context),
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.coachManageWeeklyAttendance,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontFamily: ResponsiveText.fontFamily,
                    fontSize: ResponsiveText.bodySmall(context),
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? gold.withOpacity(0.42) : gold.withOpacity(0.75),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: gold.withOpacity(0.16),
            child: Icon(
              Icons.info_outline_rounded,
              color: isDark ? gold : maroon,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings.coachAttendanceFilteringInfo,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _secondaryText(isDark),
                fontFamily: ResponsiveText.fontFamily,
                fontSize: ResponsiveText.bodySmall(context),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moduleHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? red.withOpacity(0.30) : gold.withOpacity(0.75),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 29,
            backgroundColor: maroon,
            child: Icon(
              _headerIcon,
              color: gold,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontFamily: ResponsiveText.fontFamily,
                    fontSize: ResponsiveText.pageTitle(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontFamily: ResponsiveText.fontFamily,
                    fontSize: ResponsiveText.bodySmall(context),
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    required bool isDark,
  }) {
    return Row(
      children: [
        SizedBox(
          width: ResponsiveHelper.isMobile(context) ? 200 : 230,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                color: isDark ? gold : maroon,
                fontFamily: ResponsiveText.fontFamily,
                fontSize: ResponsiveText.heading(context),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: isDark ? red.withOpacity(0.50) : gold.withOpacity(0.85),
          ),
        ),
      ],
    );
  }

  Widget _contentList(bool isDark) {
    final items = _itemsForCurrentTab();

    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];

        return Padding(
          padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _openScreen(item.screen),
              child: Ink(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _card(isDark),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? red.withOpacity(0.25)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(isDark ? 0.16 : 0.08),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: item.color.withOpacity(0.30),
                        ),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.color,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _primaryText(isDark),
                              fontFamily: ResponsiveText.fontFamily,
                              fontSize: ResponsiveText.title(context),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _secondaryText(isDark),
                              fontFamily: ResponsiveText.fontFamily,
                              fontSize: ResponsiveText.small(context),
                              height: 1.25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? Colors.white38 : Colors.black38,
                      size: 25,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _summaryRow(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          _miniStat(
            isDark: isDark,
            icon: Icons.fact_check_rounded,
            label: AppStrings.mark,
            value: AppStrings.today,
            color: Colors.green,
          ),
          _miniStat(
            isDark: isDark,
            icon: Icons.history_rounded,
            label: AppStrings.history,
            value: AppStrings.view,
            color: Colors.redAccent,
          ),
          _miniStat(
            isDark: isDark,
            icon: Icons.calendar_month_rounded,
            label: AppStrings.calendar,
            value: AppStrings.view,
            color: Colors.orange,
          ),
          _miniStat(
            isDark: isDark,
            icon: Icons.person_rounded,
            label: AppStrings.roleLabel,
            value: AppStrings.coachLabel,
            color: Colors.purpleAccent,
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _secondaryText(isDark),
              fontFamily: ResponsiveText.fontFamily,
              fontSize: ResponsiveText.tiny(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _primaryText(isDark),
              fontFamily: ResponsiveText.fontFamily,
              fontSize: ResponsiveText.bodySmall(context),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavigation(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? red.withOpacity(0.30) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          _bottomItem(
            isDark: isDark,
            icon: Icons.fact_check_rounded,
            label: AppStrings.mark,
            selected: _currentIndex == 0,
            onTap: () => setState(() => _currentIndex = 0),
          ),
          _bottomItem(
            isDark: isDark,
            icon: Icons.history_rounded,
            label: AppStrings.records,
            selected: _currentIndex == 1,
            onTap: () => setState(() => _currentIndex = 1),
          ),
          _bottomItem(
            isDark: isDark,
            icon: Icons.calendar_month_rounded,
            label: AppStrings.calendar,
            selected: _currentIndex == 2,
            onTap: () => setState(() => _currentIndex = 2),
          ),
        ],
      ),
    );
  }

  Widget _bottomItem({
    required bool isDark,
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: selected ? red.withOpacity(0.16) : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? red.withOpacity(0.45) : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected
                    ? (isDark ? gold : maroon)
                    : _secondaryText(isDark),
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? (isDark ? gold : maroon)
                      : _secondaryText(isDark),
                  fontWeight: FontWeight.w900,
                  fontFamily: ResponsiveText.fontFamily,
                  fontSize: ResponsiveText.small(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget screen;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.screen,
  });
}
