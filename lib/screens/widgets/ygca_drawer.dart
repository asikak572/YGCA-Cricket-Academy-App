import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../theme/theme_controller.dart';
import '../../core/language/app_strings.dart';
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
  // Drawer will ignore old module navItems.
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

  void _copyText(BuildContext context, String value, String message) {
    Clipboard.setData(ClipboardData(text: value));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }


  void _showMessage(
    BuildContext context,
    String message, {
    Color color = Colors.green,
  }) {
    final isDark = ThemeController.themeMode.value == ThemeMode.dark;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _card(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: color.withOpacity(0.45),
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 900), () {
      final navigator = Navigator.of(context, rootNavigator: true);
      if (navigator.canPop()) {
        navigator.pop();
      }
    });
  }

  Future<void> _sendPasswordResetEmail(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email?.trim() ?? email?.trim() ?? '';

    if (userEmail.isEmpty) {
      _showMessage(
        context,
        "No registered email found for this account.",
        color: Colors.red,
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail);

      if (!context.mounted) return;

      _showMessage(
        context,
        "Password reset link sent to $userEmail",
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      String message = "Unable to send password reset email.";

      if (e.code == 'invalid-email') {
        message = "The registered email address is invalid.";
      } else if (e.code == 'user-not-found') {
        message = "No account found for this email.";
      } else if (e.message != null && e.message!.trim().isNotEmpty) {
        message = e.message!;
      }

      _showMessage(context, message, color: Colors.red);
    } catch (_) {
      if (!context.mounted) return;

      _showMessage(
        context,
        "Something went wrong. Please try again.",
        color: Colors.red,
      );
    }
  }

  Future<void> _confirmPasswordReset(BuildContext context, bool isDark) async {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email?.trim() ?? email?.trim() ?? '';

    if (userEmail.isEmpty) {
      _showMessage(
        context,
        "No registered email found for this account.",
        color: Colors.red,
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _card(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isDark ? red.withOpacity(0.35) : gold.withOpacity(0.75),
            ),
          ),
          title: Text(
            "Change Password",
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            "A password reset link will be sent to:\n$userEmail",
            style: TextStyle(
              color: _secondaryText(isDark),
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? red : maroon,
                foregroundColor: isDark ? Colors.white : gold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                "Send Link",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _sendPasswordResetEmail(context);
    }
  }

  void _toggleLanguage(BuildContext context) {
    ThemeController.toggleLanguage();

    _showMessage(
      context,
      "Language changed to ${ThemeController.language.value}",
    );
  }

  void _toggleCompactMode(BuildContext context) {
    ThemeController.toggleCompactMode();

    _showMessage(
      context,
      ThemeController.compactMode.value
          ? "Compact Mode enabled"
          : "Compact Mode disabled",
    );
  }

  void _toggleLargeTextMode(BuildContext context) {
    ThemeController.toggleLargeTextMode();

    _showMessage(
      context,
      ThemeController.largeTextMode.value
          ? "Large Text Mode enabled"
          : "Large Text Mode disabled",
    );
  }

  void _showFontStyleSelector(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return ValueListenableBuilder<String>(
          valueListenable: ThemeController.fontFamily,
          builder: (context, selectedFont, _) {
            return _bottomSheetContainer(
              isDark: isDark,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _bottomSheetHandle(isDark),
                  const SizedBox(height: 18),
                  _sheetHeader(
                    isDark: isDark,
                    icon: Icons.font_download_rounded,
                    title: "Font Style",
                    subtitle: "Choose your preferred app font",
                  ),
                  const SizedBox(height: 18),
                  _settingsTile(
                    isDark: isDark,
                    icon: Icons.text_fields_rounded,
                    title: "Default",
                    subtitle: "System default font",
                    trailing: selectedFont == "Default" ? "Selected" : "",
                    onTap: () {
                      ThemeController.setFontFamily("Default");
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 10),
                  _settingsTile(
                    isDark: isDark,
                    icon: Icons.text_fields_rounded,
                    title: "Poppins",
                    subtitle: "Modern rounded font",
                    trailing: selectedFont == "Poppins" ? "Selected" : "",
                    onTap: () {
                      ThemeController.setFontFamily("Poppins");
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 10),
                  _settingsTile(
                    isDark: isDark,
                    icon: Icons.text_fields_rounded,
                    title: "Noto Sans",
                    subtitle: "Best for English, Tamil and Hindi",
                    trailing: selectedFont == "NotoSans" ? "Selected" : "",
                    onTap: () {
                      ThemeController.setFontFamily("NotoSans");
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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

              return _bottomSheetContainer(
                isDark: isDark,
                child: ValueListenableBuilder<String>(
                  valueListenable: ThemeController.language,
                  builder: (context, language, _) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: ThemeController.compactMode,
                      builder: (context, compact, _) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: ThemeController.largeTextMode,
                          builder: (context, largeText, _) {
                            return ValueListenableBuilder<String>(
                              valueListenable: ThemeController.fontFamily,
                              builder: (context, fontFamily, _) {
                                final gap = compact ? 8.0 : 12.0;

                                return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _bottomSheetHandle(isDark),
                                const SizedBox(height: 18),
                                _sheetHeader(
                                  isDark: isDark,
                                  icon: Icons.settings_rounded,
                                  title: AppStrings.settings,
                                  subtitle: AppStrings.appPreferences,
                                ),
                                const SizedBox(height: 18),

                                _sheetSectionTitle(AppStrings.appearance, isDark),
                                _settingsTile(
                                  isDark: isDark,
                                  icon: isDark
                                      ? Icons.light_mode_rounded
                                      : Icons.dark_mode_rounded,
                                  title: isDark
                                      ? AppStrings.switchToLight
                                      : AppStrings.switchToDark,
                                  subtitle: AppStrings.changeAppearance,
                                  trailing: isDark ? "Dark" : "Light",
                                  onTap: ThemeController.toggleTheme,
                                ),

                                SizedBox(height: gap),
                                _sheetSectionTitle(AppStrings.language, isDark),
                                _settingsTile(
                                  isDark: isDark,
                                  icon: Icons.language_rounded,
                                  title: AppStrings.language,
                                  subtitle: "English / தமிழ் / हिन्दी",
                                  trailing: language,
                                  onTap: () => _toggleLanguage(context),
                                ),

                                SizedBox(height: gap),
                                _sheetSectionTitle(AppStrings.appPreferencesTitle, isDark),
                                _settingsTile(
                                  isDark: isDark,
                                  icon: Icons.view_compact_rounded,
                                  title: AppStrings.compactMode,
                                  subtitle: AppStrings.reduceSpacing,
                                  trailing: compact ? AppStrings.on : AppStrings.off,
                                  onTap: () => _toggleCompactMode(context),
                                ),
                                const SizedBox(height: 10),
                                _settingsTile(
                                  isDark: isDark,
                                  icon: Icons.text_fields_rounded,
                                  title: AppStrings.largeTextMode,
                                  subtitle: AppStrings.betterReadability,
                                  trailing: largeText ? AppStrings.on : AppStrings.off,
                                  onTap: () => _toggleLargeTextMode(context),
                                ),
                                const SizedBox(height: 10),
_settingsTile(
  isDark: isDark,
  icon: Icons.font_download_rounded,
  title: "Font Style",
  subtitle: "Default / Poppins / Noto Sans",
  trailing: ThemeController.fontFamily.value == "NotoSans"
      ? "Noto Sans"
      : ThemeController.fontFamily.value,
  onTap: () => _showFontStyleSelector(context, isDark),
),

                                SizedBox(height: gap),
                                _sheetSectionTitle(AppStrings.privacySecurity, isDark),
                                _settingsTile(
                                  isDark: isDark,
                                  icon: Icons.lock_reset_rounded,
                                  title: AppStrings.changePassword,
                                  subtitle: AppStrings.resetLink,
                                  trailing: AppStrings.email,
                                  onTap: () =>
                                      _confirmPasswordReset(context, isDark),
                                ),
                                const SizedBox(height: 10),
                                _settingsTile(
                                  isDark: isDark,
                                  icon: Icons.verified_user_rounded,
                                  title: AppStrings.loginStatus,
                                  subtitle:
                                      "Signed in as ${role.toUpperCase()}",
                                  trailing: AppStrings.active,
                                  onTap: () {
                                    _showMessage(
                                      context,
                                      "Your account is currently active.",
                                    );
                                  },
                                ),

                                SizedBox(height: gap),
                                _sheetSectionTitle(AppStrings.about, isDark),
                                _settingsTile(
                                  isDark: isDark,
                                  icon: Icons.info_rounded,
                                  title: AppStrings.appVersion,
                                  subtitle: "YGCA Management System",
                                  trailing: "1.0.0",
                                  onTap: () {
                                    Navigator.pop(context);
                                    Future.delayed(
                                      const Duration(milliseconds: 180),
                                      () => _openAboutApp(navigator.context),
                                    );
                                  },
                                ),
                              ],
                            );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      );
    });
  }

  void _openHelpSupport(BuildContext context) {
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

              return _bottomSheetContainer(
                isDark: isDark,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _bottomSheetHandle(isDark),
                    const SizedBox(height: 18),
                    _sheetHeader(
                      isDark: isDark,
                      icon: Icons.support_agent_rounded,
                      title: "Help & Support",
                      subtitle: "Contact academy support team",
                    ),
                    const SizedBox(height: 18),

                    _supportTile(
                      context: context,
                      isDark: isDark,
                      icon: Icons.call_rounded,
                      title: "Call Academy",
                      subtitle: "9941411006",
                      color: Colors.green,
                      copyValue: "9941411006",
                    ),
                    const SizedBox(height: 10),
                    _supportTile(
                      context: context,
                      isDark: isDark,
                      icon: Icons.call_rounded,
                      title: "Alternate Number",
                      subtitle: "8939299555",
                      color: Colors.blueAccent,
                      copyValue: "8939299555",
                    ),
                    const SizedBox(height: 10),
                    _supportTile(
                      context: context,
                      isDark: isDark,
                      icon: Icons.chat_rounded,
                      title: "WhatsApp Support",
                      subtitle: "+91 9941411006",
                      color: Colors.green,
                      copyValue: "+919941411006",
                    ),
                    const SizedBox(height: 10),
                    _supportTile(
                      context: context,
                      isDark: isDark,
                      icon: Icons.report_problem_rounded,
                      title: "Report Issue",
                      subtitle: "Share app issue with academy admin",
                      color: Colors.orange,
                      copyValue: "Report issue to YGCA support",
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    });
  }

  void _openAboutApp(BuildContext context) {
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

              return _bottomSheetContainer(
                isDark: isDark,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _bottomSheetHandle(isDark),
                    const SizedBox(height: 18),
                    Container(
                      width: 82,
                      height: 82,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: gold.withOpacity(0.75),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? red.withOpacity(0.14)
                                : maroon.withOpacity(0.10),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/ygca_logo.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "YGCA Management System",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Young Gen Cricket Academy",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? gold : maroon,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _aboutInfoTile(
                      isDark: isDark,
                      icon: Icons.verified_rounded,
                      title: "Version",
                      value: "1.0.0",
                    ),
                    const SizedBox(height: 10),
                    _aboutInfoTile(
                      isDark: isDark,
                      icon: Icons.storage_rounded,
                      title: "Backend",
                      value: "Firebase",
                    ),
                    const SizedBox(height: 10),
                    _aboutInfoTile(
                      isDark: isDark,
                      icon: Icons.security_rounded,
                      title: "Access",
                      value: "Role Based",
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "Designed for academy management, attendance, fees, schedules, performance and parent-student communication.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
                          subtitle: "Theme, language, password and security",
                          onTap: () => _openSettings(context),
                        ),
                        _drawerTile(
                          isDark: isDark,
                          icon: Icons.support_agent_rounded,
                          label: "Help & Support",
                          subtitle: "Call, WhatsApp and report issue",
                          onTap: () => _openHelpSupport(context),
                        ),
                        _drawerTile(
                          isDark: isDark,
                          icon: Icons.info_rounded,
                          label: "About App",
                          subtitle: "Version and academy info",
                          onTap: () => _openAboutApp(context),
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

  Widget _bottomSheetContainer({
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? red.withOpacity(0.35) : gold.withOpacity(0.8),
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
        child: SingleChildScrollView(
          child: child,
        ),
      ),
    );
  }

  Widget _bottomSheetHandle(bool isDark) {
    return Container(
      width: 44,
      height: 4,
      decoration: BoxDecoration(
        color: isDark ? Colors.white24 : Colors.black12,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _sheetHeader({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor:
              isDark ? red.withOpacity(0.15) : gold.withOpacity(0.18),
          child: Icon(
            icon,
            color: isDark ? gold : maroon,
          ),
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
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                subtitle,
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
    );
  }

  Widget _sheetSectionTitle(String title, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: TextStyle(
            color: isDark ? gold : maroon,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
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
    required String trailing,
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
            Text(
              trailing,
              style: TextStyle(
                color: isDark ? gold : maroon,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _supportTile({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String copyValue,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        _copyText(
          context,
          copyValue,
          "$title copied",
        );
      },
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
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.14),
              child: Icon(
                icon,
                color: color,
                size: 21,
              ),
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
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: _secondaryText(isDark),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.copy_rounded,
              color: isDark ? gold : maroon,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }

  Widget _aboutInfoTile({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
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
            size: 21,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: _secondaryText(isDark),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoutTile(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                backgroundColor: _card(isDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color:
                        isDark ? red.withOpacity(0.35) : gold.withOpacity(0.75),
                  ),
                ),
                title: Text(
                  "Logout",
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                content: Text(
                  "Are you sure you want to logout?",
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text(
                      "Logout",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              );
            },
          );

          if (shouldLogout == true) {
            final navigator = Navigator.of(context);
            navigator.pop();

            Future.delayed(const Duration(milliseconds: 180), () {
              onLogout!();
            });
          }
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