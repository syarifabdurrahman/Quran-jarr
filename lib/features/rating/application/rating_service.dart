import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quran_jarr/core/services/preferences_service.dart';

class RatingService {
  final InAppReview _inAppReview = InAppReview.instance;
  final PreferencesService _prefs = PreferencesService.instance;

  Future<bool> shouldShowSoftPrompt(int currentStreak) async {
    // These keys are managed via PreferencesService's internal Hive box
    final bool hasRated = _prefs.getLastRateUsShown() == 'RATED';
    final String? ignoredUntilStr = _prefs.getLastRateUsShown();
    
    if (hasRated) return false;

    if (ignoredUntilStr != null && ignoredUntilStr != 'RATED') {
      try {
        final ignoredUntil = DateTime.parse(ignoredUntilStr);
        if (DateTime.now().isBefore(ignoredUntil)) {
          return false;
        }
      } catch (_) {
        // Invalid date format, proceed
      }
    }

    // Trigger on milestone 7 or 30
    if (currentStreak == 7 || currentStreak == 30) {
      // We check milestone specifically to avoid double prompts
      // Since PreferencesService doesn't have a specific milestone key, we'll just check last show date
      final lastShown = _prefs.getLastRateUsShown();
      if (lastShown != null && lastShown.contains('streak_$currentStreak')) {
        return false;
      }
      return true;
    }
    return false;
  }

  Future<void> markAsPrompted(int currentStreak) async {
    await _prefs.setLastRateUsShown('streak_$currentStreak::${DateTime.now().toIso8601String()}');
  }

  Future<void> remindLater() async {
    // Ignore for 30 days
    final until = DateTime.now().add(const Duration(days: 30));
    await _prefs.setLastRateUsShown(until.toIso8601String());
  }

  Future<void> openStoreListing() async {
    await _prefs.setLastRateUsShown('RATED');
    
    if (await _inAppReview.isAvailable()) {
      _inAppReview.requestReview();
    } else {
      // Fallback - Note: appStoreId should be provided for iOS
      _inAppReview.openStoreListing(appStoreId: '6443424160'); // Example ID or leave empty for Android
    }
  }

  Future<void> openFeedbackEmail() async {
    // We treat this as "remind later" since they had an issue
    final until = DateTime.now().add(const Duration(days: 60));
    await _prefs.setLastRateUsShown(until.toIso8601String());

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@quranjar.app',
      query: 'subject=Quran Jar Feedback',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }
}

final ratingServiceProvider = Provider<RatingService>((ref) {
  return RatingService();
});
