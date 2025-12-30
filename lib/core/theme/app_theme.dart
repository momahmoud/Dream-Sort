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
    Color(0xFFFF1744), // 1. Red (Bright)
    Color(0xFF00E676), // 2. Green (Fluorescent)
    Color(0xFF2962FF), // 3. Blue (Royal)
    Color(0xFFFFEA00), // 4. Yellow (Canary)
    Color(0xFFD500F9), // 5. Purple (Bright)
    Color(0xFFFF6D00), // 6. Orange (Vivid)
    Color(0xFF00B8D4), // 7. Cyan
    Color(0xFFF50057), // 8. Pink
    Color(0xFF76FF03), // 9. Lime
    Color(0xFF8D6E63), // 10. Brown (Lighter to distinguish from darks)
    Color(0xFF263238), // 11. Blue Grey (Dark)
    Color(0xFF6200EA), // 12. Deep Purple
    Color(0xFF004D40), // 13. Teal (Dark)
    Color(0xFFDD2C00), // 14. Deep Orange
    Color(0xFF304FFE), // 15. Indigo (Bright)
    Color(0xFF880E4F), // 16. Maroon
    Color(0xFF0091EA), // 17. Light Blue
    Color(0xFFC6FF00), // 18. Lime Accent
    Color(0xFF3E2723), // 19. Dark Brown
    Color(0xFFC51162), // 20. Rose (Dark Pink)
    Color(0xFF7986CB), // 21. Indigo (Light)
    Color(0xFFA1887F), // 22. Brown (Pale)
    Color(0xFFFFAB00), // 23. Amber
    Color(0xFF00C853), // 24. Green (Standard)
    Color(0xFF607D8B), // 25. Blue Grey
    Color(0xFFBA68C8), // 26. Purple (Light)
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
