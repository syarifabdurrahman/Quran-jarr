import 'package:hive_flutter/hive_flutter.dart';
import '../config/constants.dart';
import '../config/translations.dart';

/// App Preferences Service
/// Stores user preferences like selected translation, theme, etc.
class PreferencesService {
  PreferencesService._();

  static final PreferencesService _instance = PreferencesService._();
  static PreferencesService get instance => _instance;

  Box? _prefsBox;

  Box get _box {
    if (_prefsBox == null) {
      throw StateError('PreferencesService must be initialized before use');
    }
    return _prefsBox!;
  }

  /// Initialize preferences
  Future<void> initialize() async {
    await Hive.initFlutter();
    _prefsBox = await Hive.openBox('preferences');
  }

  // ==================== Onboarding Preferences ====================

  /// Check if onboarding is completed
  bool isOnboardingCompleted() {
    return _box.get(
          AppConstants.keyOnboardingCompleted,
          defaultValue: false,
        )
        as bool;
  }

  /// Set onboarding as completed
  Future<void> setOnboardingCompleted(bool completed) async {
    await _box.put(AppConstants.keyOnboardingCompleted, completed);
  }

  /// Check if internet requirement is accepted
  bool isInternetAccepted() {
    return _box.get(AppConstants.keyInternetAccepted, defaultValue: false)
        as bool;
  }

  /// Set internet requirement acceptance
  Future<void> setInternetAccepted(bool accepted) async {
    await _box.put(AppConstants.keyInternetAccepted, accepted);
  }

  /// Get verse selection mode
  VerseSelectionMode getVerseSelectionMode() {
    final value =
        _box.get(
              AppConstants.keyVerseSelectionMode,
              defaultValue: VerseSelectionMode.random.value,
            )
            as String;
    return VerseSelectionMode.fromValue(value);
  }

  /// Set verse selection mode
  Future<void> setVerseSelectionMode(VerseSelectionMode mode) async {
    await _box.put(AppConstants.keyVerseSelectionMode, mode.value);
  }

  // ==================== Translation Preferences ====================

  /// Get the selected translation ID
  String getTranslationId() {
    return _box.get(
          AppConstants.keySelectedTranslation,
          defaultValue: AvailableTranslations.defaultTranslation.id,
        )
        as String;
  }

  /// Set the selected translation ID
  Future<void> setTranslationId(String translationId) async {
    await _box.put(AppConstants.keySelectedTranslation, translationId);
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
    return _box.get('verses_per_day', defaultValue: 1) as int;
  }

  /// Set verses per day (minimum 1, no maximum limit)
  Future<void> setVersesPerDay(int count) async {
    // Minimum 1, no maximum limit
    final clamped = count < 1 ? 1 : count;
    await _box.put('verses_per_day', clamped);
  }

  /// Get today's jar tap count
  /// Resets at the notification time (24-hour cycle from notification time)
  int getTodayJarTapCount() {
    final now = DateTime.now();
    final (hour, minute) = getNotificationTime();
    final lastResetDate =
        _box.get('last_reset_date', defaultValue: '') as String;

    // Calculate the notification time for today and yesterday
    final todayNotificationTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    final yesterdayNotificationTime = todayNotificationTime.subtract(
      const Duration(days: 1),
    );

    // Determine the most recent reset time
    DateTime lastReset;
    if (lastResetDate.isEmpty) {
      // First time ever - use yesterday's notification time as reset
      lastReset = yesterdayNotificationTime;
    } else {
      lastReset = DateTime.parse(lastResetDate);
    }

    // Check if we should reset (current time is after today's notification time
    // and last reset was before today's notification time)
    if (now.isAfter(todayNotificationTime) &&
        lastReset.isBefore(todayNotificationTime)) {
      // New cycle - reset count
      return 0;
    }

    // Still in the same cycle, return current count
    return _box.get('today_tap_count', defaultValue: 0) as int;
  }

  /// Increment today's jar tap count
  Future<void> incrementJarTapCount() async {
    final now = DateTime.now();
    final (hour, minute) = getNotificationTime();
    final todayNotificationTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    final lastResetDate =
        _box.get('last_reset_date', defaultValue: '') as String;

    int newCount;
    DateTime lastReset;
    if (lastResetDate.isEmpty) {
      lastReset = todayNotificationTime.subtract(const Duration(days: 1));
    } else {
      lastReset = DateTime.parse(lastResetDate);
    }

    // Check if we need to reset (new cycle)
    if (now.isAfter(todayNotificationTime) &&
        lastReset.isBefore(todayNotificationTime)) {
      // New cycle, reset count to 1
      newCount = 1;
      await _box.put('last_reset_date', now.toIso8601String());
    } else {
      // Same cycle, increment count
      final currentCount =
          _box.get('today_tap_count', defaultValue: 0) as int;
      newCount = currentCount + 1;
    }

    await _box.put('today_tap_count', newCount);
  }

  /// Grant an extra tap for today (used after rewarded ad)
  Future<void> grantExtraTap() async {
    final currentCount = getTodayJarTapCount();
    if (currentCount > 0) {
      // We reduce the count to grant one more tap
      await _box.put('today_tap_count', currentCount - 1);
    }
  }

