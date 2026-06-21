import 'package:flutter/material.dart';

class YgcaDashboardHeader extends StatelessWidget {
  const YgcaDashboardHeader({
    super.key,
    this.dashboardTitle,
    this.onLogout,
    this.showProfileAvatar = false,
    this.useLogoLayout = false,
    this.dynamicSubtitle,
  });

  final String? dashboardTitle;
  final VoidCallback? onLogout;
  final bool showProfileAvatar;
  final bool useLogoLayout;
  final String? dynamicSubtitle;

  static const Color _maroon = Color(0xFF7F0000);
  static const Color _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return useLogoLayout
        ? _buildLogoLayout(context)
        : _buildCenteredLayout(context);
  }

  Widget _buildLogoLayout(BuildContext context) {
    return Container(
      color: _maroon,
      padding: const EdgeInsets.fromLTRB(16, 45, 16, 18),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 26,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dashboardTitle != null)
                  Text(
                    dashboardTitle!,
                    style: const TextStyle(
                      color: _gold,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                if (dynamicSubtitle != null)
                  Text(
                    dynamicSubtitle!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          _notificationBell(context),
          if (onLogout != null) _logoutButton(),
          if (showProfileAvatar) _profileAvatar(),
        ],
      ),
    );
  }

  Widget _buildCenteredLayout(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 42, 16, 14),
      color: _maroon,
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 26,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                "YGCA",
                style: TextStyle(
                  color: _gold,
                  fontSize: dashboardTitle != null ? 30 : 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                "YOUNG GEN CRICKET ACADEMY",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                ),
              ),
              if (dashboardTitle != null)
                Text(
                  dashboardTitle!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const Spacer(),
          _notificationBell(context),
          if (onLogout != null) _logoutButton(),
          if (showProfileAvatar) _profileAvatar(),
        ],
      ),
    );
  }

  Widget _notificationBell(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/notifications');
      },
      child: const Icon(
        Icons.notifications_none,
        color: Colors.white,
      ),
    );
  }

  Widget _logoutButton() {
    return IconButton(
      onPressed: onLogout,
      icon: const Icon(
        Icons.logout,
        color: Colors.white,
      ),
    );
  }

  Widget _profileAvatar() {
    return const CircleAvatar(
      radius: 16,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.person,
        color: Colors.black,
        size: 19,
      ),
    );
  }
}