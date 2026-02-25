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

  // ==================== Theme Preferences ====================

  /// Check if dark mode is enabled
  bool isDarkMode() {
    return _prefsBox.get('dark_mode', defaultValue: false) as bool;
  }

  /// Set dark mode
  Future<void> setDarkMode(bool enabled) async {
    await _prefsBox.put('dark_mode', enabled);
  }

  // ==================== Notification Preferences ====================

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
