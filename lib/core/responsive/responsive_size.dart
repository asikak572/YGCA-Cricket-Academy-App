import 'package:flutter/material.dart';
import '../../theme/theme_controller.dart';
import 'responsive_helper.dart';

class ResponsiveSize {
  ResponsiveSize._();

  static double _compactFactor() {
    return ThemeController.compactMode.value ? 0.85 : 1.0;
  }

  static double heroHeight(BuildContext context) {
    double value;

    if (ResponsiveHelper.isDesktop(context)) {
      value = 340;
    } else if (ResponsiveHelper.isTablet(context)) {
      value = 290;
    } else {
      value = 248;
    }

    return value * _compactFactor();
  }

  static double circleButton(BuildContext context) {
    double value;

    if (ResponsiveHelper.isDesktop(context)) {
      value = 46;
    } else if (ResponsiveHelper.isTablet(context)) {
      value = 44;
    } else {
      value = 42;
    }

    return value * _compactFactor();
  }

  static double logo(BuildContext context) {
    double value;

    if (ResponsiveHelper.isDesktop(context)) {
      value = 54;
    } else if (ResponsiveHelper.isTablet(context)) {
      value = 50;
    } else {
      value = 46;
    }

    return value * _compactFactor();
  }

  static double quickActionHeight(BuildContext context) {
    double value;

    if (ResponsiveHelper.isDesktop(context)) {
      value = 104;
    } else if (ResponsiveHelper.isTablet(context)) {
      value = 98;
    } else {
      value = 92;
    }

    return value * _compactFactor();
  }

  static double quickActionWidth(BuildContext context) {
    double value;

    if (ResponsiveHelper.isDesktop(context)) {
      value = 108;
    } else if (ResponsiveHelper.isTablet(context)) {
      value = 100;
    } else {
      value = 92;
    }

    return value * _compactFactor();
  }
}