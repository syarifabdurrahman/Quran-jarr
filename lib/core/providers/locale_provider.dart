import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/providers/preferences_provider.dart';
import 'package:quran_jarr/core/services/locale_service.dart';

/// Locale Provider
/// Provides the current app locale based on translation preference
/// Reacts to preference changes automatically
final localeProvider = Provider<Locale>((ref) {
  return LocaleService.instance.getCurrentLocale();
});

/// Locale Notifier
/// Manages locale state reactively
class LocaleNotifier extends StateNotifier<Locale> {
  final Ref ref;

  LocaleNotifier(this.ref) : super(const Locale('en')) {
    // Initialize with current locale
    _updateLocale();
    // Listen to preferences changes
    ref.listen(preferencesNotifierProvider, (previous, next) {
      _updateLocale();
    });
  }

  void _updateLocale() {
    final translationId = ref.read(preferencesNotifierProvider).prefs.getSelectedTranslation().id;
    final newLocale = translationId == 'indonesian' || translationId == 'id.indonesian'
        ? const Locale('id')
        : const Locale('en');

    state = newLocale;
  }
}

/// Locale Notifier Provider
/// Provides a reactive locale that updates when translation changes
final localeNotifierProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref);
});
