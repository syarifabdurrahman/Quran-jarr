import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Text Styles for Quran Jarr App
/// Using Lora for English and Amiri for Arabic
class AppTextStyles {
  AppTextStyles._();

  // English Text Styles (Lora)
  static TextStyle get loraBodyLarge => GoogleFonts.lora(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get loraBodyMedium => GoogleFonts.lora(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get loraBodySmall => GoogleFonts.lora(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get loraHeading => GoogleFonts.lora(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get loraTitle => GoogleFonts.lora(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get loraCaption => GoogleFonts.lora(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.3,
      );

  // Arabic Text Styles (Amiri)
  static TextStyle get amiriVerseLarge => GoogleFonts.amiri(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.8,
        letterSpacing: 0.5,
      );

  static TextStyle get amiriVerseMedium => GoogleFonts.amiri(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.7,
        letterSpacing: 0.3,
      );

  static TextStyle get amiriVerseSmall => GoogleFonts.amiri(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.6,
      );

  // Surah Name Style
  static TextStyle get surahName => GoogleFonts.amiri(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.sageGreen,
        height: 1.4,
      );

  // Button Text
  static TextStyle get buttonText => GoogleFonts.lora(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnDark,
        height: 1.2,
      );
}
