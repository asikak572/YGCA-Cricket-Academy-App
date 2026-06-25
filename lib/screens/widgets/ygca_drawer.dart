import 'package:flutter/material.dart';

import '../../theme/theme_controller.dart';

import '../notification_screen.dart';
import '../leave_request_screen.dart';
import '../parent_attendance_module_screen.dart';
import '../parent_fee_module_screen.dart';
import '../parent_schedule_module_screen.dart';
import '../parent_performance_module_screen.dart';
import '../edit_profile_screen.dart';

class YgcaNavItem {
  const YgcaNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class YgcaDrawer extends StatelessWidget {
  const YgcaDrawer({
    super.key,
    required this.role,
    this.username,
    this.email,
    this.navItems = const [],
    this.onLogout,
  });

  final String role;
  final String? username;
  final String? email;
  final List<YgcaNavItem> navItems;
  final VoidCallback? onLogout;

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  String get initials {
    final name = username ?? role;
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();

    if (parts.isEmpty) {
      return role.isNotEmpty ? role[0].toUpperCase() : "U";
    }

    return parts.map((e) => e[0].toUpperCase()).take(2).join();
  }

  Color _bg(bool isDark) {
    return isDark ? const Color(0xFF070707) : const Color(0xFFFAFAFA);
  }

  Color _card(bool isDark) {
    return isDark ? const Color(0xFF151515) : Colors.white;
  }

  Color _tile(bool isDark) {
    return isDark ? const Color(0xFF1B0A0A) : Colors.white;
  }

  Color _tileBorder(bool isDark) {
    return isDark ? red.withOpacity(0.28) : const Color(0xFFE2E8F0);
  }

  Color _primaryText(bool isDark) {
    return isDark ? Colors.white : const Color(0xFF111827);
  }

  Color _secondaryText(bool isDark) {
    return isDark ? Colors.white60 : const Color(0xFF64748B);
  }

  void _closeDrawer(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _openScreen(BuildContext context, Widget screen) {
    final navigator = Navigator.of(context);
    navigator.pop();

    Future.delayed(const Duration(milliseconds: 180), () {
      navigator.push(MaterialPageRoute(builder: (_) => screen));
    });
  }

  void _openNamedRoute(BuildContext context, String routeName) {
    final navigator = Navigator.of(context);
    navigator.pop();

    Future.delayed(const Duration(milliseconds: 180), () {
      navigator.pushNamed(routeName);
    });
  }

  List<YgcaNavItem> _defaultItems(BuildContext context) {
    switch (role) {
      case 'Parent':
        return [
          YgcaNavItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            onTap: () => _closeDrawer(context),
          ),
          YgcaNavItem(
            icon: Icons.fact_check_rounded,
            label: 'Attendance',
            onTap: () {
              _openScreen(context, const ParentAttendanceModuleScreen());
            },
          ),
          YgcaNavItem(
            icon: Icons.bar_chart_rounded,
            label: 'Performance',
            onTap: () {
              _openScreen(context, const ParentPerformanceModuleScreen());
            },
          ),
          YgcaNavItem(
            icon: Icons.receipt_long_rounded,
            label: 'Payment History',
            onTap: () {
              _openScreen(context, const ParentFeeModuleScreen());
            },
          ),
          YgcaNavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Match Schedule',
            onTap: () {
              _openScreen(context, const ParentScheduleModuleScreen());
            },
          ),
          YgcaNavItem(
            icon: Icons.event_note_rounded,
            label: 'Apply Leave',
            onTap: () {
              _openScreen(context, const LeaveRequestScreen());
            },
          ),
          YgcaNavItem(
            icon: Icons.notifications_rounded,
            label: 'Notifications',
            onTap: () {
              _openScreen(context, const NotificationScreen());
            },
          ),
          YgcaNavItem(
            icon: Icons.person_rounded,
            label: 'Edit Profile',
            onTap: () {
              _openScreen(context, const EditProfileScreen());
            },
          ),
        ];

      case 'Student':
        return [
          YgcaNavItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            onTap: () => _closeDrawer(context),
          ),
          YgcaNavItem(
            icon: Icons.fact_check_rounded,
            label: 'Attendance',
            onTap: () => _openNamedRoute(context, '/attendance'),
          ),
          YgcaNavItem(
            icon: Icons.bar_chart_rounded,
            label: 'Performance',
            onTap: () => _openNamedRoute(context, '/performance'),
          ),
          YgcaNavItem(
            icon: Icons.receipt_long_rounded,
            label: 'Fees',
            onTap: () => _openNamedRoute(context, '/fees'),
          ),
          YgcaNavItem(
            icon: Icons.notifications_rounded,
            label: 'Notifications',
            onTap: () => _openNamedRoute(context, '/notifications'),
          ),
        ];

      case 'Coach':
        return [
          YgcaNavItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            onTap: () => _closeDrawer(context),
          ),
          YgcaNavItem(
            icon: Icons.people_rounded,
            label: 'Students',
            onTap: () => _openNamedRoute(context, '/student-list'),
          ),
          YgcaNavItem(
            icon: Icons.fact_check_rounded,
            label: 'Mark Attendance',
            onTap: () => _openNamedRoute(context, '/attendance'),
          ),
          YgcaNavItem(
            icon: Icons.bar_chart_rounded,
            label: 'Performance',
            onTap: () => _openNamedRoute(context, '/performance'),
          ),
        ];

