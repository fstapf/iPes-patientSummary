import 'package:flutter/material.dart';

/// Sistema de cores baseado no CSS original do projeto
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryHover = Color(0xFF0070EB);

  // Grayscale
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFEEEEEE);
  static const Color gray100 = Color(0xFFE4E4E4);
  static const Color gray200 = Color(0xFFCECECE);
  static const Color gray300 = Color(0xFFB8B8B8);
  static const Color gray400 = Color(0xFFA3A3A3);
  static const Color gray500 = Color(0xFF8D8D8D);
  static const Color gray600 = Color(0xFF777777);
  static const Color gray700 = Color(0xFF646464);
  static const Color gray800 = Color(0xFF515151);
  static const Color gray900 = Color(0xFF3E3E3E);
  static const Color gray1000 = Color(0xFF2B2B2B);

  // Status colors
  static const Color success = Color(0xFF28CD59);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF5B55D6);

  // Backgrounds
  static const Color background = gray50;
  static const Color cardBackground = white;

  // Alerts
  static const Color alertHighBg = Color(0xFFFFEEEE);
  static const Color alertMediumBg = Color(0xFFFFF3CD);
  static const Color alertLowBg = Color(0xFFE7F3FF);

  // Status backgrounds
  static const Color statusCompletedBg = Color(0xFFF0FFF4);
  static const Color statusProgressBg = Color(0xFFEBF8FF);
  static const Color statusDelayedBg = Color(0xFFFFF5F5);
  static const Color statusSuspendedBg = Color(0xFFFFF3CD);
}