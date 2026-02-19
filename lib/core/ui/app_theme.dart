import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_radius.dart';

class AppTheme {
  /// Single accent color. Dark theme default.
  static const Color accent = Color(0xFF3B82F6);

  static const Color surfaceDark = Color(0xFF0B0B0B);
  static const Color cardDark = Color(0xFF141414);
  static const Color sidebarDark = Color(0xFF0F0F0F);
  static const Color topbarDark = Color(0xFF141414);

  /// Card elevation (consistent)
  static const double cardElevation = 0;

  /// Web typography: H1 28–32, section 20–22, body 14–16.
  static TextTheme _webTextTheme(ColorScheme scheme) {
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: scheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: scheme.onSurface),
      bodyMedium: TextStyle(fontSize: 14, color: scheme.onSurface),
      bodySmall: TextStyle(fontSize: 12, color: scheme.onSurface),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  static ThemeData darkTheme({bool isWeb = false}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: isWeb ? _webTextTheme(colorScheme) : null,
      scaffoldBackgroundColor: surfaceDark,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
      ),
      cardTheme: CardThemeData(
        elevation: cardElevation,
        color: cardDark,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(borderRadius: AppRadius.mdRadius),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
        ),
      ),
    );
  }

  static ThemeData get dark => darkTheme(isWeb: kIsWeb);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
    );
    return ThemeData(useMaterial3: true, colorScheme: colorScheme);
  }
}
