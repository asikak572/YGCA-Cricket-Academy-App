import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium compact sticky AppBar for all four YGCA dashboard screens.
///
/// Design:
/// - Left: YGCA logo image + "YGCA" text in gold + subtitle
/// - Right: notification bell (with badge) + action button (logout/avatar)
/// - Compact height — does NOT scroll with content (proper Scaffold.appBar)
/// - Hamburger icon opens the [YgcaDrawer] via Scaffold.of(context).openDrawer()
///
/// Usage:
/// ```dart
/// Scaffold(
///   appBar: YgcaDashboardAppBar(
///     role: "STUDENT",
///     username: name,
///     onLogout: () => _logout(context),
///   ),
///   drawer: YgcaDrawer(...),
///   body: ...,
/// )
/// ```
class YgcaDashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const YgcaDashboardAppBar({
    super.key,
    required this.role,
    this.username,
    this.onLogout,
    this.showProfileAvatar = false,
    this.notificationCount = 0,
    this.onNotificationTap,
  });

  /// Role badge text — e.g. "STUDENT", "COACH", "PARENT", "ADMIN"
  final String role;

  /// Logged-in user's display name (shown as subtitle under role).
  final String? username;

  /// Logout callback. When non-null, a logout icon button is shown.
  /// When null, a profile avatar is shown instead (admin style).
  final VoidCallback? onLogout;

  /// When true, shows a profile CircleAvatar instead of a logout button.
  final bool showProfileAvatar;

  /// Notification badge count. 0 = no badge shown.
  final int notificationCount;

  /// Tap handler for the notification bell.
  final VoidCallback? onNotificationTap;

  static const Color _maroon = Color(0xFF7F0000);
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _maroonDark = Color(0xFF5A0000);

  static const double _barHeight = 62.0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _maroon,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: _maroon,
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: _barHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Hamburger (opens Drawer) ───────────────────────────
                  _AnimatedMenuButton(),

                  const SizedBox(width: 4),

                  // ── YGCA Logo + Branding ───────────────────────────────
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            'assets/images/ygca_logo.jpg',
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: _gold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.sports_cricket,
                                color: _gold,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'YGCA',
                                style: TextStyle(
                                  color: _gold,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  height: 1.1,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _gold.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: _gold.withValues(alpha: 0.4),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      role,
                                      style: const TextStyle(
                                        color: _gold,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  if (username != null) ...[
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        username!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Notification Bell ──────────────────────────────────
                  _NotificationBell(
                    count: notificationCount,
                    onTap: onNotificationTap,
                  ),

                  const SizedBox(width: 2),

                  // ── Logout / Profile ───────────────────────────────────
                  if (onLogout != null)
                    _LogoutButton(onLogout: onLogout!)
                  else if (showProfileAvatar)
                    _ProfileAvatar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    // SafeArea top padding is added at runtime; we give the base bar height.
    // Flutter's Scaffold accounts for status bar on top of preferredSize.
    return const Size.fromHeight(_barHeight);
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ────────────────────────────────────────────────────────────────────────────

/// Animated hamburger icon that opens the Scaffold drawer.
class _AnimatedMenuButton extends StatefulWidget {
  @override
  State<_AnimatedMenuButton> createState() => _AnimatedMenuButtonState();
}

class _AnimatedMenuButtonState extends State<_AnimatedMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.85,
      upperBound: 1.0,
    )..value = 1.0;
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    _ctrl.reverse().then((_) {
      if (mounted) {
        _ctrl.forward();
        Scaffold.of(context).openDrawer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                _MenuLine(width: 18),
                _MenuLine(width: 14),
                _MenuLine(width: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuLine extends StatelessWidget {
  const _MenuLine({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 2,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Notification bell with optional orange badge count.
class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.count, this.onTap});
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24,
            ),
            if (count > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF7F0000),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onLogout});
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Logout',
      child: InkWell(
        onTap: onLogout,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.logout_rounded, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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

class _ProfileAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
    );
  }
}
