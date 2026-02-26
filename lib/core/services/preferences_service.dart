import 'package:hive_flutter/hive_flutter.dart';
import '../config/constants.dart';
import '../config/translations.dart';

/// App Preferences Service
/// Stores user preferences like selected translation, theme, etc.
class PreferencesService {
  PreferencesService._();

  static final PreferencesService _instance = PreferencesService._();
  static PreferencesService get instance => _instance;

  late Box _prefsBox;

  /// Initialize preferences
  Future<void> initialize() async {
    await Hive.initFlutter();
    _prefsBox = await Hive.openBox('preferences');
  }

  // ==================== Onboarding Preferences ====================

  /// Check if onboarding is completed
  bool isOnboardingCompleted() {
    return _prefsBox.get(AppConstants.keyOnboardingCompleted, defaultValue: false) as bool;
  }

  /// Set onboarding as completed
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefsBox.put(AppConstants.keyOnboardingCompleted, completed);
  }

  /// Check if internet requirement is accepted
  bool isInternetAccepted() {
    return _prefsBox.get(AppConstants.keyInternetAccepted, defaultValue: false) as bool;
  }

  /// Set internet requirement acceptance
  Future<void> setInternetAccepted(bool accepted) async {
    await _prefsBox.put(AppConstants.keyInternetAccepted, accepted);
  }

  /// Get verse selection mode
  VerseSelectionMode getVerseSelectionMode() {
    final value = _prefsBox.get(AppConstants.keyVerseSelectionMode, defaultValue: VerseSelectionMode.random.value) as String;
    return VerseSelectionMode.fromValue(value);
  }

  /// Set verse selection mode
  Future<void> setVerseSelectionMode(VerseSelectionMode mode) async {
    await _prefsBox.put(AppConstants.keyVerseSelectionMode, mode.value);
  }

  // ==================== Translation Preferences ====================

  /// Get the selected translation ID
  String getTranslationId() {
    return _prefsBox.get(AppConstants.keySelectedTranslation,
            defaultValue: AvailableTranslations.defaultTranslation.id)
        as String;
  }

  /// Set the selected translation ID
  Future<void> setTranslationId(String translationId) async {
    await _prefsBox.put(AppConstants.keySelectedTranslation, translationId);
  }

  /// Get the selected translation object
  Translation getSelectedTranslation() {
    final id = getTranslationId();
    return AvailableTranslations.getById(id);
  }

  /// Get all available translations
  List<Translation> getAvailableTranslations() {
    return AvailableTranslations.allTranslations;
  }

  // ==================== Notification Preferences ====================

  /// Get verses per day (default 1)
  int getVersesPerDay() {
    return _prefsBox.get('verses_per_day', defaultValue: 1) as int;
  }

  /// Set verses per day (minimum 1, no maximum limit)
  Future<void> setVersesPerDay(int count) async {
    // Minimum 1, no maximum limit
    final clamped = count < 1 ? 1 : count;
    await _prefsBox.put('verses_per_day', clamped);
  }

  /// Get today's jar tap count
  int getTodayJarTapCount() {
    final lastTapDate = _prefsBox.get('last_tap_date', defaultValue: '') as String;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    // Reset count if it's a new day
    if (lastTapDate != today) {
      return 0;
    }

    return _prefsBox.get('today_tap_count', defaultValue: 0) as int;
  }

  /// Increment today's jar tap count
  Future<void> incrementJarTapCount() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastTapDate = _prefsBox.get('last_tap_date', defaultValue: '') as String;

    int newCount;
    if (lastTapDate != today) {
      // New day, reset count
      newCount = 1;
      await _prefsBox.put('last_tap_date', today);
    } else {
      // Same day, increment count
      final currentCount = _prefsBox.get('today_tap_count', defaultValue: 0) as int;
      newCount = currentCount + 1;
    }

    await _prefsBox.put('today_tap_count', newCount);
  }

  /// Check if user can tap the jar today
  bool canTapJarToday() {
    final limit = getVersesPerDay();
    // Unlimited taps (9999 or higher)
    if (limit >= 9999) return true;
    final todayCount = getTodayJarTapCount();
    return todayCount < limit;
  }

  /// Get remaining jar taps for today
  int getRemainingJarTaps() {
    final limit = getVersesPerDay();
    // Unlimited taps (9999 or higher)
    if (limit >= 9999) return 9999;
    final todayCount = getTodayJarTapCount();
    final remaining = limit - todayCount;
    return remaining < 0 ? 0 : remaining;
  }

  /// Check if daily notification is enabled
  bool isDailyNotificationEnabled() {
    return _prefsBox.get('daily_notification_enabled', defaultValue: false) as bool;
  }

  /// Set daily notification enabled
  Future<void> setDailyNotificationEnabled(bool enabled) async {
    await _prefsBox.put('daily_notification_enabled', enabled);
  }

  /// Get notification time (hour, minute)
  (int hour, int minute) getNotificationTime() {
    final hour = _prefsBox.get('notification_hour', defaultValue: 7) as int;
    final minute = _prefsBox.get('notification_minute', defaultValue: 0) as int;
    return (hour, minute);
  }

  /// Set notification time
  Future<void> setNotificationTime(int hour, int minute) async {
    await _prefsBox.put('notification_hour', hour);
    await _prefsBox.put('notification_minute', minute);
  }

  // ==================== Pending Verse Key ====================

  /// Set pending verse key from notification tap (persisted)
  Future<void> setPendingVerseKey(String verseKey) async {
    await _prefsBox.put('pending_verse_key', verseKey);
  }

  /// Get and clear pending verse key from storage
  String? getAndClearPendingVerseKey() {
    final key = _prefsBox.get('pending_verse_key', defaultValue: null) as String?;
    // Clear immediately after reading
    _prefsBox.delete('pending_verse_key');
    return key;
  }

  // ==================== Font Size Preferences ====================

  /// Get Arabic font size multiplier (0.8 to 1.5, default 1.0)
  double getArabicFontSizeMultiplier() {
    return _prefsBox.get('arabic_font_multiplier', defaultValue: 1.0) as double;
  }

  /// Set Arabic font size multiplier
  Future<void> setArabicFontSizeMultiplier(double multiplier) async {
    // Clamp between 0.8 and 1.5
    final clamped = multiplier.clamp(0.8, 1.5);
    await _prefsBox.put('arabic_font_multiplier', clamped);
  }

  /// Get English font size multiplier (0.8 to 1.5, default 1.0)
  double getEnglishFontSizeMultiplier() {
    return _prefsBox.get('english_font_multiplier', defaultValue: 1.0) as double;
  }

  /// Set English font size multiplier
  Future<void> setEnglishFontSizeMultiplier(double multiplier) async {
    // Clamp between 0.8 and 1.5
    final clamped = multiplier.clamp(0.8, 1.5);
    await _prefsBox.put('english_font_multiplier', clamped);
  }

  // ==================== Clear Preferences ====================

  /// Clear all preferences
  Future<void> clearAll() async {
    await _prefsBox.clear();
  }

  /// Close the preferences box
  Future<void> close() async {
    await _prefsBox.close();
  }
}
