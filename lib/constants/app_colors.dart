import 'package:flutter/material.dart';

/// Paleta de colores fiel a las capturas de referencia oficiales.
class AppColors {
  AppColors._();

  static const Color primaryGreen = Color(0xFF1F8A5B);
  static const Color darkGreen = Color(0xFF0E5C3A);
  static const Color leafGreen = Color(0xFF6FCB4F);
  static const Color skyBlue = Color(0xFF4FB6E8);
  static const Color oceanBlue = Color(0xFF1E6FA8);
  static const Color sunYellow = Color(0xFFFFC93C);
  static const Color pitahayaOrange = Color(0xFFF39C3E);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1B3B2F);
  static const Color textGrey = Color(0xFF7A8C85);
  static const Color lockedGrey = Color(0xFFB9C4BE);
  static const Color correctGreen = Color(0xFF2ECC71);
  static const Color incorrectRed = Color(0xFFE74C3C);
  static const Color backgroundLight = Color(0xFFF3F8F4);

  static const LinearGradient forestGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFDDEFC8), Color(0xFFFCE9B0)],
  );
}
