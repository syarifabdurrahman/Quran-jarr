import 'package:dartz/dartz.dart';
import 'package:quran_jarr/core/network/api_exception.dart';
import 'package:quran_jarr/features/jar/data/datasources/local_storage_service.dart';
import 'package:quran_jarr/features/jar/data/datasources/quran_api_service.dart';
import 'package:quran_jarr/features/jar/data/models/verse_model.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';
import 'package:quran_jarr/features/jar/domain/repositories/verse_repository.dart';

/// Verse Repository Implementation
/// Implements VerseRepository interface using QuranApiService and LocalStorageService
/// Following Liskov Substitution Principle - can be substituted with any VerseRepository implementation
/// Following Dependency Inversion Principle - depends on abstractions (interfaces)
class VerseRepositoryImpl implements VerseRepository {
  final QuranApiService _apiService;
  final LocalStorageService _localStorage;

  VerseRepositoryImpl({
    required QuranApiService apiService,
    required LocalStorageService localStorage,
  })  : _apiService = apiService,
        _localStorage = localStorage;

  @override
  Future<Either<ApiException, Verse>> getRandomVerse({
    String translationId = 'english', // Default translation
    List<int>? surahNumbers, // Optional list of surah numbers for curated mode
  }) async {
    final result = await _apiService.getRandomVerse(
      translationId: translationId,
      surahNumbers: surahNumbers,
    );

    if (result.isLeft()) {
      return Left(result.swap().getOrElse(() => ApiException('Unknown error')));
    }

    final model = result.getOrElse(() => VerseModel(
      surahNumber: 1,
      ayahNumber: 1,
      arabicText: '',
      translation: '',
      surahName: '',
      verseKey: '1:1',
    ));

    final verse = model.toEntity();
    // Check if verse is saved in archive
    final isSaved = await _localStorage.isVerseSaved(verse.verseKey);
    return Right(verse.copyWith(isSaved: isSaved));
  }

  @override
  Future<Either<ApiException, Verse>> getVerseByKey(
    String verseKey, {
    String translationId = 'english', // Default translation
  }) async {
    // Parse verse key (format: "surah:ayah" e.g., "2:255")
    final parts = verseKey.split(':');
    if (parts.length != 2) {
      return Left(ApiException('Invalid verse key format: $verseKey'));
    }

    try {
      final surahNo = int.parse(parts[0]);
      final ayahNo = int.parse(parts[1]);

      final result = await _apiService.getVerseBySurahAyah(
        surahNo,
        ayahNo,
        translationId: translationId,
      );

      if (result.isLeft()) {
        return Left(result.swap().getOrElse(() => ApiException('Unknown error')));
      }

      final model = result.getOrElse(() => VerseModel(
        surahNumber: 1,
        ayahNumber: 1,
        arabicText: '',
        translation: '',
        surahName: '',
        verseKey: '1:1',
      ));

      final verse = model.toEntity();
      // Check if verse is saved in archive
      final isSaved = await _localStorage.isVerseSaved(verse.verseKey);
      return Right(verse.copyWith(isSaved: isSaved));
    } catch (e) {
      return Left(ApiException('Failed to parse verse key: $e'));
    }
  }

  @override
  Future<Either<ApiException, Verse>> getDailyVerse({
    String translationId = 'english', // Default translation
    List<int>? surahNumbers, // Optional list of surah numbers for curated mode
  }) async {
    // Try to get cached today's verse first
    final cachedVerse = await _localStorage.getTodayVerse();
    if (cachedVerse != null) {
      final verse = cachedVerse.toEntity();
      // Check if verse is saved in archive
      final isSaved = await _localStorage.isVerseSaved(verse.verseKey);
      return Right(verse.copyWith(isSaved: isSaved));
    }

    // If no cached verse, get a random one (respecting curated mode)
    final result = await _apiService.getRandomVerse(
      translationId: translationId,
      surahNumbers: surahNumbers,
    );

    // Cache the verse if successful
    if (result.isRight()) {
      final model = result.getOrElse(() => VerseModel(
            surahNumber: 1,
            ayahNumber: 1,
            arabicText: '',
            translation: '',
            surahName: '',
            verseKey: '1:1',
          ));
      await _localStorage.saveTodayVerse(model);
      final verse = model.toEntity();
      // Check if verse is saved in archive
      final isSaved = await _localStorage.isVerseSaved(verse.verseKey);
      return Right(verse.copyWith(isSaved: isSaved));
    }

    return Left(result.swap().getOrElse(() => ApiException('Unknown error')));
  }

  @override
  Future<Either<ApiException, void>> saveVerse(Verse verse) async {
    try {
      final model = VerseModel.fromEntity(verse);
      await _localStorage.saveVerseToArchive(model);
      return const Right(null);
    } catch (e) {
      return Left(ApiException('Failed to save verse: $e'));
    }
  }

  @override
  Future<Either<ApiException, List<Verse>>> getSavedVerses() async {
    try {
      final models = await _localStorage.getSavedVerses();
      final verses = models.map((m) => m.toEntity()).toList();
      return Right(verses);
    } catch (e) {
      return Left(ApiException('Failed to get saved verses: $e'));
    }
  }

  @override
  Future<Either<ApiException, void>> deleteVerse(String verseKey) async {
    try {
      await _localStorage.removeVerseFromArchive(verseKey);
      return const Right(null);
    } catch (e) {
      return Left(ApiException('Failed to delete verse: $e'));
    }
  }

  @override
  Future<Either<ApiException, bool>> isVerseSaved(String verseKey) async {
    try {
      final isSaved = await _localStorage.isVerseSaved(verseKey);
      return Right(isSaved);
    } catch (e) {
      return Left(ApiException('Failed to check if verse is saved: $e'));
    }
  }

  @override
  Future<Either<ApiException, String>> getTafsir(
    int surahNumber,
    int ayahNumber, {
    String translationId = 'english',
  }) async {
    return await _apiService.getTafsir(
      surahNumber,
      ayahNumber,
      translationId: translationId,
    );
  }
}
