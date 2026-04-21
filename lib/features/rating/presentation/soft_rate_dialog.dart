import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quran_jarr/features/rating/application/rating_service.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';

class SoftRateDialog extends ConsumerWidget {
  final int currentStreak;

  const SoftRateDialog({super.key, required this.currentStreak});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingService = ref.read(ratingServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.cream,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Illustration/Icon area
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.midnightGold : AppColors.sageGreen)
                    .withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 64,
                    color: isDark ? AppColors.midnightGold : AppColors.sageGreen,
                  ).animate(onPlay: (controller) => controller.repeat())
                   .shimmer(duration: 2.seconds, color: Colors.white.withValues(alpha: 0.4))
                   .shake(hz: 2, curve: Curves.easeInOut),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                children: [
                  Text(
                    'Enjoying Quran Jar?',
                    style: AppTextStyles.loraHeadingForTheme(context).copyWith(
                      fontSize: 22,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.deepUmber,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'MashAllah, you have reached a $currentStreak-day streak! Your consistency is inspiring. Are you enjoying your daily reflections?',
                    style: AppTextStyles.loraBodyMediumForTheme(context).copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.midnightGold : AppColors.sageGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      ratingService.openStoreListing();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Yes, I love it!',
                      style: AppTextStyles.loraBodyLargeForTheme(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      ratingService.openFeedbackEmail();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'I have some feedback',
                      style: AppTextStyles.loraBodyMediumForTheme(context).copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().scale(
        duration: 400.ms,
        curve: Curves.easeOutBack,
        begin: const Offset(0.8, 0.8),
      ).fadeIn(),
    );
  }

  static Future<void> showIfNeeded(BuildContext context, WidgetRef ref, int currentStreak) async {
    final ratingService = ref.read(ratingServiceProvider);
    final shouldShow = await ratingService.shouldShowSoftPrompt(currentStreak);

    if (shouldShow && context.mounted) {
      await ratingService.markAsPrompted(currentStreak);
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => SoftRateDialog(currentStreak: currentStreak),
        );
      }
    }
  }
}
