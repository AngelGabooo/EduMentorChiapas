import 'package:flutter/material.dart';

class AppTheme {
  // Colores para modo claro
  static const Color primaryColor = Color(0xFF3B82F6);
  static const Color secondaryColor = Color(0xFF1D4ED8);
  static const Color accentColor = Color(0xFF60A5FA);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color onPrimaryColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF1E293B);
  static const Color cardColor = Color(0xFFFFFFFF);

  // Colores para modo oscuro
  static const Color darkBackgroundColor = Color(0xFF0F172A);
  static const Color darkSurfaceColor = Color(0xFF1E293B);
  static const Color darkTextColor = Color(0xFFF1F5F9);
  static const Color darkCardColor = Color(0xFF334155);

  // Tamaños de fuente base para diferentes escalas
  static const Map<String, double> _fontSizeScales = {
    'Pequeño': 0.85,
    'Medio': 1.0,
    'Grande': 1.2,
    'Extra Grande': 1.4,
  };

  // Obtener el factor de escala actual
  static double getFontScale(String fontSizeSetting) {
    return _fontSizeScales[fontSizeSetting] ?? 1.0;
  }

  // Generar TextTheme con escala
  static TextTheme _getTextTheme(double scale, bool isDark) {
    final baseColor = isDark ? darkTextColor : textColor;

    return TextTheme(
      // Display
      displayLarge: TextStyle(
        fontSize: 32.0 * scale,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      displayMedium: TextStyle(
        fontSize: 28.0 * scale,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      displaySmall: TextStyle(
        fontSize: 24.0 * scale,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),

      // Headline
      headlineLarge: TextStyle(
        fontSize: 20.0 * scale,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 18.0 * scale,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 16.0 * scale,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),

      // Title
      titleLarge: TextStyle(
        fontSize: 16.0 * scale,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleMedium: TextStyle(
        fontSize: 14.0 * scale,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleSmall: TextStyle(
        fontSize: 12.0 * scale,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),

      // Body
      bodyLarge: TextStyle(
        fontSize: 14.0 * scale,
        fontWeight: FontWeight.normal,
        color: baseColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 12.0 * scale,
        fontWeight: FontWeight.normal,
        color: baseColor,
      ),
      bodySmall: TextStyle(
        fontSize: 10.0 * scale,
        fontWeight: FontWeight.normal,
        color: baseColor,
      ),

      // Label
      labelLarge: TextStyle(
        fontSize: 12.0 * scale,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      labelMedium: TextStyle(
        fontSize: 10.0 * scale,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      labelSmall: TextStyle(
        fontSize: 8.0 * scale,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
    );
  }

  static ThemeData getLightTheme({String fontSizeSetting = 'Medio'}) {
    final scale = getFontScale(fontSizeSetting);

    final baseTheme = ThemeData.light(useMaterial3: true);

    return baseTheme.copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        onPrimary: onPrimaryColor,
        onSurface: textColor,
      ),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryColor),
        titleTextStyle: TextStyle(
          fontSize: 18.0 * scale,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: TextStyle(
            fontSize: 14.0 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(
          fontSize: 14.0 * scale,
          color: textColor.withOpacity(0.7),
        ),
        hintStyle: TextStyle(
          fontSize: 14.0 * scale,
          color: textColor.withOpacity(0.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: TextStyle(
            fontSize: 14.0 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: _getTextTheme(scale, false),
      dialogBackgroundColor: surfaceColor,
    );
  }

  static ThemeData getDarkTheme({String fontSizeSetting = 'Medio'}) {
    final scale = getFontScale(fontSizeSetting);

    final baseTheme = ThemeData.dark(useMaterial3: true);

    return baseTheme.copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      cardColor: darkCardColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: primaryColor,
        secondary: accentColor,
        surface: darkSurfaceColor,
        background: darkBackgroundColor,
        onPrimary: onPrimaryColor,
        onSurface: darkTextColor,
      ),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: darkSurfaceColor,
        foregroundColor: darkTextColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryColor),
        titleTextStyle: TextStyle(
          fontSize: 18.0 * scale,
          fontWeight: FontWeight.bold,
          color: darkTextColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: TextStyle(
            fontSize: 14.0 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF475569)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF475569)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: darkSurfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(
          fontSize: 14.0 * scale,
          color: darkTextColor,
        ),
        hintStyle: TextStyle(
          fontSize: 14.0 * scale,
          color: darkTextColor.withOpacity(0.7),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: TextStyle(
            fontSize: 14.0 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: _getTextTheme(scale, true),
      dialogBackgroundColor: darkSurfaceColor,
    );
  }
}