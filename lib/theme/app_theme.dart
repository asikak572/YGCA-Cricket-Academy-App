import 'package:flutter/material.dart';

import '../core/responsive/responsive_text.dart';

class YGCATheme {
  YGCATheme._();

  static const Color ygcaRed = Color(0xFFE50914);
  static const Color ygcaMaroon = Color(0xFF7F0000);
  static const Color ygcaDarkMaroon = Color(0xFF3B0000);
  static const Color ygcaGold = Color(0xFFD4AF37);

  static const Color darkBg = Color(0xFF070707);
  static const Color darkCard = Color(0xFF111111);
  static const Color darkCard2 = Color(0xFF1A0808);

  static const Color lightBg = Color(0xFFFAFAFA);
  static const Color lightCard = Color(0xFFFFFFFF);

  static TextTheme _darkTextTheme() {
    return const TextTheme(
      displayLarge: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, height: 1.10),
      displayMedium: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, height: 1.12),
      headlineLarge: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.15),
      headlineMedium: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, height: 1.18),
      headlineSmall: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, height: 1.20),
      titleLarge: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, height: 1.22),
      titleMedium: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, height: 1.25),
      titleSmall: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700, height: 1.25),
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, height: 1.35),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500, height: 1.35),
      bodySmall: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w500, height: 1.35),
      labelLarge: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
      labelMedium: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700),
      labelSmall: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w700),
    );
  }

  static TextTheme _lightTextTheme() {
    return const TextTheme(
      displayLarge: TextStyle(color: Color(0xFF111827), fontSize: 34, fontWeight: FontWeight.w900, height: 1.10),
      displayMedium: TextStyle(color: Color(0xFF111827), fontSize: 28, fontWeight: FontWeight.w900, height: 1.12),
      headlineLarge: TextStyle(color: Color(0xFF111827), fontSize: 24, fontWeight: FontWeight.w900, height: 1.15),
      headlineMedium: TextStyle(color: Color(0xFF111827), fontSize: 20, fontWeight: FontWeight.w900, height: 1.18),
      headlineSmall: TextStyle(color: Color(0xFF111827), fontSize: 18, fontWeight: FontWeight.w800, height: 1.20),
      titleLarge: TextStyle(color: Color(0xFF111827), fontSize: 18, fontWeight: FontWeight.w900, height: 1.22),
      titleMedium: TextStyle(color: Color(0xFF111827), fontSize: 15, fontWeight: FontWeight.w700, height: 1.25),
      titleSmall: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w700, height: 1.25),
      bodyLarge: TextStyle(color: Color(0xFF111827), fontSize: 16, fontWeight: FontWeight.w500, height: 1.35),
      bodyMedium: TextStyle(color: Color(0xFF334155), fontSize: 14, fontWeight: FontWeight.w500, height: 1.35),
      bodySmall: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500, height: 1.35),
      labelLarge: TextStyle(color: Color(0xFF111827), fontSize: 14, fontWeight: FontWeight.w800),
      labelMedium: TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w700),
      labelSmall: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w700),
    );
  }

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: ygcaRed,
      onPrimary: Colors.white,
      secondary: ygcaGold,
      onSecondary: Colors.black,
      surface: darkCard,
      onSurface: Colors.white,
      error: Colors.redAccent,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: ResponsiveText.fontFamily,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: ygcaRed,
      colorScheme: colorScheme,
      textTheme: _darkTextTheme(),
      dividerColor: const Color(0xFF3A1A1A),
      cardColor: darkCard,
      disabledColor: Colors.white38,
      hintColor: Colors.white38,
      splashColor: ygcaRed.withOpacity(0.12),
      highlightColor: ygcaRed.withOpacity(0.08),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        labelStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
        floatingLabelStyle: const TextStyle(color: ygcaRed, fontWeight: FontWeight.w700),
        hintStyle: const TextStyle(color: Colors.white38, fontWeight: FontWeight.w500),
        errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
        prefixIconColor: ygcaGold,
        suffixIconColor: Colors.white60,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF3A1A1A))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF3A1A1A))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: ygcaRed, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ygcaRed,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ygcaGold,
          minimumSize: const Size(0, 52),
          side: const BorderSide(color: ygcaGold, width: 1.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: ygcaGold, textStyle: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Color(0xFF3A1A1A))),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkCard,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: Color(0xFF3A1A1A))),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
        contentTextStyle: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500, height: 1.35),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0B0B0B),
        selectedItemColor: ygcaRed,
        unselectedItemColor: Colors.white60,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w800),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCard2,
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        actionTextColor: ygcaGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: ygcaRed, foregroundColor: Colors.white, elevation: 6),
      dividerTheme: const DividerThemeData(color: Color(0xFF3A1A1A), thickness: 1, space: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: ygcaRed, linearTrackColor: Color(0xFF2A1010), circularTrackColor: Color(0xFF2A1010)),
    );
  }

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: ygcaMaroon,
      onPrimary: Colors.white,
      secondary: ygcaGold,
      onSecondary: Colors.black,
      surface: lightCard,
      onSurface: Color(0xFF111827),
      error: Colors.red,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: ResponsiveText.fontFamily,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: ygcaMaroon,
      colorScheme: colorScheme,
      textTheme: _lightTextTheme(),
      dividerColor: const Color(0xFFE2E8F0),
      cardColor: lightCard,
      disabledColor: Colors.black26,
      hintColor: Colors.black38,
      splashColor: ygcaMaroon.withOpacity(0.10),
      highlightColor: ygcaMaroon.withOpacity(0.06),
      appBarTheme: const AppBarTheme(
        backgroundColor: ygcaMaroon,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        labelStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
        floatingLabelStyle: const TextStyle(color: ygcaMaroon, fontWeight: FontWeight.w700),
        hintStyle: const TextStyle(color: Colors.black38, fontWeight: FontWeight.w500),
        errorStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
        prefixIconColor: ygcaMaroon,
        suffixIconColor: Colors.black54,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: ygcaMaroon, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ygcaMaroon,
          foregroundColor: ygcaGold,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ygcaMaroon,
          minimumSize: const Size(0, 52),
          side: const BorderSide(color: ygcaMaroon, width: 1.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: ygcaMaroon, textStyle: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Color(0xFFE2E8F0))),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: Color(0xFFE2E8F0))),
        titleTextStyle: const TextStyle(color: Color(0xFF111827), fontSize: 20, fontWeight: FontWeight.w900),
        contentTextStyle: const TextStyle(color: Color(0xFF475569), fontSize: 14, fontWeight: FontWeight.w500, height: 1.35),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: ygcaMaroon,
        unselectedItemColor: Colors.black54,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w800),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF111827),
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        actionTextColor: ygcaGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: ygcaMaroon, foregroundColor: ygcaGold, elevation: 6),
      dividerTheme: const DividerThemeData(color: Color(0xFFE2E8F0), thickness: 1, space: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: ygcaMaroon, linearTrackColor: Color(0xFFF1F5F9), circularTrackColor: Color(0xFFF1F5F9)),
    );
  }
}
