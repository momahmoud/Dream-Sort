import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF16213E);
  static const Color primary = Color(0xFF0F3460);
  static const Color accent = Color(0xFFE94560);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);

  // Sorting Colors (The items to sort)
  static const List<Color> sortColors = [
    Color(0xFFFF0055), // Red/Pink
    Color(0xFF00DDFF), // Cyan
    Color(0xFFFFD500), // Yellow
    Color(0xFF00FF55), // Green
    Color(0xFFAA00FF), // Purple
    Color(0xFFFF8800), // Orange
    Color(0xFF2979FF), // Blue
    Color(0xFFB0BEC5), // Silver
    Color(0xFF795548), // Brown
    Color(0xFF009688), // Teal
    Color(0xFFC6FF00), // Lime
    Color(0xFF3D5AFE), // Indigo
    Color(0xFFC51162), // Deep Pink
    Color(0xFF69F0AE), // Mint
    Color(0xFFE040FB), // Lavender
    Color(0xFF3E2723), // Dark Brown
    Color(0xFF827717), // Olive
    Color(0xFFFF6E40), // Coral
  ];

  static ThemeData getTheme(Locale locale) {
    final fontFamily = locale.languageCode == 'ar' ? 'Almarai' : 'Play';

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      fontFamily: fontFamily, // Apply globally
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textPrimary, fontFamily: fontFamily),
        bodyMedium: TextStyle(color: textPrimary, fontFamily: fontFamily),
        bodySmall: TextStyle(color: textPrimary, fontFamily: fontFamily),
        displayLarge: TextStyle(color: textPrimary, fontFamily: fontFamily),
        displayMedium: TextStyle(color: textPrimary, fontFamily: fontFamily),
        displaySmall: TextStyle(color: textPrimary, fontFamily: fontFamily),
        headlineLarge: TextStyle(color: textPrimary, fontFamily: fontFamily),
        headlineMedium: TextStyle(color: textPrimary, fontFamily: fontFamily),
        headlineSmall: TextStyle(color: textPrimary, fontFamily: fontFamily),
        titleLarge: TextStyle(color: textPrimary, fontFamily: fontFamily),
        titleMedium: TextStyle(color: textPrimary, fontFamily: fontFamily),
        titleSmall: TextStyle(color: textPrimary, fontFamily: fontFamily),
        labelLarge: TextStyle(color: textPrimary, fontFamily: fontFamily),
        labelMedium: TextStyle(color: textPrimary, fontFamily: fontFamily),
        labelSmall: TextStyle(color: textPrimary, fontFamily: fontFamily),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
    );
  }
}
