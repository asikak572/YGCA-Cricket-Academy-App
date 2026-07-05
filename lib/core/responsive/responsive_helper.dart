import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';

class ResponsiveHelper {
  ResponsiveHelper._();

  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isMobile(BuildContext context) {
    return width(context) < ResponsiveBreakpoints.mobile;
  }

  static bool isTablet(BuildContext context) {
    return width(context) >= ResponsiveBreakpoints.mobile &&
        width(context) < ResponsiveBreakpoints.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return width(context) >= ResponsiveBreakpoints.tablet;
  }

  static double maxContentWidth(BuildContext context) {
    if (isDesktop(context)) return ResponsiveBreakpoints.desktop;
    if (isTablet(context)) return 900;
    return width(context);
  }
}