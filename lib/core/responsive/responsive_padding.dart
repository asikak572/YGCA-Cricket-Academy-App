import 'package:flutter/material.dart';
import '../../theme/theme_controller.dart';
import 'responsive_helper.dart';

class ResponsivePadding {
  ResponsivePadding._();

  static double _compactFactor() {
    return ThemeController.compactMode.value ? 0.75 : 1.0;
  }

  static double horizontal(BuildContext context) {
    double value;

    if (ResponsiveHelper.isDesktop(context)) {
      value = 32;
    } else if (ResponsiveHelper.isTablet(context)) {
      value = 24;
    } else {
      value = 16;
    }

    return value * _compactFactor();
  }

  static double vertical(BuildContext context) {
    double value;

    if (ResponsiveHelper.isDesktop(context)) {
      value = 24;
    } else if (ResponsiveHelper.isTablet(context)) {
      value = 20;
    } else {
      value = 16;
    }

    return value * _compactFactor();
  }

  static EdgeInsets screen(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: horizontal(context),
      vertical: vertical(context),
    );
  }
}