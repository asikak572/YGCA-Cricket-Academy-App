import 'package:flutter/material.dart';

import '../../theme/theme_controller.dart';
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

  // Kept for compatibility only.
  // We are not showing these old navItems anymore.
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
    return isDark ? const Color(0xFF111111) : Colors.white;
  }

  Color _border(bool isDark) {
    return isDark ? red.withOpacity(0.22) : const Color(0xFFE2E8F0);
  }

  Color _primaryText(bool isDark) {
    return isDark ? Colors.white : const Color(0xFF111827);
  }

  Color _secondaryText(bool isDark) {
    return isDark ? Colors.white60 : const Color(0xFF64748B);
  }

  void _openProfile(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();

    Future.delayed(const Duration(milliseconds: 180), () {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
        ),
      );
    });
  }

  void _openSettings(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();

    Future.delayed(const Duration(milliseconds: 180), () {
      showModalBottomSheet(
        context: navigator.context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) {
          return ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeMode,
            builder: (context, mode, _) {
              final isDark = mode == ThemeMode.dark;

              return Container(
                margin: const EdgeInsets.all(14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _card(isDark),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: isDark
                        ? red.withOpacity(0.35)
                        : gold.withOpacity(0.8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? red.withOpacity(0.16)
                          : Colors.black.withOpacity(0.10),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: isDark
                                ? red.withOpacity(0.15)
                                : gold.withOpacity(0.18),
                            child: Icon(
                              Icons.settings_rounded,
                              color: isDark ? gold : maroon,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Settings",
                                  style: TextStyle(
                                    color: _primaryText(isDark),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  "Theme and account preferences",
                                  style: TextStyle(
                                    color: _secondaryText(isDark),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _settingsTile(
                        isDark: isDark,
                        icon: isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        title: isDark
                            ? "Switch to Light Mode"
                            : "Switch to Dark Mode",
                        subtitle: "Change app appearance",
                        onTap: ThemeController.toggleTheme,
                      ),
                      const SizedBox(height: 10),
                      _settingsTile(
                        isDark: isDark,
                        icon: Icons.verified_user_rounded,
                        title: role,
                        subtitle: email ?? "YGCA account",
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        return Drawer(
          backgroundColor: _bg(isDark),
          width: MediaQuery.of(context).size.width < 360 ? 292 : 314,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF050505),
                        const Color(0xFF090909),
                        const Color(0xFF120404),
                      ]
                    : [
                        Colors.white,
                        const Color(0xFFFAFAFA),
                        const Color(0xFFFFFBF2),
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _drawerHeader(isDark),
                  const SizedBox(height: 14),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      children: [
                        _drawerTile(
                          isDark: isDark,
                          icon: Icons.person_rounded,
                          label: "Profile",
                          subtitle: "View and edit account",
                          onTap: () => _openProfile(context),
                        ),
                        _drawerTile(
                          isDark: isDark,
                          icon: Icons.settings_rounded,
                          label: "Settings",
                          subtitle: "Theme and preferences",
                          onTap: () => _openSettings(context),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  if (onLogout != null) _logoutTile(context, isDark),

                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _drawerHeader(bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF111111),
                  const Color(0xFF1A0606),
                  darkMaroon,
                ]
              : [
                  Colors.white,
                  const Color(0xFFFFFBF2),
                  const Color(0xFFFFF4CC),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? gold.withOpacity(0.45) : gold.withOpacity(0.9),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.14) : maroon.withOpacity(0.08),
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
                  color: isDark ? Colors.black.withOpacity(0.35) : Colors.white,
                  borderRadius: BorderRadius.circular(17),
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
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "YGCA",
                      style: TextStyle(
                        color: isDark ? gold : maroon,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                    Text(
                      "Young Gen Cricket Academy",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.28)
                  : Colors.white.withOpacity(0.82),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.10)
                    : gold.withOpacity(0.45),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: gold,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: maroon,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
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
                          fontSize: 15,
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
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? gold.withOpacity(0.13)
                              : maroon.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: gold.withOpacity(0.60),
                          ),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: TextStyle(
                            color: isDark ? gold : maroon,
                            fontSize: 10.5,
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
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              color: _card(isDark),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border(isDark)),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.24)
                      : Colors.black.withOpacity(0.035),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: isDark
                        ? red.withOpacity(0.10)
                        : gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isDark
                          ? red.withOpacity(0.24)
                          : gold.withOpacity(0.65),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isDark ? gold : maroon,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _primaryText(isDark),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _secondaryText(isDark),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white60 : maroon,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _settingsTile({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0B0B0B) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border(isDark)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDark ? gold : maroon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _primaryText(isDark),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _secondaryText(isDark),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            color: isDark ? red.withOpacity(0.10) : Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.redAccent.withOpacity(0.42)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.redAccent.withOpacity(0.28),
                  ),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.redAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}