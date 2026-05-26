import 'package:flutter/material.dart';

/// Dark chat UI palette (ChatGPT-style).
abstract final class ChatTheme {
  static const Color background = Color(0xFF050510);
  static const Color surface = Color(0xFF12122A);
  static const Color surfaceHigh = Color(0xFF1A1B2E);
  static const Color border = Color(0xFF2D2F4A);
  static const Color textPrimary = Color(0xFFCDD6F4);
  static const Color textMuted = Color(0xFF8892B0);
  static const Color textDim = Color(0xFF4A5568);
  static const Color accent = Color(0xFF6C3ED6);
  static const Color accentLight = Color(0xFF9B6DFF);
  static const Color accentBlue = Color(0xFF4FC3F7);
  static const Color favorite = Color(0xFFFAC775);

  static const LinearGradient userBubble = LinearGradient(
    colors: [Color(0xFF6C3ED6), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandText = LinearGradient(
    colors: [Color(0xFF9B6DFF), Color(0xFF4FC3F7)],
  );
}
