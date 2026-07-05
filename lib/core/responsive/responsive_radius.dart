import 'package:flutter/material.dart';
import 'responsive_helper.dart';

class ResponsiveRadius {
  ResponsiveRadius._();

  static double small(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 14;
    if (ResponsiveHelper.isTablet(context)) return 12;
    return 10;
  }

  static double medium(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 22;
    if (ResponsiveHelper.isTablet(context)) return 20;
    return 18;
  }

  static double large(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 34;
    if (ResponsiveHelper.isTablet(context)) return 32;
    return 30;
  }
}