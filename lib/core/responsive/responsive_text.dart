import 'package:flutter/material.dart';

import '../../theme/theme_controller.dart';

class ResponsiveText {
  ResponsiveText._();

  static String get _language {
    return ThemeController.language.value.toLowerCase();
  }

  static bool get _isTamil {
    return _language == 'ta' ||
        _language == 'tamil' ||
        _language == 'தமிழ்';
  }
  static String get fontFamily {
  if (_isTamil) {
    return 'NotoSansTamil';
  }

  return 'Poppins';
}
  // General title used in cards, headers and dashboard sections
static double title(BuildContext context) {
  return _size(
    context,
    18,
    tamil: 0.87,
    hindi: 0.92,
    min: 13,
    max: 21,
  );
}

// Very small text used in badges, compact labels and bottom areas
static double tiny(BuildContext context) {
  return _size(
    context,
    9,
    tamil: 0.95,
    hindi: 0.98,
    min: 7.5,
    max: 10.5,
  );
}

  static bool get _isHindi {
    return _language == 'hi' ||
        _language == 'hindi' ||
        _language == 'हिंदी' ||
        _language == 'हिन्दी';
  }

  static double _screenScale(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 340) return 0.88;
    if (width < 370) return 0.92;
    if (width < 410) return 0.96;
    if (width < 600) return 1.00;
    if (width < 900) return 1.08;

    return 1.14;
  }

  static double _languageScale({
    double tamil = 0.90,
    double hindi = 0.94,
  }) {
    if (_isTamil) return tamil;
    if (_isHindi) return hindi;

    return 1.0;
  }

  static double _size(
    BuildContext context,
    double baseSize, {
    double tamil = 0.90,
    double hindi = 0.94,
    double min = 8,
    double max = 40,
  }) {
    final result = baseSize *
        _screenScale(context) *
        _languageScale(
          tamil: tamil,
          hindi: hindi,
        );

    return result.clamp(min, max).toDouble();
  }

  // Very large dashboard hero heading
  static double hero(BuildContext context) {
    return _size(
      context,
      34,
      tamil: 0.76,
      hindi: 0.84,
      min: 22,
      max: 38,
    );
  }

  // Secondary text shown inside hero sections
  static double heroSubtitle(BuildContext context) {
    return _size(
      context,
      22,
      tamil: 0.82,
      hindi: 0.88,
      min: 15,
      max: 25,
    );
  }

  // Main screen title or AppBar title
  static double pageTitle(BuildContext context) {
    return _size(
      context,
      24,
      tamil: 0.84,
      hindi: 0.89,
      min: 17,
      max: 27,
    );
  }

  // Section headings
  static double heading(BuildContext context) {
    return _size(
      context,
      20,
      tamil: 0.86,
      hindi: 0.91,
      min: 14,
      max: 23,
    );
  }

  static double sectionTitle(BuildContext context) {
    return _size(
      context,
      18,
      tamil: 0.87,
      hindi: 0.92,
      min: 13,
      max: 21,
    );
  }

  // Standard card heading
  static double cardTitle(BuildContext context) {
    return _size(
      context,
      15,
      tamil: 0.88,
      hindi: 0.93,
      min: 11,
      max: 17,
    );
  }

  // Smaller description inside a card
  static double cardSubtitle(BuildContext context) {
    return _size(
      context,
      12,
      tamil: 0.92,
      hindi: 0.95,
      min: 9.5,
      max: 14,
    );
  }

  // Normal paragraph and form text
  static double body(BuildContext context) {
    return _size(
      context,
      14,
      tamil: 0.93,
      hindi: 0.96,
      min: 11,
      max: 16,
    );
  }

  // Slightly smaller normal text
  static double bodySmall(BuildContext context) {
    return _size(
      context,
      12,
      tamil: 0.94,
      hindi: 0.97,
      min: 9.5,
      max: 14,
    );
  }

  // Small labels and secondary details
  static double small(BuildContext context) {
    return _size(
      context,
      11,
      tamil: 0.94,
      hindi: 0.97,
      min: 8.5,
      max: 12.5,
    );
  }

  static double caption(BuildContext context) {
    return _size(
      context,
      10,
      tamil: 0.95,
      hindi: 0.98,
      min: 8,
      max: 11.5,
    );
  }

  // Numbers or values shown in summary cards
  static double statValue(BuildContext context) {
    return _size(
      context,
      22,
      tamil: 0.85,
      hindi: 0.90,
      min: 15,
      max: 25,
    );
  }

  // Label under summary-card numbers
  static double statLabel(BuildContext context) {
    return _size(
      context,
      11,
      tamil: 0.90,
      hindi: 0.94,
      min: 8.5,
      max: 12.5,
    );
  }

  // Button text
  static double button(BuildContext context) {
    return _size(
      context,
      14,
      tamil: 0.92,
      hindi: 0.95,
      min: 11,
      max: 15.5,
    );
  }

  // Bottom navigation labels
  static double bottomNav(BuildContext context) {
    return _size(
      context,
      10.5,
      tamil: 0.90,
      hindi: 0.93,
      min: 8,
      max: 11,
    );
  }

  // TextField labels and entered text
  static double input(BuildContext context) {
    return _size(
      context,
      14,
      tamil: 0.93,
      hindi: 0.96,
      min: 11,
      max: 16,
    );
  }

  // Dialog headings
  static double dialogTitle(BuildContext context) {
    return _size(
      context,
      20,
      tamil: 0.86,
      hindi: 0.91,
      min: 15,
      max: 22,
    );
  }

  // Dialog body text
  static double dialogBody(BuildContext context) {
    return _size(
      context,
      14,
      tamil: 0.93,
      hindi: 0.96,
      min: 11,
      max: 16,
    );
  }
} 