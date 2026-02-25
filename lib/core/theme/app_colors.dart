import 'package:flutter/material.dart';

/// Desert Oasis Color Palette
/// Primary (Background): #F9F7F2 (Soft Cream/Parchment)
/// Secondary (The Jar/Accents): #8C927D (Sage Green)
/// Highlight (Text/Icons): #4A4238 (Deep Umber/Earth)
/// CTA (Buttons): #D4A373 (Warm Terracotta)
class AppColors {
  AppColors._();

  // ==================== Light Mode Colors ====================
  // Primary Colors
  static const Color cream = Color(0xFFF9F7F2);
  static const Color sageGreen = Color(0xFF8C927D);
  static const Color deepUmber = Color(0xFF4A4238);
  static const Color terracotta = Color(0xFFD4A373);

  // Secondary Colors
  static const Color softSand = Color(0xFFF5EDE4);
  static const Color mutedGold = Color(0xFFC4A962);
  static const Color darkEarth = Color(0xFF3A332B);

  // Semantic Colors
  static const Color success = Color(0xFF6B8E23);
  static const Color error = Color(0xFFC1564D);
  static const Color warning = Color(0xFFE8B84A);

  // Glassmorphism
  static const Color glassWhite = Color(0xFFFFFFFF);
  static const Color glassBorder = Color(0x1A000000);

  // Text Colors
  static const Color textPrimary = Color(0xFF4A4238);
  static const Color textSecondary = Color(0xFF7A7268);
  static const Color textOnDark = Color(0xFFF9F7F2);

  // ==================== Dark Mode Colors ====================
  // Primary Colors (Dark)
  static const Color darkCream = Color(0xFF1A1915);
  static const Color darkSageGreen = Color(0xFF9BA88F);
  static const Color darkDeepUmber = Color(0xFFE8E4DD);
  static const Color darkTerracotta = Color(0xFFE0B895);

  // Secondary Colors (Dark)
  static const Color darkSoftSand = Color(0xFF2A2822);
  static const Color darkMutedGold = Color(0xFFD4BC76);
  static const Color darkDarkEarth = Color(0xFF151410);

  // Semantic Colors (Dark)
  static const Color darkSuccess = Color(0xFF8BC34A);
  static const Color darkError = Color(0xFFE57373);
  static const Color darkWarning = Color(0xFFFFD54F);

  // Glassmorphism (Dark)
  static const Color darkGlassWhite = Color(0xFF2A2822);
  static const Color darkGlassBorder = Color(0x33FFFFFF);

  // Text Colors (Dark)
  static const Color darkTextPrimary = Color(0xFFE8E4DD);
  static const Color darkTextSecondary = Color(0xFFB0A898);
  static const Color darkTextOnDark = Color(0xFF1A1915);
}
