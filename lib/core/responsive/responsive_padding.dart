import 'package:flutter/material.dart';
import 'responsive_helper.dart';

class ResponsivePadding {
  ResponsivePadding._();

  static double horizontal(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 32;
    if (ResponsiveHelper.isTablet(context)) return 24;
    return 16;
  }

  static double vertical(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 24;
    if (ResponsiveHelper.isTablet(context)) return 20;
    return 16;
  }

  static EdgeInsets screen(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: horizontal(context),
      vertical: vertical(context),
    );
  }
}