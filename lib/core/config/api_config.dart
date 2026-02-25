/// API Configuration for Quran.com API
class ApiConfig {
  ApiConfig._();

  /// Base URL for Quran.com API v4
  static const String baseUrl = 'https://api.quran.com/api/v4';

  /// Endpoints
  static const String versesRandom = '/verses/random';
  static const String versesByKey = '/verses/by_key';
  static const String chapters = '/chapters';
  static const String chapterInfo = '/chapters';
  static const String recitations = '/resources/recitations';

  /// Translation IDs
  /// 131 = Sahih International (English)
  /// 20 = Wahid Abd. Rahim (Indonesian)
  /// 161 = Mustafa Khattab (English)
  static const String defaultTranslation = '131';

  /// Reciter IDs for audio
  /// 5 = Mishary Rashid Alafasy
  /// 3 = Abdul Basit Murattal
  /// 4 = Abdul Basit Mujawwad
  static const String defaultReciter = '5';

  /// Query Parameters
  static const Map<String, String> defaultParams = {
    'translations': defaultTranslation,
    'language': 'en',
    'fields': 'text_uthmani,chapter_id,hizb_number,verse_number',
  };

  /// Timeout duration in seconds
  static const int timeoutSeconds = 30;

  /// Headers
  static const Map<String, String> headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
}
