import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors extracted from the provided Meetrix image
  static const Color brandPrimary = Color(0xFFA37C6B); // warm brown
  static const Color brandOnPrimary = Color(0xFFFFFFFF);
  static const Color brandBackground = Color(0xFFFAF6F2); // soft cream
  static const Color brandForeground = Color(0xFF5E3D36); // darker text color
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkOutline = Color(0xFF404040);

  // Handy, consistent text styles that pages can import and use directly if desired.
  static const TextStyle heading1 = TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: brandForeground);
  static const TextStyle heading2 = TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: brandForeground);
  static const TextStyle title = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: brandForeground);
  static const TextStyle body = TextStyle(fontSize: 16, color: brandForeground);
  static const TextStyle caption = TextStyle(fontSize: 14, color: Color(0xFF6B5A54));

  // Extra accent colors for consistent small highlights and badges
  static const Color accentBlue = Color(0xFF2F80ED);
  static const Color accentGreen = Color(0xFF2ECC71);
  static const Color accentOrange = Color(0xFFF2994A);
  static const Color accentPurple = Color(0xFF9B51E0);

  static ThemeData buildLightTheme() {  // This is the light theme
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandPrimary,
      primary: brandPrimary,
      background: brandBackground,
      surface: Colors.white,
      onBackground: brandForeground,
      onSurface: brandForeground,
    );

    final textTheme = TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
    );

    return ThemeData(
      colorScheme: colorScheme,
      primaryColor: brandPrimary,
      scaffoldBackgroundColor: brandBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onBackground,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: brandPrimary,
        foregroundColor: brandOnPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: brandOnPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brandPrimary,
        ),
      ),
      useMaterial3: true,
      textTheme: textTheme,
    );
  }

  static ThemeData buildDarkTheme() {
    // Create color with opacity separately
    final darkOnBackgroundWithOpacity = darkOnBackground.withOpacity(0.9);
    final darkOutlineWithOpacity = darkOutline.withOpacity(0.5);
    final darkOutlineWithOpacity2 = darkOutline.withOpacity(0.3);

    final colorScheme = ColorScheme.dark(
      primary: brandPrimary,
      primaryContainer: brandPrimary.withOpacity(0.2),
      onPrimary: brandOnPrimary,
      secondary: brandPrimary.withOpacity(0.8),
      onSecondary: brandOnPrimary,
      background: darkBackground,
      onBackground: darkOnBackground,
      surface: darkSurface,
      onSurface: darkOnSurface,
      outline: darkOutline,
      error: Colors.red.shade400,
      onError: Colors.white,
    );

    final textTheme = TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: darkOnBackground),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkOnBackground),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: darkOnBackground),
      bodyLarge: TextStyle(fontSize: 16, color: darkOnBackground),
      bodyMedium: TextStyle(fontSize: 14, color: darkOnBackgroundWithOpacity),
    );

    return ThemeData(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      primaryColor: brandPrimary,
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkOnBackground,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: brandPrimary,
        foregroundColor: brandOnPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: brandOnPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brandPrimary,
        ),
      ),
      useMaterial3: true,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: brandPrimary,
        unselectedItemColor: darkOnBackground.withOpacity(0.6),
        elevation: 4,
      ),
      dividerTheme: DividerThemeData(
        color: darkOutlineWithOpacity,
        thickness: 0.5,
        space: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkOutlineWithOpacity),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkOutlineWithOpacity),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brandPrimary),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurface,
        selectedColor: brandPrimary.withOpacity(0.2),
        checkmarkColor: brandPrimary,
        labelStyle: TextStyle(color: darkOnBackground),
        secondaryLabelStyle: TextStyle(color: brandPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: darkOutlineWithOpacity2),
        ),
      ),
    );
  }
}