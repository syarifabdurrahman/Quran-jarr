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
    String translationId = '131', // Default to Sahih International
  }) async {
    final result = await _apiService.getRandomVerse(translationId: translationId);
    return result.fold(
      (error) => Left(error),
      (model) => Right(model.toEntity()),
    );
  }

  @override
  Future<Either<ApiException, Verse>> getVerseByKey(
    String verseKey, {
    String translationId = '131', // Default to Sahih International
  }) async {
    final result = await _apiService.getVerseByKey(verseKey, translationId: translationId);
    return result.fold(
      (error) => Left(error),
      (model) => Right(model.toEntity()),
    );
  }

  @override
  Future<Either<ApiException, Verse>> getDailyVerse({
    String translationId = '131', // Default to Sahih International
  }) async {
    // Try to get cached today's verse first
    final cachedVerse = await _localStorage.getTodayVerse();
    if (cachedVerse != null) {
      return Right(cachedVerse.toEntity());
    }

    // If no cached verse, get a random one
    final result = await _apiService.getRandomVerse(translationId: translationId);
    return result.fold(
      (error) => Left(error),
      (model) async {
        // Cache as today's verse
        await _localStorage.saveTodayVerse(model);
        return Right(model.toEntity());
      },
    );
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
}
