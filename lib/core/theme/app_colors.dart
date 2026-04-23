import 'package:flutter/material.dart';

/// Desert Oasis Color Palette (Light Theme)
/// Primary (Background): #F9F7F2 (Soft Cream/Parchment)
/// Secondary (The Jar/Accents): #8C927D (Sage Green)
/// Highlight (Text/Icons): #4A4238 (Deep Umber/Earth)
/// CTA (Buttons): #D4A373 (Warm Terracotta)
class AppColors {
  AppColors._();

  // ==================== Light Theme Colors ====================

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
  static const Color sunlightGlow = Color(0x1AD4A373); // Ethereal Day Glow

  // Day Theme Gradients
  static const Color dayGradientStart = Color(0xFFFFFFFF);
  static const Color dayGradientEnd = Color(0xFFF9F7F2);

  // Text Colors
  static const Color textPrimary = Color(0xFF4A4238);
  static const Color textSecondary = Color(0xFF7A7268);
  static const Color textOnDark = Color(0xFFF9F7F2);

  // ==================== Dark Theme Colors (Celestial Night) ====================

  // Primary Colors - Dark Theme
  static const Color midnightBlue = Color(0xFF0F172A); // Deeper Obsidian
  static const Color midnightPeriwinkle = Color(0xFF94A3B8); // Softer Slate Blue
  static const Color midnightGold = Color(0xFFE2B170); // Ethereal Gold
  static const Color midnightSlate = Color(0xFF1E293B); // Deep Navy Slate

  // Dark Theme Surface Colors
  static const Color darkSurface = Color(0xFF020617); // Richer Night
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkElevated = Color(0xFF334155);

  // Dark Theme Text Colors
  static const Color darkTextPrimary = Color(0xFFE2E8F0); // Off-white for less glare
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Dark Theme Accents
  static const Color darkSageGreen = Color(0xFF475569);
  static const Color darkTerracotta = Color(0xFFB45309);

  // Glassmorphism (Night Mode)
  static const Color glassNight = Color(0x331E293B);
  static const Color glassNightBorder = Color(0x1A94A3B8);
  static const Color starlightGlow = Color(0x1AE2B170);

  // ==================== Theme-Aware Getters (DRY) ====================

  static Color background(BuildContext context) =>
      _isDarkMode(context) ? midnightBlue : cream;

  static Color surface(BuildContext context) =>
      _isDarkMode(context) ? darkCard : softSand;

  static Color primary(BuildContext context) =>
      _isDarkMode(context) ? midnightPeriwinkle : sageGreen;

  static Color accent(BuildContext context) =>
      _isDarkMode(context) ? midnightGold : terracotta;

  static Color getTextPrimary(BuildContext context) =>
      _isDarkMode(context) ? darkTextPrimary : textPrimary;

  static Color getTextSecondary(BuildContext context) =>
      _isDarkMode(context) ? darkTextSecondary : textSecondary;

  static bool _isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // Legacy getters for backward compatibility
  static Color get card => softSand;
  static Color get cardDark => darkCard;
}
