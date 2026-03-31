import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quran_jarr/core/services/preferences_service.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';

/// Rate Us Service
/// Shows rate us dialog once per day after reading verses
class RateUsService {
  RateUsService._();

  static final RateUsService instance = RateUsService._();

  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.simpurrapps.quran_jarr';

  /// Check if we should show rate us dialog today
  bool shouldShowRateUs() {
    final prefs = PreferencesService.instance;
    final lastShown = prefs.getLastRateUsShown();

    if (lastShown == null) {
      return true; // Never shown before
    }

    final now = DateTime.now();
    final lastShownDate = DateTime.parse(lastShown);
    final daysSinceLastShown = now.difference(lastShownDate).inDays;

    // Show if at least 1 day has passed
    return daysSinceLastShown >= 1;
  }

  /// Mark rate us as shown today
  Future<void> markAsShown() async {
    final prefs = PreferencesService.instance;
    await prefs.setLastRateUsShown(DateTime.now().toIso8601String());
  }

  /// Show rate us dialog
  Future<void> showRateUsDialog(BuildContext context) async {
    if (!shouldShowRateUs()) {
      return; // Don't show if already shown today
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.midnightPeriwinkle
        : AppColors.sageGreen;
    final bgColor = isDark ? AppColors.darkCard : AppColors.cream;
    final accentColor = isDark ? AppColors.midnightGold : AppColors.terracotta;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Star icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.star_rounded, color: accentColor, size: 36),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Enjoying Quran Jarr?',
              style: AppTextStyles.loraHeading().copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'If you find this app helpful for your daily Quran reading, please consider rating us on the Play Store.',
              style: AppTextStyles.loraBodySmall().copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Rate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _launchPlayStore();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                  await markAsShown();
                },
                icon: const Icon(Icons.star_rounded, color: Colors.white),
                label: const Text('Rate Us'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Later button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  markAsShown();
                },
                child: Text(
                  'Maybe Later',
                  style: AppTextStyles.loraBodyMedium().copyWith(
                    color: primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Launch Play Store URL
  Future<void> _launchPlayStore() async {
    final uri = Uri.parse(_playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
