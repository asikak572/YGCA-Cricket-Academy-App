import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';
import '../core/responsive/responsive_padding.dart';

import 'attendance_calendar_screen.dart';
import 'attendance_history_screen.dart';
import 'leave_request_screen.dart';
import 'cancel_session_screen.dart';
import 'makeup_session_screen.dart';

class StudentAttendanceModuleScreen extends StatefulWidget {
  const StudentAttendanceModuleScreen({
    super.key,
    required this.studentId,
    required this.name,
    required this.batch,
    required this.rollNo,
    required this.attendance,
  });

  final String studentId;
  final String name;
  final String batch;
  final String rollNo;
  final String attendance;

  @override
  State<StudentAttendanceModuleScreen> createState() =>
      _StudentAttendanceModuleScreenState();
}

class _StudentAttendanceModuleScreenState
    extends State<StudentAttendanceModuleScreen> {
  int _currentIndex = 0;

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
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
        return AppStrings.attendanceMain;
      case 1:
        return AppStrings.sessionManagement;
      case 2:
        return AppStrings.attendanceReports;
      default:
        return AppStrings.attendanceModule;
    }
  }

  String get _subtitle {
    switch (_currentIndex) {
      case 0:
        return AppStrings.markAttendanceViewCalendarHistory;
      case 1:
        return AppStrings.manageLeaveCancelledMakeup;
      case 2:
        return AppStrings.viewAttendanceReportsAnalytics;
      default:
        return "";
    }
  }

  IconData get _headerIcon {
    switch (_currentIndex) {
      case 0:
        return Icons.fact_check_rounded;
      case 1:
        return Icons.calendar_month_rounded;
      case 2:
        return Icons.bar_chart_rounded;
      default:
        return Icons.dashboard_rounded;
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
          title: AppStrings.markAttendanceTitle,
          subtitle: AppStrings.takeDailySessionAttendance,
          color: Colors.green,
          screen: const AttendanceHistoryScreen(),
        ),
        _InfoItem(
          icon: Icons.calendar_month_rounded,
          title: AppStrings.attendanceCalendar,
          subtitle: AppStrings.studentWiseCalendarView,
          color: Colors.orange,
          screen: AttendanceCalendarScreen(
            studentId: widget.studentId,
            name: widget.name,
            batch: widget.batch,
            rollNo: widget.rollNo,
            attendance: widget.attendance,
          ),
        ),
        _InfoItem(
          icon: Icons.history_rounded,
          title: AppStrings.attendanceHistory,
          subtitle: AppStrings.viewPastAttendanceRecords,
          color: Colors.blueAccent,
          screen: AttendanceHistoryScreen(
            allowedStudentIds: [widget.studentId],
          ),
        ),
      ];
    }

    if (_currentIndex == 1) {
      return [
        _InfoItem(
          icon: Icons.assignment_rounded,
          title: AppStrings.leaveRequestsSingleLine,
          subtitle: AppStrings.studentAttendanceApplyManageLeave,
          color: Colors.redAccent,
          screen: const LeaveRequestScreen(),
        ),
        _InfoItem(
          icon: Icons.event_busy_rounded,
          title: AppStrings.cancelSession,
          subtitle: AppStrings.studentAttendanceViewCancelledSessions,
          color: Colors.deepOrange,
          screen: const CancelSessionScreen(),
        ),
        _InfoItem(
          icon: Icons.event_repeat_rounded,
          title: AppStrings.makeupSessions,
          subtitle: AppStrings.studentAttendanceViewMakeupSessions,
          color: Colors.teal,
          screen: const MakeupSessionScreen(),
        ),
      ];
    }

    return [
      _InfoItem(
        icon: Icons.bar_chart_rounded,
        title: AppStrings.attendanceReports,
        subtitle: AppStrings.viewAttendanceSummaryAnalytics,
        color: Colors.purpleAccent,
        screen: AttendanceHistoryScreen(
          allowedStudentIds: [widget.studentId],
        ),
      ),
      _InfoItem(
        icon: Icons.grid_view_rounded,
        title: AppStrings.monthlySummary,
        subtitle: AppStrings.viewMonthlySummary,
        color: Colors.blueAccent,
        screen: AttendanceHistoryScreen(
          allowedStudentIds: [widget.studentId],
        ),
      ),
      _InfoItem(
        icon: Icons.person_search_rounded,
        title: AppStrings.studentAnalytics,
        subtitle: AppStrings.checkStudentAnalytics,
        color: Colors.orange,
        screen: AttendanceHistoryScreen(
          allowedStudentIds: [widget.studentId],
        ),
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
          backgroundColor: _bg(isDark),
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                ResponsivePadding.horizontal(context),
                12,
                ResponsivePadding.horizontal(context),
                20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _pageHeader(context, isDark),
                  const SizedBox(height: 16),
                  _moduleHeader(isDark),
                  const SizedBox(height: 18),
                  _sectionTitle(
                    title: _title.toUpperCase(),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _subtitle,
                    style: TextStyle(
                      color: _secondaryText(isDark),
                      fontSize: 12,
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
          'assets/images/ygca_logo.jpg',
          width: 42,
          height: 42,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            AppStrings.attendanceModule.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _primaryText(isDark),
              fontSize: 19,
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

  Widget _moduleHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF120202),
                  const Color(0xFF1A0505),
                  red.withOpacity(0.22),
                ]
              : [
                  Colors.white,
                  const Color(0xFFFFF7F7),
                  gold.withOpacity(0.20),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? red.withOpacity(0.30) : gold.withOpacity(0.75),
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark ? red.withOpacity(0.10) : Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -22,
            bottom: -30,
            child: Icon(
              _headerIcon,
              color: isDark ? red.withOpacity(0.13) : maroon.withOpacity(0.07),
              size: 118,
            ),
          ),
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.black.withOpacity(0.30)
                      : Colors.white.withOpacity(0.75),
                  border: Border.all(
                    color: gold.withOpacity(0.85),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withOpacity(0.13),
                      blurRadius: 14,
                    ),
                  ],
                ),
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
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
          width: 220,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                color: isDark ? gold : maroon,
                fontSize: 18,
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
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? item.color.withOpacity(0.07)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            item.color.withOpacity(isDark ? 0.38 : 0.20),
                            item.color.withOpacity(isDark ? 0.16 : 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
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
                              fontSize: 14.5,
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
                              fontSize: 11.2,
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
    if (_currentIndex == 0) {
      return _summaryContainer(
        isDark: isDark,
        items: [
          _MiniStatData(
            icon: Icons.check_circle_rounded,
            label: AppStrings.present,
            value: widget.attendance.isEmpty ? "0%" : widget.attendance,
            color: Colors.green,
          ),
          _MiniStatData(
            icon: Icons.cancel_rounded,
            label: AppStrings.absent,
            value: "5",
            color: Colors.redAccent,
          ),
          _MiniStatData(
            icon: Icons.event_busy_rounded,
            label: AppStrings.leave,
            value: "3",
            color: Colors.orange,
          ),
          _MiniStatData(
            icon: Icons.history_rounded,
            label: AppStrings.history,
            value: AppStrings.all,
            color: Colors.blueAccent,
          ),
        ],
      );
    }

    if (_currentIndex == 1) {
      return _summaryContainer(
        isDark: isDark,
        items: [
          _MiniStatData(
            icon: Icons.assignment_rounded,
            label: AppStrings.leave,
            value: "4",
            color: Colors.redAccent,
          ),
          _MiniStatData(
            icon: Icons.event_busy_rounded,
            label: AppStrings.cancel,
            value: "1",
            color: Colors.deepOrange,
          ),
          _MiniStatData(
            icon: Icons.event_repeat_rounded,
            label: AppStrings.makeup,
            value: "3",
            color: Colors.teal,
          ),
          _MiniStatData(
            icon: Icons.event_available_rounded,
            label: AppStrings.sessions,
            value: AppStrings.live,
            color: Colors.green,
          ),
        ],
      );
    }

    return _summaryContainer(
      isDark: isDark,
      items: [
        _MiniStatData(
          icon: Icons.bar_chart_rounded,
          label: AppStrings.reports,
          value: AppStrings.all,
          color: Colors.purpleAccent,
        ),
        _MiniStatData(
          icon: Icons.grid_view_rounded,
          label: AppStrings.month,
          value: "30D",
          color: Colors.blueAccent,
        ),
        _MiniStatData(
          icon: Icons.person_search_rounded,
          label: AppStrings.students,
          value: AppStrings.view,
          color: Colors.orange,
        ),
        _MiniStatData(
          icon: Icons.percent_rounded,
          label: AppStrings.avg,
          value: widget.attendance.isEmpty ? "0%" : widget.attendance,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _summaryContainer({
    required bool isDark,
    required List<_MiniStatData> items,
  }) {
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
        children: items.map((item) {
          return Expanded(
            child: _miniStat(
              isDark: isDark,
              icon: item.icon,
              label: item.label,
              value: item.value,
              color: item.color,
            ),
          );
        }).toList(),
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
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 22,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _secondaryText(isDark),
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: _primaryText(isDark),
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _bottomNavigation(bool isDark) {
    final items = [
      _BottomNavItem(
        icon: Icons.fact_check_rounded,
        label: AppStrings.main,
      ),
      _BottomNavItem(
        icon: Icons.event_available_rounded,
        label: AppStrings.session,
      ),
      _BottomNavItem(
        icon: Icons.bar_chart_rounded,
        label: AppStrings.reports,
      ),
    ];

    return Container(
      margin: EdgeInsets.fromLTRB(
        ResponsivePadding.horizontal(context),
        0,
        ResponsivePadding.horizontal(context),
        12,
      ),
      padding: const EdgeInsets.all(7),
      height: 76,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101010) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? red.withOpacity(0.30) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark ? red.withOpacity(0.12) : Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final selected = index == _currentIndex;
          final item = items[index];

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(23),
              onTap: () {
                setState(() {
                  _currentIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: selected
                      ? LinearGradient(
                          colors: [
                            red.withOpacity(isDark ? 0.90 : 0.92),
                            maroon.withOpacity(isDark ? 0.95 : 0.90),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: selected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(23),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: red.withOpacity(isDark ? 0.23 : 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      color: selected
                          ? Colors.white
                          : isDark
                              ? Colors.white60
                              : const Color(0xFF6B7280),
                      size: selected ? 25 : 23,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : isDark
                                ? Colors.white60
                                : const Color(0xFF6B7280),
                        fontSize: 11,
                        fontWeight:
                            selected ? FontWeight.w900 : FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
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

  _InfoItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.screen,
  });
}

class _BottomNavItem {
  final IconData icon;
  final String label;

  _BottomNavItem({
    required this.icon,
    required this.label,
  });
}

class _MiniStatData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  _MiniStatData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
