import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';

import 'attendance_screen.dart';
import 'attendance_history_screen.dart';
import 'attendance_report_screen.dart';
import 'attendance_calendar_screen.dart';
import 'leave_request_screen.dart';
import 'cancel_session_screen.dart';
import 'makeup_session_screen.dart';

class AttendanceModuleScreen extends StatelessWidget {
  const AttendanceModuleScreen({super.key});

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _topBar(context, isDark),
                  _heroBanner(isDark),
                  const SizedBox(height: 18),
                  _sectionTitle('ATTENDANCE ACTIONS', isDark),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.10,
                      children: [
                        _moduleCard(
                          context: context,
                          isDark: isDark,
                          icon: Icons.check_circle_rounded,
                          title: 'Mark Attendance',
                          subtitle: 'Take daily session attendance',
                          color: Colors.green,
                          onTap: () => _open(context, const AttendanceScreen()),
                        ),
                        _moduleCard(
                          context: context,
                          isDark: isDark,
                          icon: Icons.calendar_month_rounded,
                          title: 'Attendance Calendar',
                          subtitle: 'Student-wise calendar view',
                          color: Colors.orange,
                          onTap: () => _open(
                            context,
                            const AttendanceCalendarScreen(),
                          ),
                        ),
                        _moduleCard(
                          context: context,
                          isDark: isDark,
                          icon: Icons.history_rounded,
                          title: 'Attendance History',
                          subtitle: 'View past attendance records',
                          color: Colors.blue,
                          onTap: () => _open(
                            context,
                            const AttendanceHistoryScreen(),
                          ),
                        ),
                        _moduleCard(
                          context: context,
                          isDark: isDark,
                          icon: Icons.analytics_rounded,
                          title: 'Attendance Reports',
                          subtitle: 'Summary and analytics',
                          color: Colors.purple,
                          onTap: () => _open(
                            context,
                            const AttendanceReportScreen(),
                          ),
                        ),
                        _moduleCard(
                          context: context,
                          isDark: isDark,
                          icon: Icons.assignment_rounded,
                          title: 'Leave Requests',
                          subtitle: 'Approve and manage leave',
                          color: Colors.redAccent,
                          onTap: () => _open(context, const LeaveRequestScreen()),
                        ),
                        _moduleCard(
                          context: context,
                          isDark: isDark,
                          icon: Icons.event_busy_rounded,
                          title: 'Cancel Session',
                          subtitle: 'Cancel or update class sessions',
                          color: Colors.deepOrange,
                          onTap: () => _open(context, const CancelSessionScreen()),
                        ),
                        _moduleCard(
                          context: context,
                          isDark: isDark,
                          icon: Icons.event_repeat_rounded,
                          title: 'Makeup Sessions',
                          subtitle: 'Compensate missed sessions',
                          color: Colors.teal,
                          onTap: () => _open(context, const MakeupSessionScreen()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _workflowCard(isDark),
                  const SizedBox(height: 22),
                  _footer(isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _topBar(BuildContext context, bool isDark) {
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
                  'YGCA',
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Attendance Management',
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
          color: isDark ? const Color(0xFF111111) : Colors.white,
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

  Widget _heroBanner(bool isDark) {
    return Container(
      height: 230,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? red.withOpacity(0.55) : gold.withOpacity(0.9),
          width: 1,
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
              Icons.fact_check_rounded,
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
                    Icons.fact_check_rounded,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
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
                            'ATTENDANCE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 31,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          Text(
                            'CONTROL',
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
                              _heroChip('Track Sessions'),
                              _heroChip('Leave & Makeup'),
                              _heroChip('Reports'),
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
      constraints: const BoxConstraints(maxWidth: 160),
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

  Widget _moduleCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _card(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? red.withOpacity(0.25) : _border(isDark),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.30)
                  : Colors.black.withOpacity(0.055),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.25),
                    red.withOpacity(0.10),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.45)),
              ),
              child: Icon(icon, color: color, size: 27),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryText(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText(isDark),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _workflowCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF180808),
                  const Color(0xFF0F0F0F),
                  red.withOpacity(0.18),
                ]
              : [
                  Colors.white,
                  const Color(0xFFFFFBF2),
                  gold.withOpacity(0.18),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? red.withOpacity(0.35) : gold.withOpacity(0.7),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: red.withOpacity(0.18),
            child: Icon(
              Icons.rule_folder_rounded,
              color: gold,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Workflow',
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Mark attendance, monitor records, handle leave and schedule makeup sessions.',
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
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
        boxShadow: [
          BoxShadow(
            color: red.withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _footerItem(Icons.check_circle_rounded, 'Track'),
          _footerItem(Icons.event_available_rounded, 'Manage'),
          _footerItem(Icons.analytics_rounded, 'Report'),
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
