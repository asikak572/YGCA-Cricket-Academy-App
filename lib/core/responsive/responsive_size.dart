import 'package:flutter/material.dart';
import 'responsive_helper.dart';

class ResponsiveSize {
  ResponsiveSize._();

  static double heroHeight(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 340;
    if (ResponsiveHelper.isTablet(context)) return 290;
    return 248;
  }

  static double circleButton(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 46;
    if (ResponsiveHelper.isTablet(context)) return 44;
    return 42;
  }

  static double logo(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 54;
    if (ResponsiveHelper.isTablet(context)) return 50;
    return 46;
  }

  static double quickActionHeight(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 104;
    if (ResponsiveHelper.isTablet(context)) return 98;
    return 92;
  }

  static double quickActionWidth(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 108;
    if (ResponsiveHelper.isTablet(context)) return 100;
    return 92;
  }
}