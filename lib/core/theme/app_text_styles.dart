import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Text Styles for Quran Jarr App
/// Using Lora for English and Amiri for Arabic
class AppTextStyles {
  AppTextStyles._();

  /// Get text style with font size multiplied
  static TextStyle _withFontSize(TextStyle style, double multiplier) {
    return style.copyWith(
      fontSize: (style.fontSize ?? 14) * multiplier,
    );
  }

  // English Text Styles (Lora)
  static TextStyle loraBodyLarge([double multiplier = 1.0]) => _withFontSize(
        GoogleFonts.lora(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        multiplier,
      );

  static TextStyle loraBodyMedium([double multiplier = 1.0]) => _withFontSize(
        GoogleFonts.lora(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        multiplier,
      );

  static TextStyle loraBodySmall([double multiplier = 1.0]) => _withFontSize(
        GoogleFonts.lora(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
        multiplier,
      );

  static TextStyle loraHeading([double multiplier = 1.0]) => _withFontSize(
        GoogleFonts.lora(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
        multiplier,
      );

  static TextStyle loraTitle([double multiplier = 1.0]) => _withFontSize(
        GoogleFonts.lora(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.2,
        ),
        multiplier,
      );

  static TextStyle loraCaption([double multiplier = 1.0]) => _withFontSize(
        GoogleFonts.lora(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.3,
        ),
        multiplier,
      );

  // Arabic Text Styles (Amiri)
  static TextStyle amiriVerseLarge([double multiplier = 1.0]) => _withFontSize(
        GoogleFonts.amiri(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.8,
          letterSpacing: 0.5,
        ),
        multiplier,
      );

  static TextStyle amiriVerseMedium([double multiplier = 1.0]) => _withFontSize(
        GoogleFonts.amiri(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.7,
          letterSpacing: 0.3,
        ),
        multiplier,
      );

  static TextStyle amiriVerseSmall([double multiplier = 1.0]) => _withFontSize(
        GoogleFonts.amiri(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
        multiplier,
      );

  // Surah Name Style
  static TextStyle surahName([double multiplier = 1.0]) => _withFontSize(
        GoogleFonts.amiri(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.sageGreen,
          height: 1.4,
        ),
        multiplier,
      );

  // Button Text
  static TextStyle buttonText([double multiplier = 1.0]) => _withFontSize(
        GoogleFonts.lora(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textOnDark,
          height: 1.2,
        ),
        multiplier,
      );
}
