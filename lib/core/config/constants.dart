/// App Constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Quran Jar';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyLastPullTimestamp = 'last_pull_timestamp';
  static const String keySavedVerses = 'saved_verses';
  static const String keyTodayVerse = 'today_verse';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keySelectedTranslation = 'selected_translation';
  static const String keyVerseSelectionMode = 'verse_selection_mode';
  static const String keyInternetAccepted = 'internet_accepted';

  // Duration
  static const int dailyPullHours = 24;
  static const Duration dailyPullDuration = Duration(hours: dailyPullHours);

  // Animation Duration
  static const int jarAnimationDurationMs = 800;
  static const int verseCardAnimationDurationMs = 600;
  static const int pageTransitionDurationMs = 300;

  // Share Image Config
  static const double shareImageWidth = 1080;
  static const double shareImageHeight = 1920;
  static const int shareImageQuality = 95;

  // Audio Config
  static const double audioFadeDurationMs = 300;

  // Jar Visual Config
  static const double jarWidth = 200;
  static const double jarHeight = 280;
  static const double jarBorderRadius = 20;
}

/// Verse Selection Mode
enum VerseSelectionMode {
  curated('curated'),
  random('random');

  final String value;
  const VerseSelectionMode(this.value);

  static VerseSelectionMode fromValue(String value) {
    return VerseSelectionMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => VerseSelectionMode.random,
    );
  }
}
