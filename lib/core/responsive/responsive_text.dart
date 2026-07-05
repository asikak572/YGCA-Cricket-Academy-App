import 'package:flutter/material.dart';
import 'responsive_helper.dart';

class ResponsiveText {
  ResponsiveText._();

  static double title(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 42;
    if (ResponsiveHelper.isTablet(context)) return 38;
    return 35;
  }

  static double heading(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 22;
    if (ResponsiveHelper.isTablet(context)) return 20;
    return 18;
  }

  static double body(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 16;
    if (ResponsiveHelper.isTablet(context)) return 15;
    return 14;
  }

  static double small(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 13;
    if (ResponsiveHelper.isTablet(context)) return 12;
    return 11;
  }

  static double tiny(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 11;
    if (ResponsiveHelper.isTablet(context)) return 10;
    return 9.5;
  }
}