  /// Check if user can tap the jar today
  bool canTapJarToday() {
    final limit = getVersesPerDay();
    final todayCount = getTodayJarTapCount();
    return todayCount < limit;
  }

  /// Get remaining jar taps for today
  int getRemainingJarTaps() {
    final limit = getVersesPerDay();
    final todayCount = getTodayJarTapCount();
    final remaining = limit - todayCount;
    return remaining < 0 ? 0 : remaining;
  }

  /// Check if daily notification is enabled
  bool isDailyNotificationEnabled() {
    return _box.get('daily_notification_enabled', defaultValue: false)
        as bool;
  }

  /// Set daily notification enabled
  Future<void> setDailyNotificationEnabled(bool enabled) async {
    await _box.put('daily_notification_enabled', enabled);
  }

  /// Get notification time (hour, minute)
  (int hour, int minute) getNotificationTime() {
    final hour = _box.get('notification_hour', defaultValue: 7) as int;
    final minute = _box.get('notification_minute', defaultValue: 0) as int;
    return (hour, minute);
  }

  /// Set notification time
  Future<void> setNotificationTime(int hour, int minute) async {
    await _box.put('notification_hour', hour);
    await _box.put('notification_minute', minute);
  }

  // ==================== Pending Verse Key ====================

  /// Set pending verse key from notification tap (persisted)
  Future<void> setPendingVerseKey(String verseKey) async {
    await _box.put('pending_verse_key', verseKey);
  }

  /// Get and clear pending verse key from storage
  String? getAndClearPendingVerseKey() {
    final key =
        _box.get('pending_verse_key', defaultValue: null) as String?;
    // Clear immediately after reading
    _box.delete('pending_verse_key');
    return key;
  }

  // ==================== Font Size Preferences ====================

  /// Get Arabic font size multiplier (0.8 to 1.5, default 1.0)
  double getArabicFontSizeMultiplier() {
    return _box.get('arabic_font_multiplier', defaultValue: 1.0) as double;
  }

  /// Set Arabic font size multiplier
  Future<void> setArabicFontSizeMultiplier(double multiplier) async {
    // Clamp between 0.8 and 1.5
    final clamped = multiplier.clamp(0.8, 1.5);
    await _box.put('arabic_font_multiplier', clamped);
  }

  /// Get English font size multiplier (0.8 to 1.5, default 1.0)
  double getEnglishFontSizeMultiplier() {
    return _box.get('english_font_multiplier', defaultValue: 1.0)
        as double;
  }

  /// Set English font size multiplier
  Future<void> setEnglishFontSizeMultiplier(double multiplier) async {
    // Clamp between 0.8 and 1.5
    final clamped = multiplier.clamp(0.8, 1.5);
    await _box.put('english_font_multiplier', clamped);
  }

  // ==================== Theme Preferences ====================

  /// Get theme mode (0 = system, 1 = light, 2 = dark)
  int getThemeMode() {
    return _box.get('theme_mode', defaultValue: 0) as int;
  }

  /// Set theme mode
  Future<void> setThemeMode(int mode) async {
    await _box.put('theme_mode', mode);
  }

  // ==================== Accessibility Preferences ====================

  /// Get reduced motion preference
  bool getReducedMotion() {
    return _box.get('reduced_motion', defaultValue: false) as bool;
  }

  /// Set reduced motion preference
  Future<void> setReducedMotion(bool enabled) async {
    await _box.put('reduced_motion', enabled);
  }

  // ==================== Jar Type Preferences ====================

  /// Get jar type (0 = classic, 1 = vintage, 2 = modern, 3 = ornate)
  int getJarType() {
    return _box.get('jar_type', defaultValue: 0) as int;
  }

  /// Set jar type
  Future<void> setJarType(int type) async {
    await _box.put('jar_type', type);
  }

  // ==================== Audio Preferences ====================

  /// Get the selected reciter ID
  int getReciterId() {
    return _box.get('selected_reciter_id', defaultValue: 2) as int;
  }

  /// Set the selected reciter ID
  Future<void> setReciterId(int id) async {
    await _box.put('selected_reciter_id', id);
  }

  // ==================== Rate Us Preferences ====================

  /// Get last rate us shown date (ISO 8601 string)
  String? getLastRateUsShown() {
    return _box.get('last_rate_us_shown') as String?;
  }

  /// Set last rate us shown date
  Future<void> setLastRateUsShown(String date) async {
    await _box.put('last_rate_us_shown', date);
  }

  // ==================== Dhikr Preferences ====================

  /// Get dhikr count
  int getDhikrCount() {
    return _box.get('dhikr_count', defaultValue: 0) as int;
  }

  /// Set dhikr count
  Future<void> setDhikrCount(int count) async {
    await _box.put('dhikr_count', count);
  }

  // ==================== Clear Preferences ====================

  /// Clear all preferences
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Close the preferences box
  Future<void> close() async {
    await _box.close();
  }
}
