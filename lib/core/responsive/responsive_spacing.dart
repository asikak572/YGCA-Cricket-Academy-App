import 'package:flutter/material.dart';
import '../../theme/theme_controller.dart';
import 'responsive_helper.dart';

class ResponsiveSpacing {
  ResponsiveSpacing._();

  static double _compactFactor() {
    return ThemeController.compactMode.value ? 0.75 : 1.0;
  }

  static double small(BuildContext context) {
    final base = ResponsiveHelper.isDesktop(context)
        ? 12.0
        : ResponsiveHelper.isTablet(context)
            ? 10.0
            : 8.0;

    return base * _compactFactor();
  }

  static double medium(BuildContext context) {
    final base = ResponsiveHelper.isDesktop(context)
        ? 20.0
        : ResponsiveHelper.isTablet(context)
            ? 16.0
            : 14.0;

    return base * _compactFactor();
  }

  static double large(BuildContext context) {
    final base = ResponsiveHelper.isDesktop(context)
        ? 28.0
        : ResponsiveHelper.isTablet(context)
            ? 24.0
            : 20.0;

    return base * _compactFactor();
  }
}