import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';

import 'match_schedule_screen.dart';
import 'training_schedule_screen.dart';

class StudentScheduleModuleScreen extends StatefulWidget {
  const StudentScheduleModuleScreen({super.key});

  @override
  State<StudentScheduleModuleScreen> createState() =>
      _StudentScheduleModuleScreenState();
}

class _StudentScheduleModuleScreenState
    extends State<StudentScheduleModuleScreen> {
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
        return "Schedule";
      case 1:
        return "Sessions";
      case 2:
        return "Reports";
      default:
        return "Schedule Module";
    }
  }

  String get _subtitle {
    switch (_currentIndex) {
      case 0:
        return "View match and training schedules";
      case 1:
        return "Check regular, makeup and cancelled sessions";
      case 2:
        return "View schedule history and updates";
      default:
        return "";
    }
  }

  IconData get _headerIcon {
    switch (_currentIndex) {
      case 0:
        return Icons.calendar_month_rounded;
      case 1:
        return Icons.event_available_rounded;
      case 2:
        return Icons.analytics_rounded;
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
          icon: Icons.sports_cricket_rounded,
          title: "Match Schedule",
          subtitle: "View upcoming matches",
          color: const Color(0xFF8B5CF6),
          screen: const MatchScheduleScreen(),
        ),
        _InfoItem(
          icon: Icons.calendar_today_rounded,
          title: "Training Schedule",
          subtitle: "View academy training sessions",
          color: const Color(0xFF0F766E),
          screen: const TrainingScheduleScreen(),
        ),
        _InfoItem(
          icon: Icons.today_rounded,
          title: "Today Schedule",
          subtitle: "Check today's training or match plan",
          color: Colors.orange,
          screen: const TrainingScheduleScreen(),
        ),
      ];
    }

    if (_currentIndex == 1) {
      return [
        _InfoItem(
          icon: Icons.event_available_rounded,
          title: "Regular Sessions",
          subtitle: "View regular academy sessions",
          color: Colors.green,
          screen: const TrainingScheduleScreen(),
        ),
        _InfoItem(
          icon: Icons.replay_circle_filled_rounded,
          title: "Makeup Sessions",
          subtitle: "View makeup class/session updates",
          color: Colors.blueAccent,
          screen: const TrainingScheduleScreen(),
        ),
        _InfoItem(
          icon: Icons.event_busy_rounded,
          title: "Cancelled Sessions",
          subtitle: "View cancelled training sessions",
          color: Colors.redAccent,
          screen: const TrainingScheduleScreen(),
        ),
      ];
    }

    return [
      _InfoItem(
        icon: Icons.history_rounded,
        title: "Session History",
        subtitle: "View previous schedule records",
        color: Colors.purpleAccent,
        screen: const TrainingScheduleScreen(),
      ),
      _InfoItem(
        icon: Icons.calendar_month_rounded,
        title: "Monthly Schedule",
        subtitle: "View monthly training timetable",
        color: Colors.blueAccent,
        screen: const TrainingScheduleScreen(),
      ),
      _InfoItem(
        icon: Icons.campaign_rounded,
        title: "Schedule Updates",
        subtitle: "View latest schedule announcements",
        color: Colors.orange,
        screen: const TrainingScheduleScreen(),
      ),
    ];
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
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
            "SCHEDULE MODULE",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _primaryText(isDark),
              fontSize: 18,
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
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.16) : maroon.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -26,
            child: Icon(
              Icons.calendar_month_rounded,
              color: Colors.white.withOpacity(0.08),
              size: 115,
            ),
          ),
          Row(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.30),
                  shape: BoxShape.circle,
                  border: Border.all(color: gold.withOpacity(0.85)),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withOpacity(0.16),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: gold,
                  size: 35,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "SCHEDULE MODULE",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Matches, training sessions and timetable",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Schedule updates are controlled by Admin/Coach",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.78),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
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

  Widget _infoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? gold.withOpacity(0.42) : gold.withOpacity(0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
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
              "Students can view match and training schedules. Later we can connect each row to separate dynamic screens.",
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
                    fontSize: 20,
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
    );
  }

  Widget _sectionTitle({
    required String title,
    required bool isDark,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 230,
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
            icon: Icons.sports_cricket_rounded,
            label: "Match",
            value: "View",
            color: const Color(0xFF8B5CF6),
          ),
          _MiniStatData(
            icon: Icons.calendar_today_rounded,
            label: "Training",
            value: "View",
            color: const Color(0xFF0F766E),
          ),
          _MiniStatData(
            icon: Icons.today_rounded,
            label: "Today",
            value: "Plan",
            color: Colors.orange,
          ),
          _MiniStatData(
            icon: Icons.event_rounded,
            label: "Schedule",
            value: "Live",
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
            icon: Icons.event_available_rounded,
            label: "Regular",
            value: "Class",
            color: Colors.green,
          ),
          _MiniStatData(
            icon: Icons.replay_circle_filled_rounded,
            label: "Makeup",
            value: "View",
            color: Colors.blueAccent,
          ),
          _MiniStatData(
            icon: Icons.event_busy_rounded,
            label: "Cancel",
            value: "Track",
            color: Colors.redAccent,
          ),
          _MiniStatData(
            icon: Icons.update_rounded,
            label: "Updates",
            value: "Live",
            color: Colors.orange,
          ),
        ],
      );
    }

    return _summaryContainer(
      isDark: isDark,
      items: [
        _MiniStatData(
          icon: Icons.history_rounded,
          label: "History",
          value: "View",
          color: Colors.purpleAccent,
        ),
        _MiniStatData(
          icon: Icons.calendar_month_rounded,
          label: "Monthly",
          value: "Plan",
          color: Colors.blueAccent,
        ),
        _MiniStatData(
          icon: Icons.campaign_rounded,
          label: "Updates",
          value: "News",
          color: Colors.orange,
        ),
        _MiniStatData(
          icon: Icons.verified_rounded,
          label: "Status",
          value: "Active",
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
          size: 21,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _secondaryText(isDark),
            fontSize: 9.2,
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
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _bottomNavigation(bool isDark) {
    final items = [
      _BottomNavItem(
        icon: Icons.calendar_month_rounded,
        label: "Main",
      ),
      _BottomNavItem(
        icon: Icons.event_available_rounded,
        label: "Sessions",
      ),
      _BottomNavItem(
        icon: Icons.analytics_rounded,
        label: "Reports",
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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