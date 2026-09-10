import 'package:flutter/material.dart';

/// Uygulama renk paleti. Renkleri buradan çek.
class AppColors {
  AppColors._();

  // Zemin / yüzeyler
  static const background = Color(0xFF0B0918); // ana arka plan
  static const surface = Color(0xFF16122B); // kartlar
  static const surfaceHigh = Color(0xFF1F1A3C); // yükseltilmiş yüzey
  static const outline = Color(0xFF2E2850); // ince kenarlık

  // Aksan
  static const primary = Color(0xFFC724D9); // magenta-mor
  static const secondary = Color(0xFF7A2BF5); // menekşe
  static const accentPink = Color(0xFFEC3B8B); // vurgu / user score

  // Metin
  static const textPrimary = Color(0xFFF4F1FB);
  static const textMuted = Color(0xFF9A93B8);

  // Marka gradyanı
  static const brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF8E2DE2), Color(0xFFE94FD0)],
  );
}
