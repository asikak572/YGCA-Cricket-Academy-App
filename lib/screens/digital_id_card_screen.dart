import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';

class DigitalIdCardScreen extends StatelessWidget {
  final String name;
  final String rollNo;
  final String batch;
  final String parentName;
  final String phone;
  final String photoUrl;

  const DigitalIdCardScreen({
    super.key,
    required this.name,
    required this.rollNo,
    required this.batch,
    required this.parentName,
    required this.phone,
    required this.photoUrl,
  });

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  Color _bg(bool isDark) {
    return isDark ? const Color(0xFF070707) : const Color(0xFFFAFAFA);
  }

  Color _card(bool isDark) {
    return isDark ? const Color(0xFF111111) : Colors.white;
  }

  Color _border(bool isDark) {
    return isDark ? const Color(0xFF3A1515) : const Color(0xFFE2E8F0);
  }

  Color _primaryText(bool isDark) {
    return isDark ? Colors.white : const Color(0xFF111827);
  }

  Color _secondaryText(bool isDark) {
    return isDark ? Colors.white60 : const Color(0xFF64748B);
  }

  String get _initial {
    if (name.trim().isEmpty) return "S";
    return name.trim()[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<String>(
          valueListenable: ThemeController.language,
          builder: (context, language, __) {
            final isDark = mode == ThemeMode.dark;

            return Scaffold(
          backgroundColor: _bg(isDark),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                children: [
                  _topHeader(context, isDark),
                  const SizedBox(height: 16),
                  _idCard(isDark),
                  const SizedBox(height: 18),
                  _noteCard(isDark),
                ],
              ),
            ),
          ),
            );
          },
        );
      },
    );
  }

  Widget _topHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        _circleButton(
          isDark: isDark,
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        Image.asset(
          'assets/images/ygca_logo.jpg',
          width: 46,
          height: 46,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.digitalIdCardTitle.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              Text(
                AppStrings.youngGenCricketAcademy,
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
        ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeController.themeMode,
          builder: (context, mode, _) {
            final dark = mode == ThemeMode.dark;

            return _circleButton(
              isDark: isDark,
              icon: dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              onTap: ThemeController.toggleTheme,
            );
          },
        ),
      ],
    );
  }

  Widget _circleButton({
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _card(isDark),
          shape: BoxShape.circle,
          border: Border.all(color: _border(isDark)),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? red.withOpacity(0.12)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : maroon,
          size: 21,
        ),
      ),
    );
  }

  Widget _idCard(bool isDark) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 370),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? red.withOpacity(0.45) : gold.withOpacity(0.90),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.18) : maroon.withOpacity(0.14),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Column(
          children: [
            _cardHeader(isDark),
            const SizedBox(height: 18),
            _profilePhoto(),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                name.isEmpty ? AppStrings.studentName : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : maroon,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? red.withOpacity(0.16)
                    : maroon.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? red.withOpacity(0.35) : gold.withOpacity(0.8),
                ),
              ),
              child: Text(
                "${AppStrings.rollNo}: ${rollNo.isEmpty ? '-' : rollNo}",
                style: TextStyle(
                  color: isDark ? gold : maroon,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  _infoRow(
                    isDark: isDark,
                    icon: Icons.groups_rounded,
                    label: AppStrings.batch,
                    value: batch,
                  ),
                  _infoRow(
                    isDark: isDark,
                    icon: Icons.family_restroom_rounded,
                    label: AppStrings.parent,
                    value: parentName,
                  ),
                  _infoRow(
                    isDark: isDark,
                    icon: Icons.phone_rounded,
                    label: AppStrings.phone,
                    value: phone,
                  ),
                  _infoRow(
                    isDark: isDark,
                    icon: Icons.verified_rounded,
                    label: AppStrings.status,
                    value: AppStrings.active,
                    valueColor: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _cardFooter(isDark),
          ],
        ),
      ),
    );
  }

  Widget _cardHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.black,
                  darkMaroon,
                  red.withOpacity(0.48),
                ]
              : [
                  maroon,
                  darkMaroon,
                  Colors.black.withOpacity(0.85),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -28,
            child: Icon(
              Icons.sports_cricket_rounded,
              color: Colors.white.withOpacity(0.08),
              size: 105,
            ),
          ),
          Column(
            children: [
              Image.asset(
                'assets/images/ygca_logo.jpg',
                height: 66,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.youngGenCricketAcademy.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: gold.withOpacity(0.85)),
                ),
                child: Text(
                AppStrings.studentIdCard.toUpperCase(),
                  style: TextStyle(
                    color: gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profilePhoto() {
    return Container(
      width: 104,
      height: 104,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [gold, maroon, red],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: maroon,
        backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
        child: photoUrl.isEmpty
            ? Text(
                _initial,
                style: const TextStyle(
                  color: gold,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                ),
              )
            : null,
      ),
    );
  }

  Widget _infoRow({
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.035) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isDark
                ? red.withOpacity(0.14)
                : maroon.withOpacity(0.08),
            child: Icon(
              icon,
              color: isDark ? gold : maroon,
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: _secondaryText(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value.isEmpty ? "-" : value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor ?? _primaryText(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardFooter(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  darkMaroon,
                  Colors.black,
                ]
              : [
                  maroon,
                  darkMaroon,
                ],
        ),
      ),
      child: Column(
        children: [
          Text(
                AppStrings.disciplinePassionSuccess,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: gold,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            AppStrings.digitalIdValidForVerification,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.62),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteCard(bool isDark) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 370),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border(isDark)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: isDark ? gold : maroon,
            size: 25,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.useIdCardForVerification,
              style: TextStyle(
                color: _secondaryText(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}