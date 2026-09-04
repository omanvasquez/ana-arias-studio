import 'package:flutter/material.dart';

/// Paleta de colores oficial para Ana Arias Studio.
/// Siguiendo estrictamente las especificaciones de diseño:
/// - Fondo blanco/gris ultra claro (#F5F5F5).
/// - Textos en negro puro y gris oscuro.
/// - Rojo puro exclusivo para alertas médicas e interrupciones críticas.
abstract class AppColors {
  // Fondos y Superficies
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEEEEE);

  // Tipografía y Contrastes
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF424242);
  static const Color textMuted = Color(0xFF757575);

  // Bordes y Divisores
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEBEBEB);

  // Alertas Médicas y Bloqueos (Uso exclusivo)
  static const Color alertPureRed = Color(0xFFD32F2F);
  static const Color alertBackground = Color(0xFFFFEBEE);
  static const Color alertBorder = Color(0xFFFFCDD2);

  // Primario / Acentos Sobrios
  static const Color primary = Color(0xFF111111);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Estados de éxito y desactivado
  static const Color success = Color(0xFF2E7D32);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color disabledBackground = Color(0xFFE0E0E0);
}
