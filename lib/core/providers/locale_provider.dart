import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/providers/preferences_provider.dart';
import 'package:quran_jarr/core/services/locale_service.dart';

/// Locale Provider
/// Provides the current app locale based on translation preference
final localeProvider = Provider<Locale>((ref) {
  return LocaleService.instance.getCurrentLocale();
});

/// Locale Notifier Provider
/// Allows changing the app locale
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(LocaleService.instance.getCurrentLocale());

  /// Update locale based on translation preference
  void updateLocale() {
    state = LocaleService.instance.getCurrentLocale();
  }
}

final localeNotifierProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final notifier = LocaleNotifier();

  // Watch for translation changes and update locale
  ref.listen(preferencesNotifierProvider, (previous, next) {
    if (previous != null) {
      final prevTrans = previous.prefs.getSelectedTranslation().id;
      final nextTrans = next.prefs.getSelectedTranslation().id;
      if (prevTrans != nextTrans) {
        notifier.updateLocale();
      }
    }
  });

  return notifier;
});
