import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Theme Configuration
/// Supports both Light (Desert Oasis) and Dark (Midnight Reflection) themes
class ThemeConfig {
  ThemeConfig._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
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
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Lora',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.softSand.withValues(alpha: 0.8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.glassBorder.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        shadowColor: AppColors.glassBorder.withValues(alpha: 0.1),
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
      textTheme: _buildTextTheme(Brightness.light),
      iconTheme: const IconThemeData(color: AppColors.sageGreen, size: 24),
      dividerTheme: const DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.deepUmber,
        contentTextStyle: AppTextStyles.loraBodyMedium().copyWith(
          color: AppColors.textOnDark,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.sageGreen;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.sageGreen.withValues(alpha: 0.5);
          }
          return Colors.grey.withValues(alpha: 0.3);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.sageGreen,
        inactiveTrackColor: AppColors.sageGreen.withValues(alpha: 0.3),
        thumbColor: AppColors.sageGreen,
        overlayColor: AppColors.sageGreen.withValues(alpha: 0.2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.softSand,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.sageGreen),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.midnightPeriwinkle,
        secondary: AppColors.midnightGold,
        surface: AppColors.midnightBlue,
        error: AppColors.error,
        onPrimary: AppColors.darkSurface,
        onSecondary: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        onError: AppColors.darkTextPrimary,
      ),
      scaffoldBackgroundColor: AppColors.midnightBlue,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.midnightBlue,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Lora',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.black38,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.midnightGold,
          foregroundColor: AppColors.darkSurface,
          textStyle: AppTextStyles.buttonText().copyWith(
            color: AppColors.darkSurface,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.midnightPeriwinkle,
          textStyle: AppTextStyles.buttonText().copyWith(
            color: AppColors.midnightPeriwinkle,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppColors.midnightPeriwinkle, width: 2),
        ),
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      iconTheme: const IconThemeData(
        color: AppColors.midnightPeriwinkle,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.midnightSlate,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkElevated,
        contentTextStyle: AppTextStyles.loraBodyMedium().copyWith(
          color: AppColors.darkTextPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.midnightPeriwinkle;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.midnightPeriwinkle.withValues(alpha: 0.5);
          }
          return Colors.grey.withValues(alpha: 0.3);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.midnightPeriwinkle,
        inactiveTrackColor: AppColors.midnightPeriwinkle.withValues(alpha: 0.3),
        thumbColor: AppColors.midnightPeriwinkle,
        overlayColor: AppColors.midnightPeriwinkle.withValues(alpha: 0.2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.midnightPeriwinkle),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final secondaryColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return TextTheme(
      displayLarge: AppTextStyles.loraTitle().copyWith(color: textColor),
      displayMedium: AppTextStyles.loraHeading().copyWith(color: textColor),
      bodyLarge: AppTextStyles.loraBodyLarge().copyWith(color: textColor),
      bodyMedium: AppTextStyles.loraBodyMedium().copyWith(color: textColor),
      bodySmall: AppTextStyles.loraBodySmall().copyWith(color: secondaryColor),
      labelSmall: AppTextStyles.loraCaption().copyWith(color: secondaryColor),
    );
  }
}
