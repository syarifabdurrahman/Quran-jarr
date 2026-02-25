import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Desert Oasis Theme Configuration
/// Earthy tones with sage green, soft sand, warm terracotta
class ThemeConfig {
  ThemeConfig._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.sageGreen,
        secondary: AppColors.terracotta,
        surface: AppColors.cream,
        error: AppColors.error,
        onPrimary: AppColors.textOnDark,
        onSecondary: AppColors.textOnDark,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textOnDark,
      ),
      scaffoldBackgroundColor: AppColors.cream,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.loraHeading(),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.softSand,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: AppColors.glassBorder,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracotta,
          foregroundColor: AppColors.textOnDark,
          textStyle: AppTextStyles.buttonText(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.sageGreen,
          textStyle: AppTextStyles.buttonText(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppColors.sageGreen, width: 2),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.loraTitle(),
        displayMedium: AppTextStyles.loraHeading(),
        bodyLarge: AppTextStyles.loraBodyLarge(),
        bodyMedium: AppTextStyles.loraBodyMedium(),
        bodySmall: AppTextStyles.loraBodySmall(),
        labelSmall: AppTextStyles.loraCaption(),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.sageGreen,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkSageGreen,
        secondary: AppColors.darkTerracotta,
        surface: AppColors.darkCream,
        error: AppColors.darkError,
        onPrimary: AppColors.darkTextOnDark,
        onSecondary: AppColors.darkTextOnDark,
        onSurface: AppColors.darkTextPrimary,
        onError: AppColors.darkTextOnDark,
      ),
      scaffoldBackgroundColor: AppColors.darkCream,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkCream,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.loraHeading().copyWith(
          color: AppColors.darkTextPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSoftSand,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: AppColors.darkGlassBorder,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkTerracotta,
          foregroundColor: AppColors.darkTextOnDark,
          textStyle: AppTextStyles.buttonText(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkSageGreen,
          textStyle: AppTextStyles.buttonText(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppColors.darkSageGreen, width: 2),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.loraTitle().copyWith(
          color: AppColors.darkTextPrimary,
        ),
        displayMedium: AppTextStyles.loraHeading().copyWith(
          color: AppColors.darkTextPrimary,
        ),
        bodyLarge: AppTextStyles.loraBodyLarge().copyWith(
          color: AppColors.darkTextPrimary,
        ),
        bodyMedium: AppTextStyles.loraBodyMedium().copyWith(
          color: AppColors.darkTextPrimary,
        ),
        bodySmall: AppTextStyles.loraBodySmall().copyWith(
          color: AppColors.darkTextSecondary,
        ),
        labelSmall: AppTextStyles.loraCaption().copyWith(
          color: AppColors.darkTextSecondary,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.darkSageGreen,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkGlassBorder,
        thickness: 1,
      ),
    );
  }
}
