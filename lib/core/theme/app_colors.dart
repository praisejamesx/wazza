import 'package:flutter/material.dart';

/// Strict monochrome palette: pure black and white with neutral greys.
/// No accent hue anywhere, so the UI stays distraction free.
class AppColors {
  AppColors._();

  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearBlack = Color(0xFF0A0A0A);

  // Light
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainer = Color(0xFFF4F4F5);
  static const Color lightSurfaceContainerHigh = Color(0xFFEBEBED);
  static const Color lightSurfaceContainerHighest = Color(0xFFE2E2E5);
  static const Color lightOutline = Color(0xFFE4E4E7);
  static const Color lightOutlineVariant = Color(0xFFEDEDEF);
  static const Color lightOnSurface = Color(0xFF0A0A0A);
  static const Color lightOnSurfaceVariant = Color(0xFF6B6B70);
  static const Color lightPrimary = Color(0xFF0A0A0A);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);

  // Dark
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF0A0A0A);
  static const Color darkSurfaceContainer = Color(0xFF141416);
  static const Color darkSurfaceContainerHigh = Color(0xFF1C1C1F);
  static const Color darkSurfaceContainerHighest = Color(0xFF26262A);
  static const Color darkOutline = Color(0xFF2A2A2D);
  static const Color darkOutlineVariant = Color(0xFF1F1F22);
  static const Color darkOnSurface = Color(0xFFF5F5F5);
  static const Color darkOnSurfaceVariant = Color(0xFF9A9A9F);
  static const Color darkPrimary = Color(0xFFFFFFFF);
  static const Color darkOnPrimary = Color(0xFF0A0A0A);

  static const Color error = Color(0xFFB3261E);

  static ColorScheme lightColorScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: lightPrimary,
      onPrimary: lightOnPrimary,
      primaryContainer: lightSurfaceContainerHigh,
      onPrimaryContainer: lightOnSurface,
      secondary: lightOnSurface,
      onSecondary: lightOnPrimary,
      secondaryContainer: lightSurfaceContainer,
      onSecondaryContainer: lightOnSurface,
      error: error,
      onError: white,
      errorContainer: Color(0xFFFCE8E6),
      onErrorContainer: Color(0xFF8C1D18),
      surface: lightSurface,
      onSurface: lightOnSurface,
      surfaceContainerLowest: white,
      surfaceContainerLow: Color(0xFFFAFAFA),
      surfaceContainer: lightSurfaceContainer,
      surfaceContainerHigh: lightSurfaceContainerHigh,
      surfaceContainerHighest: lightSurfaceContainerHighest,
      onSurfaceVariant: lightOnSurfaceVariant,
      outline: lightOutline,
      outlineVariant: lightOutlineVariant,
      shadow: black,
      scrim: black,
      inverseSurface: nearBlack,
      onInverseSurface: white,
      inversePrimary: white,
    );
  }

  static ColorScheme darkColorScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: darkPrimary,
      onPrimary: darkOnPrimary,
      primaryContainer: darkSurfaceContainerHigh,
      onPrimaryContainer: darkOnSurface,
      secondary: darkOnSurface,
      onSecondary: darkOnPrimary,
      secondaryContainer: darkSurfaceContainer,
      onSecondaryContainer: darkOnSurface,
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      errorContainer: Color(0xFF8C1D18),
      onErrorContainer: Color(0xFFF9DEDC),
      surface: darkSurface,
      onSurface: darkOnSurface,
      surfaceContainerLowest: black,
      surfaceContainerLow: Color(0xFF060607),
      surfaceContainer: darkSurfaceContainer,
      surfaceContainerHigh: darkSurfaceContainerHigh,
      surfaceContainerHighest: darkSurfaceContainerHighest,
      onSurfaceVariant: darkOnSurfaceVariant,
      outline: darkOutline,
      outlineVariant: darkOutlineVariant,
      shadow: black,
      scrim: black,
      inverseSurface: white,
      onInverseSurface: nearBlack,
      inversePrimary: nearBlack,
    );
  }
}
