import 'package:flutter/material.dart';

/// App color scheme inspired by the An be Kalan owl logo
class AppColors {
  // Primary colors from the logo
  static const Color primaryGreen = Color(0xFF2E7D32); // Owl body green
  static const Color lightGreen = Color(0xFF4CAF50); // Lighter variant
  static const Color darkGreen = Color(0xFF1B5E20); // Darker variant

  // Accent colors from the logo
  static const Color accentOrange = Color(0xFFFF9800); // Beak/feet orange
  static const Color lightOrange = Color(0xFFFFC107); // Lighter variant
  static const Color darkOrange = Color(0xFFE65100); // Darker variant

  // Secondary colors from the logo
  static const Color wisdomTeal = Color(0xFF00695C); // Graduation cap
  static const Color lightTeal = Color(0xFF26A69A); // Lighter variant
  static const Color bookBlue = Color(0xFF1976D2); // Book color

  // Neutral colors
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF5F5F5);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color mediumGrey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);
  static const Color charcoal = Color(0xFF212121);

  // Success/Error states
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGreen, primaryGreen],
  );

  static const Gradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightOrange, accentOrange],
  );

  static const Gradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [pureWhite, offWhite],
  );

  // Surface colors with opacity
  static Color get surfaceLight => primaryGreen.withOpacity(0.05);
  static Color get surfaceMedium => primaryGreen.withOpacity(0.1);
  static Color get surfaceDark => primaryGreen.withOpacity(0.15);

  static Color get accentSurfaceLight => accentOrange.withOpacity(0.05);
  static Color get accentSurfaceMedium => accentOrange.withOpacity(0.1);
  static Color get accentSurfaceDark => accentOrange.withOpacity(0.15);
}
