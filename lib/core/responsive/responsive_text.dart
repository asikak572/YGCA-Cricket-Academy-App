import 'package:flutter/material.dart';
import '../../theme/theme_controller.dart';
import 'responsive_helper.dart';

class ResponsiveText {
  ResponsiveText._();

  static double _largeFactor() {
    return ThemeController.largeTextMode.value ? 1.15 : 1.0;
  }

  static double title(BuildContext context) {
    final base = ResponsiveHelper.isDesktop(context)
        ? 42.0
        : ResponsiveHelper.isTablet(context)
            ? 38.0
            : 35.0;

    return base * _largeFactor();
  }

  static double heading(BuildContext context) {
    final base = ResponsiveHelper.isDesktop(context)
        ? 22.0
        : ResponsiveHelper.isTablet(context)
            ? 20.0
            : 18.0;

    return base * _largeFactor();
  }

  static double body(BuildContext context) {
    final base = ResponsiveHelper.isDesktop(context)
        ? 16.0
        : ResponsiveHelper.isTablet(context)
            ? 15.0
            : 14.0;

    return base * _largeFactor();
  }

  static double small(BuildContext context) {
    final base = ResponsiveHelper.isDesktop(context)
        ? 13.0
        : ResponsiveHelper.isTablet(context)
            ? 12.0
            : 11.0;

    return base * _largeFactor();
  }

  static double tiny(BuildContext context) {
    final base = ResponsiveHelper.isDesktop(context)
        ? 11.0
        : ResponsiveHelper.isTablet(context)
            ? 10.0
            : 9.5;

    return base * _largeFactor();
  }
}