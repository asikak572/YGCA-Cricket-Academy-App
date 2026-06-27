import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';

import 'widgets/ygca_app_bar.dart';

import 'coach_management_screen.dart';
import 'coach_salary_screen.dart';
import 'coach_assigned_students_screen.dart';

class CoachModuleScreen extends StatefulWidget {
  const CoachModuleScreen({super.key});

  @override
  State<CoachModuleScreen> createState() => _CoachModuleScreenState();
}

class _CoachModuleScreenState extends State<CoachModuleScreen> {
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

  Color _primaryText(bool isDark) {
    return isDark ? Colors.white : const Color(0xFF111827);
  }

  Color _secondaryText(bool isDark) {
    return isDark ? Colors.white60 : const Color(0xFF64748B);
  }

  String get _title {
    switch (_currentIndex) {
      case 0:
        return "Coach Management";
      case 1:
        return "Assigned Students";
      case 2:
        return "Coach Salary";
      default:
        return "Coach Module";
    }
  }

  String get _subtitle {
    switch (_currentIndex) {
      case 0:
        return "Manage all coaches and staff details";
      case 1:
        return "View students assigned to coaches";
      case 2:
        return "View salary and payment records";
      default:
        return "";
    }
  }

  Widget get _targetScreen {
    switch (_currentIndex) {
      case 0:
        return const CoachManagementScreen();
      case 1:
        return const CoachAssignedStudentsScreen();
      case 2:
        return const CoachSalaryScreen();
      default:
        return const CoachManagementScreen();
    }
  }

  void _openCurrentScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _targetScreen),
    );
  }

  void _openSpecificScreen(int index) {
    Widget screen;

    switch (index) {
      case 0:
        screen = const CoachManagementScreen();
        break;
      case 1:
        screen = const CoachAssignedStudentsScreen();
        break;
      case 2:
        screen = const CoachSalaryScreen();
        break;
      default:
        screen = const CoachManagementScreen();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: _bg(isDark),
          appBar: const YgcaAppBar(title: "Coach Module"),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: Column(
                      children: [
                        _smallHeader(isDark),
                        const SizedBox(height: 16),
                        _segmentedTabs(isDark),
                        const SizedBox(height: 16),
                        _sectionTitle(
                          title: _title.toUpperCase(),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _subtitle,
                            style: TextStyle(
                              color: _secondaryText(isDark),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _contentList(isDark),
                        const SizedBox(height: 12),
                        _summaryRow(isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _smallHeader(bool isDark) {
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
                  red.withOpacity(0.06),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? red.withOpacity(0.30) : red.withOpacity(0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.10) : Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -30,
            child: Icon(
              Icons.sports_cricket_rounded,
              color: isDark
                  ? red.withOpacity(0.12)
                  : red.withOpacity(0.08),
              size: 115,
            ),
          ),
          Column(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.black.withOpacity(0.28)
                      : Colors.white.withOpacity(0.70),
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
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: gold,
                  size: 28,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Coach Module",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Manage coaches, students and salary\nrecords in one place.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _segmentedTabs(bool isDark) {
    final items = [
      _ModuleTabItem(
        icon: Icons.groups_rounded,
        label: "Coach",
      ),
      _ModuleTabItem(
        icon: Icons.school_rounded,
        label: "Students",
      ),
      _ModuleTabItem(
        icon: Icons.account_balance_wallet_rounded,
        label: "Salary",
      ),
    ];

    return Container(
      height: 74,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101010) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? red.withOpacity(0.30) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.10) : Colors.black.withOpacity(0.06),
            blurRadius: 16,
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
              borderRadius: BorderRadius.circular(24),
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
                            color: red.withOpacity(isDark ? 0.22 : 0.15),
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
                        fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
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

  Widget _sectionTitle({
    required String title,
    required bool isDark,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 205,
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
            color: red.withOpacity(isDark ? 0.58 : 0.55),
          ),
        ),
      ],
    );
  }

  Widget _contentList(bool isDark) {
    final items = _currentIndex == 0
        ? [
            _InfoItem(
              icon: Icons.person_add_alt_1_rounded,
              title: "Add / Manage Coaches",
              subtitle: "Add new coaches and manage their profiles",
              color: Colors.purpleAccent,
              targetIndex: 0,
            ),
            _InfoItem(
              icon: Icons.badge_rounded,
              title: "Coach Details",
              subtitle: "View and update coach information",
              color: Colors.blueAccent,
              targetIndex: 0,
            ),
            _InfoItem(
              icon: Icons.verified_rounded,
              title: "Coach Status",
              subtitle: "Active, inactive and leave details",
              color: Colors.orange,
              targetIndex: 0,
            ),
          ]
        : _currentIndex == 1
            ? [
                _InfoItem(
                  icon: Icons.groups_rounded,
                  title: "View Students by Batch",
                  subtitle: "See students batch wise",
                  color: Colors.blueAccent,
                  targetIndex: 1,
                ),
                _InfoItem(
                  icon: Icons.fact_check_rounded,
                  title: "Student Attendance",
                  subtitle: "View attendance summary",
                  color: Colors.green,
                  targetIndex: 1,
                ),
                _InfoItem(
                  icon: Icons.analytics_rounded,
                  title: "Student Performance",
                  subtitle: "Check student performance",
                  color: Colors.orange,
                  targetIndex: 1,
                ),
              ]
            : [
                _InfoItem(
                  icon: Icons.currency_rupee_rounded,
                  title: "Salary Records",
                  subtitle: "Monthly salary details",
                  color: Colors.green,
                  targetIndex: 2,
                ),
                _InfoItem(
                  icon: Icons.payment_rounded,
                  title: "Payment Status",
                  subtitle: "Paid and pending payments",
                  color: Colors.orange,
                  targetIndex: 2,
                ),
                _InfoItem(
                  icon: Icons.receipt_long_rounded,
                  title: "Salary Reports",
                  subtitle: "View salary history and reports",
                  color: Colors.blueAccent,
                  targetIndex: 2,
                ),
              ];

    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];

        return Padding(
          padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _openSpecificScreen(item.targetIndex),
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
          Expanded(
            child: _miniStat(
              isDark: isDark,
              icon: Icons.groups_rounded,
              label: "Coaches",
              value: "12",
              color: Colors.purpleAccent,
            ),
          ),
          Expanded(
            child: _miniStat(
              isDark: isDark,
              icon: Icons.verified_rounded,
              label: "Active",
              value: "10",
              color: Colors.green,
            ),
          ),
          Expanded(
            child: _miniStat(
              isDark: isDark,
              icon: Icons.event_busy_rounded,
              label: "Leave",
              value: "2",
              color: Colors.orange,
            ),
          ),
          Expanded(
            child: _miniStat(
              isDark: isDark,
              icon: Icons.cancel_rounded,
              label: "Inactive",
              value: "0",
              color: Colors.redAccent,
            ),
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
}

class _InfoItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final int targetIndex;

  _InfoItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.targetIndex,
  });
}

class _ModuleTabItem {
  final IconData icon;
  final String label;

  _ModuleTabItem({
    required this.icon,
    required this.label,
  });
}