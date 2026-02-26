import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/services/preferences_service.dart';
import 'package:quran_jarr/core/services/notification_service.dart';
import '../config/translations.dart';

/// Version counter to force state updates
class _PreferencesState {
  final PreferencesService prefs;
  final int version;

  _PreferencesState(this.prefs, this.version);

  _PreferencesState increment() => _PreferencesState(prefs, version + 1);
}

/// Preferences Notifier
/// Manages app preferences like selected translation
class PreferencesNotifier extends StateNotifier<_PreferencesState> {
  PreferencesNotifier() : super(_PreferencesState(PreferencesService.instance, 0));

  PreferencesService get _prefs => state.prefs;

  /// Force rebuild by incrementing version
  void _notify() {
    state = state.increment();
  }

  /// Set the selected translation
  Future<void> setTranslation(Translation translation) async {
    await _prefs.setTranslationId(translation.id);
    _notify();
  }

  /// Refresh the preferences state
  void refresh() {
    _notify();
  }

  /// Toggle daily notification
  Future<void> toggleDailyNotification() async {
    final currentEnabled = _prefs.isDailyNotificationEnabled();
    await _prefs.setDailyNotificationEnabled(!currentEnabled);

    if (!currentEnabled) {
      // Enable notification - schedule it
      final (hour, minute) = _prefs.getNotificationTime();
      await NotificationService.instance.scheduleDailyNotification(
        TimeOfDay(hour: hour, minute: minute),
      );
    } else {
      // Disable notification - cancel all
      await NotificationService.instance.cancelAll();
    }

    _notify();
  }

  /// Set daily notification enabled
  Future<void> setDailyNotificationEnabled(bool enabled) async {
    await _prefs.setDailyNotificationEnabled(enabled);

    if (enabled) {
      final (hour, minute) = _prefs.getNotificationTime();
      await NotificationService.instance.scheduleDailyNotification(
        TimeOfDay(hour: hour, minute: minute),
      );
    } else {
      await NotificationService.instance.cancelAll();
    }

    _notify();
  }

  /// Set notification time
  Future<void> setNotificationTime(TimeOfDay time) async {
    await _prefs.setNotificationTime(time.hour, time.minute);

    // Reschedule if notification is enabled
    if (_prefs.isDailyNotificationEnabled()) {
      await NotificationService.instance.scheduleDailyNotification(time);
    }

    _notify();
  }

  /// Set Arabic font size multiplier
  Future<void> setArabicFontSize(double multiplier) async {
    await _prefs.setArabicFontSizeMultiplier(multiplier);
    _notify();
  }

  /// Set English font size multiplier
  Future<void> setEnglishFontSize(double multiplier) async {
    await _prefs.setEnglishFontSizeMultiplier(multiplier);
    _notify();
  }

  /// Schedule test notification (shows immediately)
  Future<void> scheduleTestNotification() async {
    // Request permission first
    await NotificationService.instance.requestPermission();

    final (hour, minute) = _prefs.getNotificationTime();
    await NotificationService.instance.scheduleDailyNotification(
      TimeOfDay(hour: hour, minute: minute),
      testMode: true,
    );
  }
}

/// Preferences Provider
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService.instance;
});

/// Preferences Notifier Provider
final preferencesNotifierProvider =
    StateNotifierProvider<PreferencesNotifier, _PreferencesState>((ref) {
  return PreferencesNotifier();
});

/// Selected Translation Provider
final selectedTranslationProvider = Provider<Translation>((ref) {
  return ref.watch(preferencesNotifierProvider).prefs.getSelectedTranslation();
});

/// Daily Notification Enabled Provider
final dailyNotificationEnabledProvider = Provider<bool>((ref) {
  return ref.watch(preferencesNotifierProvider).prefs.isDailyNotificationEnabled();
});

/// Notification Time Provider
final notificationTimeProvider = Provider<TimeOfDay>((ref) {
  final (hour, minute) = ref.watch(preferencesNotifierProvider).prefs.getNotificationTime();
  return TimeOfDay(hour: hour, minute: minute);
});

/// Arabic Font Size Multiplier Provider
final arabicFontSizeProvider = Provider<double>((ref) {
  return ref.watch(preferencesNotifierProvider).prefs.getArabicFontSizeMultiplier();
});

/// English Font Size Multiplier Provider
final englishFontSizeProvider = Provider<double>((ref) {
  return ref.watch(preferencesNotifierProvider).prefs.getEnglishFontSizeMultiplier();
});
