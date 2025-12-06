import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF246BFD);
  static const accent = Color(0xFF00CBA4);
  static const bg = Color(0xFFF6F8FF);
  static const card = Colors.white;
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF666666);
  static const error = Color(0xFFE53935);
  static const success = Color(0xFF4CAF50);

  static MaterialColor get materialPrimary => MaterialColor(0xFF246BFD, {
    50: Color(0xFFE8F0FF),
    100: Color(0xFFC5D9FF),
    200: Color(0xFF9FC2FF),
    300: Color(0xFF79ABFF),
    400: Color(0xFF5C99FF),
    500: Color(0xFF3F88FF),
    600: Color(0xFF3980FF),
    700: Color(0xFF3175FF),
    800: Color(0xFF296BFF),
    900: Color(0xFF1B58FF),
  });
}
