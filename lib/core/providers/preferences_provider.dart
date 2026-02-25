import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/services/preferences_service.dart';
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
