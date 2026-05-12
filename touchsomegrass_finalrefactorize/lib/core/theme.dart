import 'package:flutter/material.dart';

class AppColors {
  // Primary Green Shades
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF2E7D32);
  static const Color primaryDarker = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF43A047);
  
  // Backgrounds
  static const Color backgroundLight = Color(0xFFF5F9F5);
  static const Color backgroundGreenLight = Color(0xFFE8F5E9);
  static const Color backgroundLightRed = Color(0xFFFFEBEE);
  static const Color backgroundLightBlue = Color(0xFFE3F2FD);
  static const Color backgroundLightPurple = Color(0xFFF3E5F5);
  static const Color backgroundLightOrange = Color(0xFFFFF8E1);

  // Texts
  static const Color textDarkBlue = Color(0xFF0D47A1);
  static const Color textDarkPurple = Color(0xFF4A148C);
  static const Color textOrange = Color(0xFFE65100);

  // Dark Vibe Theme (Focus feature)
  static const Color darkThemeBg1 = Color(0xFF1A1A2E);
  static const Color darkThemeBg2 = Color(0xFF16213E);
  static const Color darkThemeBg3 = Color(0xFF0F3460);
  
  // Basic Colors
  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color white60 = Colors.white60;
  static const Color white54 = Colors.white54;
  static const Color white38 = Colors.white38;
  static const Color white30 = Colors.white30;
  static const Color white24 = Colors.white24;

  static const Color black = Colors.black;
  static const Color black87 = Colors.black87;
  static const Color black54 = Colors.black54;

  static const Color transparent = Colors.transparent;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
