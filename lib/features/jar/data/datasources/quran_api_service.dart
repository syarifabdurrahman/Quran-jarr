import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:quran_jarr/core/config/api_config.dart';
import 'package:quran_jarr/core/network/api_exception.dart';
import '../models/verse_model.dart';

/// Quran API Service
/// Handles all API calls to Quran API (quranapi.pages.dev) and equran.id for Indonesian
class QuranApiService {
  // Cache for tafsir
  final Map<String, String> _tafsirCache = {};

  // Cache for Indonesian surah data to avoid repeated fetches
  final Map<int, List<dynamic>> _indoSurahCache = {};

  // Cache for Indonesian tafsir data
  final Map<int, List<dynamic>> _indoTafsirCache = {};

  // Dio instance for Quran API
  Dio get _quranDio => Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: ApiConfig.timeoutSeconds),
          receiveTimeout: const Duration(seconds: ApiConfig.timeoutSeconds),
          headers: ApiConfig.headers,
        ),
      );

  // Dio instance for Indonesian API
  Dio get _indoDio => Dio(
        BaseOptions(
          baseUrl: ApiConfig.indoBaseUrl,
          connectTimeout: const Duration(seconds: ApiConfig.timeoutSeconds),
          receiveTimeout: const Duration(seconds: ApiConfig.timeoutSeconds),
          headers: ApiConfig.headers,
        ),
      );

  // Random number generator
  final _random = Random();

  QuranApiService();

  /// Get a random verse from Quran with translation
  /// Optional surahNumbers parameter for curated mode
  /// Includes retry logic for curated mode - if a surah fails, tries another
  Future<Either<ApiException, VerseModel>> getRandomVerse({
    String translationId = 'english', // Default to English
    List<int>? surahNumbers, // Optional list of surah numbers to choose from
  }) async {
    // For curated mode, try up to 3 different surahs if one fails
    final maxRetries = surahNumbers != null ? 3 : 1;
    List<int>? availableSurahs = surahNumbers;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        // Generate random surah and ayah
        final surahNo = availableSurahs != null && availableSurahs.isNotEmpty
            ? availableSurahs[_random.nextInt(availableSurahs.length)]
            : _random.nextInt(ApiConfig.totalSurahs) + 1;

        // First get the surah to know how many ayahs it has
        final surahResponse = await _quranDio.get('/$surahNo.json');
        final totalAyah = surahResponse.data['totalAyah'] as int? ?? 7;

        // Get random ayah from this surah
        final ayahNo = _random.nextInt(totalAyah) + 1;

        // Fetch the verse
        final response = await _quranDio.get('/$surahNo/$ayahNo.json');
        final data = response.data as Map<String, dynamic>;

        final result = await _parseVerseResponse(data, translationId);

        // If successful, return the result
        if (result.isRight()) {
          return result;
        }

        // If parsing failed, try another surah in curated mode
        if (surahNumbers != null && availableSurahs != null) {
          availableSurahs = availableSurahs.where((s) => s != surahNo).toList();
          if (availableSurahs.isEmpty) break;
          continue;
        }

        return result;
      } on DioException catch (e) {
        // For curated mode, retry with another surah
        if (surahNumbers != null && attempt < maxRetries - 1) {
          if (availableSurahs != null && availableSurahs.length > 1) {
            // Remove the failed surah and try again
            continue;
          }
        }
        // If not curated mode or no more retries, return the error
        return Left(ApiException.fromDioError(e));
      } catch (e) {
        // Catch any other exceptions (parsing errors, null issues, etc.)
        // For curated mode, retry with another surah
        if (surahNumbers != null && attempt < maxRetries - 1) {
          if (availableSurahs != null && availableSurahs.length > 1) {
            continue;
          }
        }
        // If not curated mode or no more retries, return the error
        return Left(ApiException('Failed to load verse: ${e.toString()}'));
      }
    }

    // If all retries failed
    return Left(ApiException('Failed to load verse after multiple attempts'));
  }

  /// Get a verse by surah and ayah numbers
  Future<Either<ApiException, VerseModel>> getVerseBySurahAyah(
    int surahNo,
    int ayahNo, {
    String translationId = 'english',
  }) async {
    try {
      final response = await _quranDio.get('/$surahNo/$ayahNo.json');
      final data = response.data as Map<String, dynamic>;

      return await _parseVerseResponse(data, translationId);
    } on DioException catch (e) {
      return Left(ApiException.fromDioError(e));
    } catch (e) {
      return Left(ApiException('Failed to load verse: ${e.toString()}'));
    }
  }

  /// Parse verse response from API
  Future<Either<ApiException, VerseModel>> _parseVerseResponse(
    Map<String, dynamic> data,
    String translationId,
  ) async {
    try {
      final surahNo = data['surahNo'] as int;
      final ayahNo = data['ayahNo'] as int;
      final surahName = data['surahName'] as String? ?? 'Surah $surahNo';
      final surahNameTranslation =
          data['surahNameTranslation'] as String? ?? surahName;
      final arabicText = data['arabic1'] as String? ??
          data['arabic2'] as String? ??
          '';

      // Get translation based on translationId
      String translationText = '';

      // Special handling for Indonesian translation
      if (translationId == 'indonesian') {
        translationText = await _getIndonesianTranslation(surahNo, ayahNo);
      } else {
        // Default handling for other translations (english, etc.)
        if (data.containsKey(translationId)) {
          translationText = data[translationId] as String? ?? '';
        } else if (data.containsKey('english')) {
          translationText = data['english'] as String? ?? '';
        }
      }

      // Get audio URL (Mishary Rashid Al Afasy - reciter 1)
      String? audioUrl;
      final audioData = data['audio'] as Map<String, dynamic>?;
      if (audioData != null && audioData.containsKey('1')) {
        final reciter1 = audioData['1'] as Map<String, dynamic>?;
        audioUrl = reciter1?['url'] as String?;
      }

      final verseKey = '$surahNo:$ayahNo';

      return Right(VerseModel(
        surahNumber: surahNo,
        ayahNumber: ayahNo,
        arabicText: arabicText,
        translation: translationText,
        surahName: surahName,
        surahNameTranslation: surahNameTranslation,
        verseKey: verseKey,
        translationId: translationId,
        audioUrl: audioUrl,
      ));
    } catch (e) {
      return Left(ApiException('Failed to parse verse data: $e'));
    }
  }

  /// Get Indonesian translation from equran.id API
  Future<String> _getIndonesianTranslation(int surahNo, int ayahNo) async {
    try {
      // Check cache first
      final cacheKey = surahNo;
      if (!_indoSurahCache.containsKey(cacheKey)) {
        final response = await _indoDio.get('/surat/$surahNo');
        final data = response.data as Map<String, dynamic>?;
        if (data != null && data.containsKey('data')) {
          final surahData = data['data'] as Map<String, dynamic>?;
          if (surahData != null && surahData.containsKey('ayat')) {
            _indoSurahCache[cacheKey] = surahData['ayat'] as List? ?? [];
          }
        }
      }

      // Find the ayah in the cached surah data
      final ayatList = _indoSurahCache[cacheKey] ?? [];
      for (final ayah in ayatList) {
        final ayahMap = ayah as Map<String, dynamic>?;
        if (ayahMap == null) continue;

        final nomorAyat = ayahMap['nomorAyat'] as int? ?? 0;
        if (nomorAyat == ayahNo) {
          return ayahMap['teksIndonesia'] as String? ?? '';
        }
      }

      return '';
    } catch (e) {
      // Return empty string on error, fallback to no translation
      return '';
    }
  }

  /// Get tafsir for a specific verse
  /// For English: Uses the Quran API tafsir endpoint (Ibn Kathir)
  /// For Indonesian: Uses equran.id API tafsir endpoint
  Future<Either<ApiException, String>> getTafsir(
    int surahNumber,
    int ayahNumber, {
    String translationId = 'english',
  }) async {
    try {
      final cacheKey = '$surahNumber-$ayahNumber-$translationId';

      // Check cache first
      if (_tafsirCache.containsKey(cacheKey)) {
        return Right(_tafsirCache[cacheKey]!);
      }

      String tafsirText = '';

      // For Indonesian translation, use equran.id API
      if (translationId == 'indonesian' || translationId == 'id.indonesian') {
        tafsirText = await _getIndonesianTafsir(surahNumber, ayahNumber);
      } else {
        // For English and others, use Quran API
        tafsirText = await _getEnglishTafsir(surahNumber, ayahNumber);
      }

      if (tafsirText.isEmpty) {
        return Left(ApiException('No tafsir available for this verse'));
      }

      // Cache it
      _tafsirCache[cacheKey] = tafsirText;

      return Right(tafsirText);
    } on DioException catch (e) {
      return Left(ApiException.fromDioError(e));
    } catch (e) {
      return Left(ApiException('Failed to load tafsir: ${e.toString()}'));
    }
  }

  /// Get English tafsir from Quran API
  Future<String> _getEnglishTafsir(int surahNumber, int ayahNumber) async {
    try {
      final response = await _quranDio.get('/tafsir/${surahNumber}_$ayahNumber.json');

      final data = response.data;
      if (data == null) return '';

      // API response structure:
      // {
      //   tafsirs: [
      //     { author: "Ibn Kathir", groupVerse: "...", content: "..." }
      //   ]
      // }

      String? tafsirText;

      // Case 1: tafsirs array - get Ibn Kathir tafsir or first one
      if (data is Map && data.containsKey('tafsirs')) {
        final tafsirsList = data['tafsirs'] as List?;
        if (tafsirsList != null && tafsirsList.isNotEmpty) {
          // Try to find Ibn Kathir tafsir first
          for (final tafsir in tafsirsList) {
            if (tafsir is Map) {
              final author = tafsir['author'] as String? ?? '';
              if (author.toLowerCase().contains('ibn kathir')) {
                tafsirText = tafsir['content'] as String?;
                break;
              }
            }
          }
          // Fallback to first tafsir if Ibn Kathir not found
          tafsirText ??= (tafsirsList.first as Map?)?['content'] as String?;
        }
      }

      // Case 2: tafsir object (singular)
      if (tafsirText == null && data is Map && data.containsKey('tafsir')) {
        final tafsirData = data['tafsir'];
        if (tafsirData is Map) {
          tafsirText = tafsirData['content'] as String? ??
                       tafsirData['ibn_kathir'] as String? ??
                       tafsirData['text'] as String?;
        } else if (tafsirData is String) {
          tafsirText = tafsirData;
        }
      }

      // Case 3: direct fields
      tafsirText ??= data['content'] as String?;
      tafsirText ??= data['text'] as String?;

      return tafsirText ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Get Indonesian tafsir from equran.id API
  Future<String> _getIndonesianTafsir(int surahNumber, int ayahNumber) async {
    try {
      // Check if we already have the surah tafsir data cached
      List<dynamic>? tafsirList;

      if (_indoTafsirCache.containsKey(surahNumber)) {
        tafsirList = _indoTafsirCache[surahNumber];
      } else {
        // Fetch tafsir data for the surah
        final response = await _indoDio.get('/tafsir/$surahNumber');
        final data = response.data as Map<String, dynamic>?;
        if (data != null && data.containsKey('data')) {
          final surahData = data['data'] as Map<String, dynamic>?;
          if (surahData != null && surahData.containsKey('tafsir')) {
            tafsirList = surahData['tafsir'] as List?;
            if (tafsirList != null) {
              _indoTafsirCache[surahNumber] = tafsirList;
            }
          }
        }
      }

      if (tafsirList == null) return '';

      // Find the specific ayah's tafsir
      for (final item in tafsirList) {
        final tafsirMap = item as Map<String, dynamic>?;
        if (tafsirMap == null) continue;

        final nomorAyat = tafsirMap['ayat'] as dynamic;
        // The ayat field might be a number or a string
        final ayatNum = nomorAyat is int ? nomorAyat : int.tryParse(nomorAyat.toString());

        if (ayatNum == ayahNumber) {
          return tafsirMap['teks'] as String? ?? '';
        }
      }

      return '';
    } catch (e) {
      return '';
    }
  }

  /// Get audio URL for a specific verse from the verse data
  /// Audio is already included in verse response, but this is for explicit access
  Future<Either<ApiException, String>> getAudioUrl(
    int surahNo,
    int ayahNo, {
    int reciter = ApiConfig.defaultReciter,
  }) async {
    try {
      final response = await _quranDio.get('/audio/$surahNo/$ayahNo.json');

      final audioData = response.data as Map<String, dynamic>?;
      if (audioData == null) {
        return Left(ApiException('No audio available for this verse'));
      }

      final reciterKey = reciter.toString();
      if (audioData.containsKey(reciterKey)) {
        final reciterInfo = audioData[reciterKey] as Map<String, dynamic>?;
        final audioUrl = reciterInfo?['url'] as String?;

        if (audioUrl != null && audioUrl.isNotEmpty) {
          return Right(audioUrl);
        }
      }

      return Left(ApiException('No audio available for reciter $reciter'));
    } on DioException catch (e) {
      return Left(ApiException.fromDioError(e));
    } catch (e) {
      return Left(ApiException('Failed to load audio: ${e.toString()}'));
    }
  }
}
