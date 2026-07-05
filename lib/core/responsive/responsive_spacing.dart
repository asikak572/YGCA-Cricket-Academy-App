import 'package:flutter/material.dart';
import 'responsive_helper.dart';

class ResponsiveSpacing {
  ResponsiveSpacing._();

  static double small(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 12;
    if (ResponsiveHelper.isTablet(context)) return 10;
    return 8;
  }

  static double medium(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 20;
    if (ResponsiveHelper.isTablet(context)) return 16;
    return 14;
  }

  static double large(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 28;
    if (ResponsiveHelper.isTablet(context)) return 24;
    return 20;
  }
}