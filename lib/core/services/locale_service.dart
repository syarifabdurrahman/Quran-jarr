import 'package:flutter/material.dart';
import 'package:quran_jarr/core/services/preferences_service.dart';
import 'package:quran_jarr/l10n/app_localizations.dart';

/// Locale Service
/// Manages app locale/language
class LocaleService {
  LocaleService._();

  static final LocaleService _instance = LocaleService._();
  static LocaleService get instance => _instance;

  final _supportedLocales = const [
    Locale('en'), // English
    Locale('id'), // Indonesian
  ];

  List<Locale> get supportedLocales => _supportedLocales;

  /// Get current locale based on translation preference
  Locale getCurrentLocale() {
    final translationId = PreferencesService.instance.getSelectedTranslation().id;

    // Map translation ID to locale
    switch (translationId) {
      case 'indonesian':
      case 'id.indonesian':
        return const Locale('id');
      default:
        return const Locale('en');
    }
  }

  /// Get locale display name
  String getLocaleDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'id':
        return 'Bahasa Indonesia';
      case 'en':
      default:
        return 'English';
    }
  }
}

/// AppLocalizations Extension
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
