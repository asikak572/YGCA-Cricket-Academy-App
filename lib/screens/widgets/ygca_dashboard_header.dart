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
          Image.asset('assets/images/ygca_logo.jpg', width: 58),
          const SizedBox(width: 12),
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
          const SizedBox(width: 12),
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
          const Icon(Icons.menu, color: Colors.white, size: 26),
          const Spacer(),
          Column(
            children: [
              Text(
                "YGCA",
                style: TextStyle(
                  color: _gold,
                  fontSize: dashboardTitle != null ? 30 : 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              Text(
                "YOUNG GEN CRICKET ACADEMY",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: dashboardTitle != null ? 10 : 9,
                ),
              ),
              if (dashboardTitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  dashboardTitle!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          _notificationBell(context),
          const SizedBox(width: 10),
          if (onLogout != null) _logoutButton(),
          if (showProfileAvatar) _profileAvatar(),
        ],
      ),
    );
  }

  Widget _notificationBell(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.pushNamed(context, '/notifications');
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.notifications_none,
            color: Colors.white,
            size: showProfileAvatar ? 26 : 28,
          ),
          Positioned(
            right: -2,
            top: -2,
            child: CircleAvatar(
              radius: showProfileAvatar ? 7 : 8,
              backgroundColor: Colors.orange,
              child: Text(
                "3",
                style: TextStyle(
                  fontSize: showProfileAvatar ? 8 : 9,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoutButton() {
    return IconButton(
      onPressed: onLogout,
      icon: const Icon(Icons.logout, color: Colors.white),
    );
  }

  Widget _profileAvatar() {
    return const CircleAvatar(
      radius: 16,
      backgroundColor: Colors.white,
      child: Icon(Icons.person, color: Colors.black, size: 19),
    );
  }
}