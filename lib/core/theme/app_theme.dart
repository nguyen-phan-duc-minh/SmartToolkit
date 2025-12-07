import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color primaryBlue = Color(0xFF0E0899);
  static const Color secondaryBlue = Color(0xFF1314A7);
  static const Color accentBlue = Color(0xFF2146DB);
  static const Color purple = Color(0xFF7B15E8);
  static const Color magenta = Color(0xFFFC38DB);
  static const Color white = Color(0xFFFFFFFF);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
      ).copyWith(
        primary: primaryBlue,
        onPrimary: white,
        secondary: purple,
        onSecondary: white,
        tertiary: magenta,
        onTertiary: white,
        surface: white,
        onSurface: const Color(0xFF1A1A1A),
        primaryContainer: accentBlue.withValues(alpha: 0.1),
        onPrimaryContainer: primaryBlue,
        secondaryContainer: purple.withValues(alpha: 0.1),
        onSecondaryContainer: purple,
        error: const Color(0xFFB00020),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      cardTheme: CardThemeData(
        elevation: 2,
        color: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryBlue,
        foregroundColor: white,
        iconTheme: const IconThemeData(color: white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: BorderSide(color: primaryBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: white,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: white,
        unselectedLabelColor: Color(0xFFBBBBBB),
        indicatorColor: magenta,
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentBlue,
        brightness: Brightness.dark,
      ).copyWith(
        primary: accentBlue,
        onPrimary: white,
        secondary: purple,
        onSecondary: white,
        tertiary: magenta,
        onTertiary: white,
        surface: const Color(0xFF121212),
        onSurface: white,
        primaryContainer: accentBlue.withValues(alpha: 0.2),
        onPrimaryContainer: accentBlue,
        secondaryContainer: purple.withValues(alpha: 0.2),
        onSecondaryContainer: purple,
        error: const Color(0xFFCF6679),
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
      cardTheme: CardThemeData(
        elevation: 2,
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: secondaryBlue,
        foregroundColor: white,
        iconTheme: const IconThemeData(color: white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentBlue,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentBlue,
          side: BorderSide(color: accentBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentBlue.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentBlue, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentBlue,
        foregroundColor: white,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: white,
        unselectedLabelColor: Color(0xFF888888),
        indicatorColor: magenta,
      ),
    );
  }
}