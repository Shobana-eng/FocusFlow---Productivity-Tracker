import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ============================================================
  // PRIMARY COLORS
  // ============================================================

  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF8B7BFF);

  // ============================================================
  // LIGHT THEME COLORS
  // ============================================================

  static const Color lightBackground = Color(0xFFF5F7FB);
  static const Color lightCard = Colors.white;

  // ============================================================
  // DARK THEME COLORS
  // ============================================================

  static const Color darkBackground = Color(0xFF09090F);
  static const Color darkCard = Color(0xFF141A2E);

  // ============================================================
  // COMMON COLORS
  // These are used by screens such as Planner and Rewards.
  // ============================================================

  static const Color background = darkBackground;
  static const Color card = darkCard;

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      scaffoldBackgroundColor: lightBackground,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),

      fontFamily: 'Poppins',

      cardColor: lightCard,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(
            double.infinity,
            58,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,

        hintStyle: const TextStyle(
          color: Colors.grey,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: primary,
            width: 2,
          ),
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Colors.black87,
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),

        headlineMedium: TextStyle(
          color: Colors.black87,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),

        titleLarge: TextStyle(
          color: Colors.black87,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),

        bodyLarge: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),

        bodyMedium: TextStyle(
          color: Colors.black54,
          fontSize: 14,
        ),
      ),
    );
  }

  // ============================================================
  // DARK THEME
  // ============================================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      scaffoldBackgroundColor: darkBackground,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ),

      fontFamily: 'Poppins',

      cardColor: darkCard,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(
            double.infinity,
            58,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,

        hintStyle: const TextStyle(
          color: Colors.white54,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: primary,
            width: 2,
          ),
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Colors.white,
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),

        headlineMedium: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),

        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),

        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),

        bodyMedium: TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
    );
  }
}