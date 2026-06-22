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

  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);
  static const Color bg = Color(0xFFFAFAFA);

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
      navigator.push(
        MaterialPageRoute(builder: (_) => screen),
      );
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
            icon: Icons.dashboard,
            label: 'Dashboard',
            onTap: () {
              _closeDrawer(context);
            },
          ),
          YgcaNavItem(
            icon: Icons.fact_check,
            label: 'Attendance',
            onTap: () {
              _openScreen(
                context,
                const ParentAttendanceModuleScreen(),
              );
            },
          ),
          YgcaNavItem(
            icon: Icons.bar_chart,
            label: 'Performance',
            onTap: () {
              _openScreen(
                context,
                const ParentPerformanceModuleScreen(),
              );
            },
          ),
          YgcaNavItem(
            icon: Icons.receipt_long,
            label: 'Payment History',
            onTap: () {
              _openScreen(
                context,
                const ParentFeeModuleScreen(),
              );
            },
          ),
          YgcaNavItem(
            icon: Icons.calendar_month,
            label: 'Match Schedule',
            onTap: () {
              _openScreen(
                context,
                const ParentScheduleModuleScreen(),
              );
            },
          ),
          YgcaNavItem(
            icon: Icons.event_note,
            label: 'Apply Leave',
            onTap: () {
              _openScreen(
                context,
                const LeaveRequestScreen(),
              );
            },
          ),
          YgcaNavItem(
            icon: Icons.notifications,
            label: 'Notifications',
            onTap: () {
              _openScreen(
                context,
                const NotificationScreen(),
              );
            },
          ),
          YgcaNavItem(
            icon: Icons.person,
            label: 'Edit Profile',
            onTap: () {
              _openScreen(
                context,
                const EditProfileScreen(),
              );
            },
          ),
        ];

      case 'Student':
        return [
          YgcaNavItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            onTap: () {
              _closeDrawer(context);
            },
          ),
          YgcaNavItem(
            icon: Icons.fact_check,
            label: 'Attendance',
            onTap: () {
              _openNamedRoute(context, '/attendance');
            },
          ),
          YgcaNavItem(
            icon: Icons.bar_chart,
            label: 'Performance',
            onTap: () {
              _openNamedRoute(context, '/performance');
            },
          ),
          YgcaNavItem(
            icon: Icons.receipt_long,
            label: 'Fees',
            onTap: () {
              _openNamedRoute(context, '/fees');
            },
          ),
          YgcaNavItem(
            icon: Icons.notifications,
            label: 'Notifications',
            onTap: () {
              _openNamedRoute(context, '/notifications');
            },
          ),
        ];

      case 'Coach':
        return [
          YgcaNavItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            onTap: () {
              _closeDrawer(context);
            },
          ),
          YgcaNavItem(
            icon: Icons.people,
            label: 'Students',
            onTap: () {
              _openNamedRoute(context, '/student-list');
            },
          ),
          YgcaNavItem(
            icon: Icons.fact_check,
            label: 'Mark Attendance',
            onTap: () {
              _openNamedRoute(context, '/attendance');
            },
          ),
          YgcaNavItem(
            icon: Icons.bar_chart,
            label: 'Performance',
            onTap: () {
              _openNamedRoute(context, '/performance');
            },
          ),
        ];

      case 'Admin':
        return [
          YgcaNavItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            onTap: () {
              _closeDrawer(context);
            },
          ),
          YgcaNavItem(
            icon: Icons.people,
            label: 'Students',
            onTap: () {
              _openNamedRoute(context, '/student-list');
            },
          ),
          YgcaNavItem(
            icon: Icons.fact_check,
            label: 'Attendance',
            onTap: () {
              _openNamedRoute(context, '/attendance');
            },
          ),
          YgcaNavItem(
            icon: Icons.payments,
            label: 'Fees',
            onTap: () {
              _openNamedRoute(context, '/fees');
            },
          ),
          YgcaNavItem(
            icon: Icons.notifications,
            label: 'Notifications',
            onTap: () {
              _openNamedRoute(context, '/notifications');
            },
          ),
        ];

      default:
        return [
          YgcaNavItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            onTap: () {
              _closeDrawer(context);
            },
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = navItems.isNotEmpty ? navItems : _defaultItems(context);

    return Drawer(
      backgroundColor: bg,
      width: MediaQuery.of(context).size.width < 360 ? 280 : 300,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 22,
              left: 20,
              right: 20,
              bottom: 22,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [darkMaroon, maroon],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/ygca_logo.jpg',
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'YGCA',
                        style: TextStyle(
                          color: gold,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: gold,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: maroon,
                          fontSize: 16,
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
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          if (email != null)
                            Text(
                              email!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: gold.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: gold.withOpacity(0.5)),
                            ),
                            child: Text(
                              role.toUpperCase(),
                              style: const TextStyle(
                                color: gold,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: Icon(item.icon, color: maroon),
                    title: Text(
                      item.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Colors.grey,
                    ),
                    onTap: item.onTap,
                  ),
                );
              },
            ),
          ),
          if (onLogout != null) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                final navigator = Navigator.of(context);
                navigator.pop();

                Future.delayed(const Duration(milliseconds: 180), () {
                  onLogout!();
                });
              },
            ),
          ],
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }
}