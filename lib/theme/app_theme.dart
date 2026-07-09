import 'package:flutter/material.dart';

class YGCATheme {
  static const Color ygcaRed = Color(0xFFE50914);
  static const Color ygcaMaroon = Color(0xFF7F0000);
  static const Color ygcaDarkMaroon = Color(0xFF3B0000);
  static const Color ygcaGold = Color(0xFFD4AF37);

  static const Color darkBg = Color(0xFF070707);
  static const Color darkCard = Color(0xFF111111);
  static const Color darkCard2 = Color(0xFF1A0808);

  static const Color lightBg = Color(0xFFFAFAFA);
  static const Color lightCard = Color(0xFFFFFFFF);

  static ThemeData darkTheme({String? fontFamily}) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: ygcaRed,
      fontFamily: fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: ygcaRed,
        secondary: ygcaGold,
        surface: darkCard,
        error: Colors.redAccent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          fontFamily: fontFamily,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0B0B0B),
        selectedItemColor: ygcaRed,
        unselectedItemColor: Colors.white60,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111111),
        labelStyle: TextStyle(color: Colors.white70, fontFamily: fontFamily),
        hintStyle: TextStyle(color: Colors.white38, fontFamily: fontFamily),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3A1A1A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3A1A1A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ygcaRed, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ygcaRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.w900,
            fontFamily: fontFamily,
          ),
        ),
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: fontFamily,
        bodyColor: Colors.white70,
        displayColor: Colors.white,
      ),
    );
  }

  static ThemeData lightTheme({String? fontFamily}) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: ygcaMaroon,
      fontFamily: fontFamily,
      colorScheme: const ColorScheme.light(
        primary: ygcaMaroon,
        secondary: ygcaGold,
        surface: lightCard,
        error: Colors.red,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ygcaMaroon,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          fontFamily: fontFamily,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: ygcaMaroon,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: Colors.black54, fontFamily: fontFamily),
        hintStyle: TextStyle(color: Colors.black38, fontFamily: fontFamily),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ygcaMaroon, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ygcaMaroon,
          foregroundColor: ygcaGold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.w900,
            fontFamily: fontFamily,
          ),
        ),
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: fontFamily,
        bodyColor: Colors.black87,
        displayColor: Colors.black,
      ),
    );
  }
}