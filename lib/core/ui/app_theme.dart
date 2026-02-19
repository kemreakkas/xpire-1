import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_radius.dart';

/// Premium dark SaaS color system. Modern, gamified but not childish.
class AppTheme {
  AppTheme._();

  // --- Primary palette
  static const Color primaryBackground = Color(0xFF0F1115);
  static const Color cardBackground = Color(0xFF151922);
  static const Color hoverBackground = Color(0xFF1E2330);

  // --- Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF); // grey 400

  // --- Accent
  static const Color accent = Color(0xFF3B82F6); // Electric Blue
  static const Color accentCyan = Color(0xFF22D3EE); // Cyan

  // --- Legacy aliases (for gradual migration)
  static const Color surfaceDark = primaryBackground;
  static const Color cardDark = cardBackground;
  static const Color sidebarDark = Color(0xFF0F1115);
  static const Color topbarDark = cardBackground;

  static const double cardElevation = 0;
  static const double cardShadowBlur = 24;
  static const double cardShadowOpacity = 0.15;

  /// XP bar gradient colors (subtle blue → cyan).
  static const List<Color> xpBarGradient = [accent, accentCyan];

  static TextTheme _premiumTextTheme(ColorScheme scheme) {
    const onSurface = textPrimary;
    const onSurfaceVariant = textSecondary;
    return TextTheme(
      displaySmall: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: onSurface,
      ),
      headlineLarge: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
        color: onSurface,
      ),
      headlineMedium: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      headlineSmall: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleLarge: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      titleSmall: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      bodyLarge: const TextStyle(fontSize: 16, color: onSurface, height: 1.45),
      bodyMedium: const TextStyle(fontSize: 14, color: onSurface, height: 1.4),
      bodySmall: const TextStyle(fontSize: 12, color: onSurfaceVariant),
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      labelMedium: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: onSurfaceVariant,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: onSurfaceVariant,
      ),
    );
  }

  static ThemeData darkTheme({bool isWeb = false}) {
    final colorScheme = ColorScheme.dark(
      surface: primaryBackground,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      surfaceContainerHighest: hoverBackground,
      primary: accent,
      onPrimary: textPrimary,
      secondary: accentCyan,
      onSecondary: primaryBackground,
      outline: const Color(0xFF374151),
      outlineVariant: const Color(0xFF1F2937),
      error: const Color(0xFFEF4444),
      onError: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _premiumTextTheme(colorScheme),
      scaffoldBackgroundColor: primaryBackground,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cardBackground,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
      ),
      cardTheme: CardThemeData(
        elevation: cardElevation,
        color: cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: hoverBackground,
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
          backgroundColor: accent,
          foregroundColor: textPrimary,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: colorScheme.outline),
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
