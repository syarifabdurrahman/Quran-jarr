import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/services/preferences_service.dart';
import 'package:quran_jarr/core/services/notification_service.dart';
import '../config/translations.dart';

/// Preferences Notifier
/// Manages app preferences like selected translation
class PreferencesNotifier extends StateNotifier<PreferencesService> {
  PreferencesNotifier() : super(PreferencesService.instance);

  /// Set the selected translation
  Future<void> setTranslation(Translation translation) async {
    await state.setTranslationId(translation.id);
    state = PreferencesService.instance;
  }

  /// Refresh the preferences state
  void refresh() {
    state = PreferencesService.instance;
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    final currentMode = state.isDarkMode();
    await state.setDarkMode(!currentMode);
    state = PreferencesService.instance;
  }

  /// Set dark mode
  Future<void> setDarkMode(bool enabled) async {
    await state.setDarkMode(enabled);
    state = PreferencesService.instance;
  }

  /// Toggle daily notification
  Future<void> toggleDailyNotification() async {
    final currentEnabled = state.isDailyNotificationEnabled();
    await state.setDailyNotificationEnabled(!currentEnabled);

    if (!currentEnabled) {
      // Enable notification - schedule it
      final (hour, minute) = state.getNotificationTime();
      await NotificationService.instance.scheduleDailyNotification(
        TimeOfDay(hour: hour, minute: minute),
      );
    } else {
      // Disable notification - cancel all
      await NotificationService.instance.cancelAll();
    }

    state = PreferencesService.instance;
  }

  /// Set daily notification enabled
  Future<void> setDailyNotificationEnabled(bool enabled) async {
    await state.setDailyNotificationEnabled(enabled);

    if (enabled) {
      final (hour, minute) = state.getNotificationTime();
      await NotificationService.instance.scheduleDailyNotification(
        TimeOfDay(hour: hour, minute: minute),
      );
    } else {
      await NotificationService.instance.cancelAll();
    }

    state = PreferencesService.instance;
  }

  /// Set notification time
  Future<void> setNotificationTime(TimeOfDay time) async {
    await state.setNotificationTime(time.hour, time.minute);

    // Reschedule if notification is enabled
    if (state.isDailyNotificationEnabled()) {
      await NotificationService.instance.scheduleDailyNotification(time);
    }

    state = PreferencesService.instance;
  }

  /// Set Arabic font size multiplier
  Future<void> setArabicFontSize(double multiplier) async {
    await state.setArabicFontSizeMultiplier(multiplier);
    state = PreferencesService.instance;
  }

  /// Set English font size multiplier
  Future<void> setEnglishFontSize(double multiplier) async {
    await state.setEnglishFontSizeMultiplier(multiplier);
    state = PreferencesService.instance;
  }
}

/// Preferences Provider
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService.instance;
});

/// Preferences Notifier Provider
final preferencesNotifierProvider =
    StateNotifierProvider<PreferencesNotifier, PreferencesService>((ref) {
  return PreferencesNotifier();
});

/// Selected Translation Provider
final selectedTranslationProvider = Provider<Translation>((ref) {
  return ref.watch(preferencesNotifierProvider).getSelectedTranslation();
});

/// Dark Mode Provider
final darkModeProvider = Provider<bool>((ref) {
  return ref.watch(preferencesNotifierProvider).isDarkMode();
});

/// Daily Notification Enabled Provider
final dailyNotificationEnabledProvider = Provider<bool>((ref) {
  return ref.watch(preferencesNotifierProvider).isDailyNotificationEnabled();
});

/// Notification Time Provider
final notificationTimeProvider = Provider<TimeOfDay>((ref) {
  final (hour, minute) = ref.watch(preferencesNotifierProvider).getNotificationTime();
  return TimeOfDay(hour: hour, minute: minute);
});

/// Arabic Font Size Multiplier Provider
final arabicFontSizeProvider = Provider<double>((ref) {
  return ref.watch(preferencesNotifierProvider).getArabicFontSizeMultiplier();
});

/// English Font Size Multiplier Provider
final englishFontSizeProvider = Provider<double>((ref) {
  return ref.watch(preferencesNotifierProvider).getEnglishFontSizeMultiplier();
});
