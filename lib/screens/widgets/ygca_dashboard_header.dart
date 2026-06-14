import 'package:flutter/material.dart';

/// Shared YGCA-branded dashboard header (top navigation bar) used across
/// all four dashboard screens: Student, Coach, Parent, and Admin.
///
/// Replaces the duplicated inline `_topHeader()` method found in each dashboard.
///
/// Usage:
/// ```dart
/// // Student / Coach dashboard (with logout):
/// YgcaDashboardHeader(
///   dashboardTitle: "STUDENT DASHBOARD",
///   onLogout: () => _logout(context),
/// )
///
/// // Parent dashboard (with logout + dynamic subtitle from user name):
/// YgcaDashboardHeader(
///   dashboardTitle: "PARENT DASHBOARD",
///   onLogout: () => _logout(context),
///   useLogoLayout: true,
///   dynamicSubtitle: "Welcome, $parentName",
/// )
///
/// // Admin dashboard (no logout, shows profile avatar):
/// YgcaDashboardHeader(
///   dashboardTitle: null,
///   showProfileAvatar: true,
/// )
/// ```
class YgcaDashboardHeader extends StatelessWidget {
  const YgcaDashboardHeader({
    super.key,
    this.dashboardTitle,
    this.onLogout,
    this.showProfileAvatar = false,
    this.useLogoLayout = false,
    this.dynamicSubtitle,
  });

  /// Dashboard role label shown below the YGCA subtitle.
  /// e.g. "STUDENT DASHBOARD", "COACH DASHBOARD".
  /// If null, the center column shows only "YGCA" + subtitle (admin style).
  final String? dashboardTitle;

  /// Logout callback. When non-null, a logout IconButton is shown on the right.
  final VoidCallback? onLogout;

  /// When true, shows a CircleAvatar profile icon instead of the logout button.
  /// Used by the Admin dashboard.
  final bool showProfileAvatar;

  /// When true, uses the logo-left layout (Parent dashboard style) instead of
  /// the centered YGCA title layout (Student / Coach style).
  final bool useLogoLayout;

  /// Optional dynamic text shown below the dashboard title in logo layout.
  /// e.g. "Welcome, $parentName"
  final String? dynamicSubtitle;

  static const Color _maroon = Color(0xFF7F0000);
  static const Color _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return useLogoLayout ? _buildLogoLayout() : _buildCenteredLayout();
  }

  // ── Parent Dashboard Layout ──────────────────────────────────────────────
  Widget _buildLogoLayout() {
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
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
          _notificationBell(),
          const SizedBox(width: 12),
          if (onLogout != null) _logoutButton(),
          if (showProfileAvatar) _profileAvatar(),
        ],
      ),
    );
  }

  // ── Student / Coach / Admin Dashboard Layout ─────────────────────────────
  Widget _buildCenteredLayout() {
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
          _notificationBell(),
          const SizedBox(width: 10),
          if (onLogout != null) _logoutButton(),
          if (showProfileAvatar) _profileAvatar(),
        ],
      ),
    );
  }

  // ── Shared Sub-Widgets ───────────────────────────────────────────────────

  Widget _notificationBell() {
    return Stack(
      children: [
        Icon(
          Icons.notifications_none,
          color: Colors.white,
          size: showProfileAvatar ? 26 : 28,
        ),
        Positioned(
          right: 0,
          top: 0,
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
