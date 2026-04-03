import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme (default for your Gentle Ministry app)
  static ThemeData get lightTheme {
    const primaryBlue = Color(0xFF2196F3); // Church Blue
    const accentAmber = Color(0xFFFFC107); // Warm accent for highlights/bookmarks

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: accentAmber,
        tertiary: const Color(0xFF4CAF50),
        surface: Colors.white,
        error: Colors.red.shade700,
        brightness: Brightness.light,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // FIX: Changed CardTheme to CardThemeData
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
      ),

      expansionTileTheme: ExpansionTileThemeData(
        iconColor: primaryBlue,
        collapsedIconColor: Colors.grey.shade600,
        textColor: primaryBlue,
        collapsedTextColor: Colors.black87,
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
      ),

      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  // Optional: Dark Theme
  static ThemeData get darkTheme {
    const primaryBlue = Color(0xFF64B5F6);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: const Color(0xFFFFD54F),
        tertiary: const Color(0xFF81C784),
        surface: const Color(0xFF1E1E1E),
        error: Colors.red.shade300,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      
      // FIX: Changed CardTheme to CardThemeData
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color(0xFF1E1E1E),
      ),
      
      expansionTileTheme:  ExpansionTileThemeData(
        iconColor: primaryBlue,
        collapsedIconColor: Colors.grey.shade400,
        textColor: primaryBlue,
        collapsedTextColor: Colors.white70,
      ),
    );
  }
}