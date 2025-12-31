import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF16213E);
  static const Color primary = Color(0xFF0F3460);
  static const Color accent = Color(0xFFE94560);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);

  // Sorting Colors (The items to sort)
  // HIGH CONTRAST PALETTE - Optimized to avoid "similar blues"
  static const List<Color> sortColors = [
    // --- 1. NEON / VIBRANT (Highest Contrast) ---
    Color(0xFFFF0000), // Pure Red
    Color(0xFF00FF00), // Electric Lime
    Color(0xFF0000FF), // Pure Blue
    Color(0xFFFFFF00), // Canary Yellow
    Color(0xFFFF00FF), // Magenta
    Color(0xFF00FFFF), // Cyan / Aqua
    Color(0xFFFF8000), // Bright Orange
    Color(0xFF9D00FF), // Electric Purple
    // --- 2. SOFT PASTELS (High Lightness) ---
    Color(0xFFFFB2C1), // Bubblegum Pink
    Color(0xFF9E9E9E), // Grey (Replaces Magic Mint - too close to others)
    Color(0xFFB2E0FF), // Sky Blue
    Color(0xFFD7CCC8), // Beige (Replaces Pale Chiffon - too close to Yellow)
    Color(0xFFE0B2FF), // Soft Lavender
    Color(0xFF5C6BC0), // Slate Blue (Replaces Apricot - too close to others)
    Color(0xFFFFFFFF), // Pure White
    Color(0xFF827717), // Olive (Replaces Spring Bud - too close to Lime)
    // --- 3. RICH MID-TONES (Deep but Saturated) ---
    Color(0xFFB71C1C), // Blood Red
    Color(0xFF006400), // Dark Forest
    Color(0xFF1A237E), // Navy Indigo
    Color(0xFFF57F17), // Deep Gold/Mustard
    Color(0xFF006064), // Deep Teal
    Color(0xFF880E4F), // Maroon / Pansy
    Color(0xFF3E2723), // Coffee Brown
    Color(0xFF4A148C), // Deep Purple (Replaced duplicate Neon Turquoise)
    // --- 4. UNIQUE HUES ---
    Color(0xFFFF5252), // Coral / Salmon
    Color(0xFF78909C), // Steel Grey-Blue (Distinct from the background)
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
