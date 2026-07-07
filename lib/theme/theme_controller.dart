import 'package:flutter/material.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.dark);

  static final ValueNotifier<bool> compactMode =
      ValueNotifier<bool>(false);

  static final ValueNotifier<bool> largeTextMode =
      ValueNotifier<bool>(false);

  static final ValueNotifier<String> language =
      ValueNotifier<String>("English");

  static void toggleTheme() {
    themeMode.value =
        themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  static void toggleCompactMode() {
    compactMode.value = !compactMode.value;
  }

  static void toggleLargeTextMode() {
    largeTextMode.value = !largeTextMode.value;
  }

 static void toggleLanguage() {
  if (language.value == "English") {
    language.value = "தமிழ்";
  } else if (language.value == "தமிழ்") {
    language.value = "हिन्दी";
  } else {
    language.value = "English";
  }
}

  static bool get isDark => themeMode.value == ThemeMode.dark;
  static bool get isCompact => compactMode.value;
  static bool get isLargeText => largeTextMode.value;
}