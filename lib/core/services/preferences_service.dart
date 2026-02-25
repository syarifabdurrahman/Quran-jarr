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
    return AvailableTranslations.englishTranslations;
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