      case 'Admin':
        return [
          YgcaNavItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            onTap: () => _closeDrawer(context),
          ),
          YgcaNavItem(
            icon: Icons.grid_view_rounded,
            label: 'Reports Dashboard',
            onTap: () => _openNamedRoute(context, '/reports'),
          ),
          YgcaNavItem(
            icon: Icons.people_rounded,
            label: 'Students',
            onTap: () => _openNamedRoute(context, '/student-list'),
          ),
          YgcaNavItem(
            icon: Icons.check_circle_rounded,
            label: 'Attendance Module',
            onTap: () => _openNamedRoute(context, '/attendance'),
          ),
          YgcaNavItem(
            icon: Icons.sports_cricket_rounded,
            label: 'Coach Module',
            onTap: () => _openNamedRoute(context, '/coach-module'),
          ),
          YgcaNavItem(
            icon: Icons.payments_rounded,
            label: 'Fee Module',
            onTap: () => _openNamedRoute(context, '/fees'),
          ),
        ];

      default:
        return [
          YgcaNavItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            onTap: () => _closeDrawer(context),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        final items = navItems.isNotEmpty ? navItems : _defaultItems(context);

        return Drawer(
          backgroundColor: _bg(isDark),
          width: MediaQuery.of(context).size.width < 360 ? 300 : 320,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        Colors.black,
                        const Color(0xFF160606),
                        const Color(0xFF250808),
                      ]
                    : [
                        const Color(0xFFFAFAFA),
                        const Color(0xFFFFFBF2),
                        Colors.white,
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                _drawerHeader(context, isDark),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return _drawerTile(
                        isDark: isDark,
                        icon: item.icon,
                        label: item.label,
                        onTap: item.onTap,
                      );
                    },
                  ),
                ),
                if (onLogout != null) _logoutTile(context, isDark),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _drawerHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(
        14,
        MediaQuery.of(context).padding.top + 14,
        14,
        10,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  darkMaroon,
                  maroon,
                  Colors.black,
                ]
              : [
                  Colors.white,
                  const Color(0xFFFFF6D9),
                  const Color(0xFFFFFBF2),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? gold.withOpacity(0.75) : gold.withOpacity(0.95),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? red.withOpacity(0.18)
                : maroon.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? gold.withOpacity(0.35)
                        : gold.withOpacity(0.75),
                  ),
                ),
                child: Image.asset(
                  'assets/images/ygca_logo.jpg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YGCA',
                      style: TextStyle(
                        color: isDark ? gold : maroon,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      'Young Gen Cricket Academy',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.28)
                  : Colors.white.withOpacity(0.82),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.12)
                    : gold.withOpacity(0.45),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: gold,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: maroon,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username ?? "$role User",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _primaryText(isDark),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      if (email != null && email!.trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          email!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _secondaryText(isDark),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? gold.withOpacity(0.13)
                              : maroon.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: gold.withOpacity(0.65),
                          ),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: TextStyle(
                            color: isDark ? gold : maroon,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile({
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: _tile(isDark),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _tileBorder(isDark)),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.30)
                      : Colors.black.withOpacity(0.045),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isDark
                        ? red.withOpacity(0.12)
                        : maroon.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isDark
                          ? red.withOpacity(0.35)
                          : gold.withOpacity(0.55),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isDark ? gold : maroon,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _primaryText(isDark),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : const Color(0xFFFFFBF2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.10)
                          : gold.withOpacity(0.45),
                    ),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? Colors.white70 : maroon,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logoutTile(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          final navigator = Navigator.of(context);
          navigator.pop();

          Future.delayed(const Duration(milliseconds: 180), () {
            onLogout!();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? red.withOpacity(0.16) : Colors.red.withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.red.withOpacity(0.45)),
          ),
          child: Row(
            children: [
              const Icon(Icons.logout_rounded, color: Colors.redAccent),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white70 : Colors.redAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}