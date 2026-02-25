import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:quran_jarr/core/config/api_config.dart';
import 'package:quran_jarr/core/network/api_exception.dart';
import 'package:quran_jarr/core/network/dio_client.dart';
import '../models/verse_model.dart';

/// Quran API Service
/// Handles all API calls to Quran.com API
class QuranApiService {
  final DioClient _dioClient;

  // Cache for chapter names
  final Map<int, String> _chapterCache = {};

  QuranApiService(this._dioClient);

  /// Get a random verse from Quran with translation
  Future<Either<ApiException, VerseModel>> getRandomVerse({
    String translationId = ApiConfig.defaultTranslation,
  }) async {
    try {
      // Get random verse with translation
      final response = await _dioClient.dio.get(
        ApiConfig.versesRandom,
        queryParameters: {
          'translations': translationId,
          'language': 'en',
          'fields': 'text_uthmani,chapter_id,verse_number,verse_key',
        },
      );

      final verseData = response.data['verse'] as Map<String, dynamic>?;

      if (verseData == null) {
        return Left(ApiException('No verses found'));
      }

      // Get translation from response
      String translationText = '';
      if (response.data.containsKey('translations')) {
        final translations = response.data['translations'] as List?;
        if (translations != null && translations.isNotEmpty) {
          final translation = translations[0] as Map<String, dynamic>;
          translationText = (translation['text'] as String? ?? '').trim();
        }
      }

      // Get chapter name
      final chapterId = verseData['chapter_id'] as int;
      final chapterName = await _getChapterName(chapterId);

      return Right(VerseModel(
        surahNumber: chapterId,
        ayahNumber: verseData['verse_number'] as int,
        arabicText: verseData['text_uthmani'] as String? ?? '',
        translation: translationText,
        surahName: chapterName,
        surahNameTranslation: chapterName,
        verseKey: verseData['verse_key'] as String,
      ));
    } on DioException catch (e) {
      return Left(ApiException.fromDioError(e));
    }
  }

  /// Get a verse by its key (e.g., "2:255")
  Future<Either<ApiException, VerseModel>> getVerseByKey(
    String verseKey, {
    String translationId = ApiConfig.defaultTranslation,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConfig.versesByKey}/$verseKey',
        queryParameters: {
          'translations': translationId,
          'language': 'en',
          'fields': 'text_uthmani,chapter_id,verse_number,verse_key',
        },
      );

      final verseData = response.data['verse'] as Map<String, dynamic>?;

      if (verseData == null) {
        return Left(ApiException('Verse not found'));
      }

      // Get translation
      String translationText = '';
      if (response.data.containsKey('translations')) {
        final translations = response.data['translations'] as List?;
        if (translations != null && translations.isNotEmpty) {
          final translation = translations[0] as Map<String, dynamic>;
          translationText = (translation['text'] as String? ?? '').trim();
        }
      }

      // Get chapter name
      final chapterId = verseData['chapter_id'] as int;
      final chapterName = await _getChapterName(chapterId);

      return Right(VerseModel(
        surahNumber: chapterId,
        ayahNumber: verseData['verse_number'] as int,
        arabicText: verseData['text_uthmani'] as String? ?? '',
        translation: translationText,
        surahName: chapterName,
        surahNameTranslation: chapterName,
        verseKey: verseData['verse_key'] as String,
      ));
    } on DioException catch (e) {
      return Left(ApiException.fromDioError(e));
    }
  }

  /// Get audio URL for a specific verse
  /// Uses Mishary Rashid Alafasy by default
  Future<Either<ApiException, String>> getAudioUrl(String verseKey) async {
    try {
      final response = await _dioClient.dio.get(
        '/verses/by_key/$verseKey',
        queryParameters: {
          'recitation': ApiConfig.defaultReciter,
          'fields': 'audio',
        },
      );

      final verse = response.data['verse'] as Map<String, dynamic>;
      final audio = verse['audio'] as Map<String, dynamic>?;
      final audioUrl = audio?['url'] as String?;

      if (audioUrl == null || audioUrl.isEmpty) {
        return Left(ApiException('No audio available for this verse'));
      }

      return Right(audioUrl);
    } on DioException catch (e) {
      return Left(ApiException.fromDioError(e));
    }
  }

  /// Get chapter name from cache or API
  Future<String> _getChapterName(int chapterId) async {
    // Check cache first
    if (_chapterCache.containsKey(chapterId)) {
      return _chapterCache[chapterId]!;
    }

    try {
      // Fetch chapter info from API
      final response = await _dioClient.dio.get(
        '${ApiConfig.chapters}/$chapterId',
        queryParameters: {
          'language': 'en',
        },
      );

      final chapter = response.data['chapter'] as Map<String, dynamic>?;
      final name = chapter?['name'] as String? ?? chapter?['name_simple'] as String? ?? 'Surah $chapterId';

      // Cache it
      _chapterCache[chapterId] = name;
      return name;
    } catch (e) {
      // Return fallback on error
      return 'Surah $chapterId';
    }
  }

  /// Get list of all chapters (surahs)
  Future<Either<ApiException, List<Map<String, dynamic>>>> getChapters() async {
    try {
      final response = await _dioClient.dio.get(
        ApiConfig.chapters,
        queryParameters: {
          'language': 'en',
        },
      );
      final chapters = response.data['chapters'] as List;

      return Right(chapters.cast<Map<String, dynamic>>());
    } on DioException catch (e) {
      return Left(ApiException.fromDioError(e));
    }
  }
}
