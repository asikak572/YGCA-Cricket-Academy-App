import 'package:flutter/material.dart';
import 'responsive_helper.dart';

class ResponsiveGrid {
  ResponsiveGrid._();

  static int dashboardCount(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 4;
    if (ResponsiveHelper.isTablet(context)) return 3;
    return 2;
  }

  static double dashboardCardRatio(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 2.0;
    if (ResponsiveHelper.isTablet(context)) return 2.15;
    return 2.35;
  }

  static int moduleCount(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 4;
    if (ResponsiveHelper.isTablet(context)) return 3;
    return 2;
  }
}