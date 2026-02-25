/// API Configuration for Quran API
class ApiConfig {
  ApiConfig._();

  /// Base URL for Quran API (quranapi.pages.dev)
  static const String baseUrl = 'https://quranapi.pages.dev/api';

  /// Base URL for Indonesian Quran API (equran.id)
  static const String indoBaseUrl = 'https://equran.id/api/v2';

  /// Base URL for Tafsir API (same as Quran API)
  static const String tafsirBaseUrl = 'https://quranapi.pages.dev/api';

  /// Quran has 114 surahs (chapters)
  static const int totalSurahs = 114;

  /// Default reciter for audio (1 = Mishary Rashid Al Afasy)
  static const int defaultReciter = 1;

  /// Timeout duration in seconds
  static const int timeoutSeconds = 30;

  /// Headers
  static const Map<String, String> headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
}
