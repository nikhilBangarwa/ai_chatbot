import 'package:flutter/material.dart';

/// Preset accent colors for the chat app. Extend this list as needed.
enum AppAccentColor {
  purple(Color(0xFF6750A4), 'Purple'),
  blue(Color(0xFF2563EB), 'Blue'),
  teal(Color(0xFF0D9488), 'Teal'),
  green(Color(0xFF16A34A), 'Green'),
  orange(Color(0xFFEA580C), 'Orange'),
  pink(Color(0xFFDB2777), 'Pink');

  const AppAccentColor(this.color, this.label);

  final Color color;
  final String label;

  static AppAccentColor fromColor(Color color) {
    final argb = color.toARGB32();
    return values.firstWhere(
      (preset) => preset.color.toARGB32() == argb,
      orElse: () => purple,
    );
  }
}
