import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Builds [ThemeData] for light and dark modes using a seed accent color.
class AppTheme {
  AppTheme._();

  static ThemeData light({required Color seedColor}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData dark({required Color seedColor}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
    );
  }

  static ThemeData fromAccent(
    AppAccentColor accent, {
    required Brightness brightness,
  }) {
    return brightness == Brightness.dark
        ? dark(seedColor: accent.color)
        : light(seedColor: accent.color);
  }
}
