import 'package:flutter/material.dart';

/// A nav item definition for the [YgcaDrawer].
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

/// Premium shared sidebar drawer for all four YGCA dashboard screens.
///
/// Features:
/// - Branded header: YGCA logo + role badge + username/email
/// - Role-specific navigation links with ripple tap feedback
/// - Smooth close animation (Flutter's built-in Drawer 250ms slide)
/// - Divider + logout button at the bottom
/// - No overflow on any screen size (320px → 1920px)
///
/// Usage:
/// ```dart
/// Scaffold(
///   drawer: YgcaDrawer(
///     role: "Student",
///     username: name,
///     email: email,
///     navItems: [
///       YgcaNavItem(icon: Icons.home, label: "Dashboard", onTap: () {}),
///       YgcaNavItem(icon: Icons.fact_check, label: "Attendance", onTap: () {...}),
///     ],
///     onLogout: () => _logout(context),
///   ),
///   ...
/// )
/// ```
class YgcaDrawer extends StatelessWidget {
  const YgcaDrawer({
    super.key,
    required this.role,
    this.username,
    this.email,
    required this.navItems,
    this.onLogout,
  });

  /// Role label, e.g. "Student", "Coach", "Parent", "Admin"
  final String role;

  /// Display name shown in the drawer header.
  final String? username;

  /// Email shown in the drawer header.
  final String? email;

  /// Navigation items to display in the drawer body.
  final List<YgcaNavItem> navItems;

  /// Logout handler. If null, logout button is hidden.
  final VoidCallback? onLogout;

  static const Color _maroon = Color(0xFF7F0000);
  static const Color _maroonDark = Color(0xFF5A0000);
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _surface = Color(0xFFFAFAFA);

  String get _initials {
    final name = username ?? role;
    return name
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase())
        .take(2)
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _surface,
      elevation: 0,
      width: _drawerWidth(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // ── Branded header ─────────────────────────────────────────────
          _DrawerHeader(
            role: role,
            username: username,
            email: email,
            initials: _initials,
          ),

          // ── Navigation links ───────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                return _NavTile(
                  icon: item.icon,
                  label: item.label,
                  onTap: () {
                    Navigator.of(context).pop(); // close drawer first
                    item.onTap();
                  },
                );
              },
            ),
          ),

          // ── Bottom divider + logout ────────────────────────────────────
          if (onLogout != null) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            _LogoutTile(onLogout: onLogout!),
          ],

          // Safe area bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }

  double _drawerWidth(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    // 280px on small screens, max 300px on larger screens
    return sw < 360 ? sw * 0.82 : 280;
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Sub-widgets (private)
// ────────────────────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.role,
    required this.username,
    required this.email,
    required this.initials,
  });

  final String role;
  final String? username;
  final String? email;
  final String initials;

  static const Color _maroon = Color(0xFF7F0000);
  static const Color _maroonDark = Color(0xFF5A0000);
  static const Color _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_maroonDark, _maroon],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/ygca_logo.jpg',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.sports_cricket,
                      color: _gold,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'YGCA',
                    style: TextStyle(
                      color: _gold,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'Young Gen Cricket Academy',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 9,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Avatar + user info
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _gold,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: _maroon,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (username != null)
                      Text(
                        username!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    if (email != null)
                      Text(
                        email!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _gold.withValues(alpha: 0.5),
                          width: 0.7,
                        ),
                      ),
                      child: Text(
                        role.toUpperCase(),
                        style: const TextStyle(
                          color: _gold,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
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
    );
  }
}

class _NavTile extends StatefulWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.onTap,
          onHover: (v) => setState(() => _hovered = v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _hovered
                  ? const Color(0xFF7F0000).withValues(alpha: 0.07)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: _hovered
                      ? const Color(0xFF7F0000)
                      : const Color(0xFF555555),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _hovered
                          ? const Color(0xFF7F0000)
                          : const Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: _hovered
                      ? const Color(0xFF7F0000)
                      : const Color(0xFFBBBBBB),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatefulWidget {
  const _LogoutTile({required this.onLogout});
  final VoidCallback onLogout;

  @override
  State<_LogoutTile> createState() => _LogoutTileState();
}

class _LogoutTileState extends State<_LogoutTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.onLogout,
          onHover: (v) => setState(() => _hovered = v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: _hovered
                  ? Colors.red.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: _hovered ? Colors.red : Colors.red.shade300,
                ),
                const SizedBox(width: 14),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _hovered ? Colors.red : Colors.red.shade300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
