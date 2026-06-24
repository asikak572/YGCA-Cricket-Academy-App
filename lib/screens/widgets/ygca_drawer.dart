import 'package:flutter/material.dart';

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
  static const Color deepBlack = Color(0xFF070707);
  static const Color gold = Color(0xFFD4AF37);

  String get initials {
    final name = username ?? role;
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();

    if (parts.isEmpty) {
      return role.isNotEmpty ? role[0].toUpperCase() : "U";
    }

    return parts.map((e) => e[0].toUpperCase()).take(2).join();
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
            onTap: () => _openScreen(
              context,
              const ParentAttendanceModuleScreen(),
            ),
          ),
          YgcaNavItem(
            icon: Icons.bar_chart_rounded,
            label: 'Performance',
            onTap: () => _openScreen(
              context,
              const ParentPerformanceModuleScreen(),
            ),
          ),
          YgcaNavItem(
            icon: Icons.receipt_long_rounded,
            label: 'Payment History',
            onTap: () => _openScreen(
              context,
              const ParentFeeModuleScreen(),
            ),
          ),
          YgcaNavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Match Schedule',
            onTap: () => _openScreen(
              context,
              const ParentScheduleModuleScreen(),
            ),
          ),
          YgcaNavItem(
            icon: Icons.event_note_rounded,
            label: 'Apply Leave',
            onTap: () => _openScreen(
              context,
              const LeaveRequestScreen(),
            ),
          ),
          YgcaNavItem(
            icon: Icons.notifications_rounded,
            label: 'Notifications',
            onTap: () => _openScreen(
              context,
              const NotificationScreen(),
            ),
          ),
          YgcaNavItem(
            icon: Icons.person_rounded,
            label: 'Edit Profile',
            onTap: () => _openScreen(
              context,
              const EditProfileScreen(),
            ),
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
            icon: Icons.people_rounded,
            label: 'Students',
            onTap: () => _openNamedRoute(context, '/student-list'),
          ),
          YgcaNavItem(
            icon: Icons.fact_check_rounded,
            label: 'Attendance',
            onTap: () => _openNamedRoute(context, '/attendance'),
          ),
          YgcaNavItem(
            icon: Icons.payments_rounded,
            label: 'Fees',
            onTap: () => _openNamedRoute(context, '/fees'),
          ),
          YgcaNavItem(
            icon: Icons.notifications_rounded,
            label: 'Notifications',
            onTap: () => _openNamedRoute(context, '/notifications'),
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
    final items = navItems.isNotEmpty ? navItems : _defaultItems(context);
    final drawerWidth = MediaQuery.of(context).size.width < 360 ? 288.0 : 315.0;

    return Drawer(
      width: drawerWidth,
      backgroundColor: deepBlack,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF050505),
              Color(0xFF160202),
              Color(0xFF320000),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _premiumHeader(),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    return _premiumTile(items[index]);
                  },
                ),
              ),
              if (onLogout != null) _logoutTile(context),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _premiumHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            maroon,
            darkMaroon,
            Colors.black.withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: gold.withOpacity(0.75), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: red.withOpacity(0.20),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: gold.withOpacity(0.55)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/ygca_logo.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YGCA',
                      style: TextStyle(
                        color: gold,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Young Gen Cricket Academy',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.28),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
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
                      fontSize: 18,
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
                        username ?? "$role User",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      if (email != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          email!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: gold.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: gold.withOpacity(0.65)),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: const TextStyle(
                            color: gold,
                            fontSize: 10,
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

  Widget _premiumTile(YgcaNavItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: gold.withOpacity(0.15),
        highlightColor: red.withOpacity(0.10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 62),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.075),
                Colors.white.withOpacity(0.030),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: red.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: red.withOpacity(0.35)),
                ),
                child: Icon(item.icon, color: gold, size: 23),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.055),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 19,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoutTile(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          final navigator = Navigator.of(context);
          navigator.pop();

          Future.delayed(const Duration(milliseconds: 180), () {
            onLogout!();
          });
        },
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                red.withOpacity(0.22),
                Colors.red.withOpacity(0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: red.withOpacity(0.40)),
          ),
          child: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.redAccent, size: 26),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.redAccent,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}