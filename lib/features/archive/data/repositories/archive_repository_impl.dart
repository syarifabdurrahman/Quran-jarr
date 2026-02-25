import 'package:dartz/dartz.dart';
import 'package:quran_jarr/core/network/api_exception.dart';
import 'package:quran_jarr/features/archive/domain/repositories/archive_repository.dart';
import 'package:quran_jarr/features/jar/data/datasources/local_storage_service.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';

/// Archive Repository Implementation
/// Implements ArchiveRepository interface using LocalStorageService
/// Following Liskov Substitution Principle - can be substituted with any ArchiveRepository implementation
class ArchiveRepositoryImpl implements ArchiveRepository {
  final LocalStorageService _localStorage;

  ArchiveRepositoryImpl(this._localStorage);

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
  Future<Either<ApiException, List<Verse>>> searchVerses(String query) async {
    try {
      final models = await _localStorage.getSavedVerses();

      // Filter by search query (arabic or translation)
      final filtered = models.where((model) {
        final arabicLower = model.arabicText.toLowerCase();
        final translationLower = model.translation.toLowerCase();
        final queryLower = query.toLowerCase();

        return arabicLower.contains(queryLower) ||
               translationLower.contains(queryLower);
      }).toList();

      final verses = filtered.map((m) => m.toEntity()).toList();
      return Right(verses);
    } catch (e) {
      return Left(ApiException('Failed to search verses: $e'));
    }
  }

  @override
  Future<Either<ApiException, void>> clearArchive() async {
    try {
      await _localStorage.clearArchive();
      return const Right(null);
    } catch (e) {
      return Left(ApiException('Failed to clear archive: $e'));
    }
  }

  @override
  Future<Either<ApiException, int>> getVerseCount() async {
    try {
      final count = _localStorage.savedVerseCount;
      return Right(count);
    } catch (e) {
      return Left(ApiException('Failed to get verse count: $e'));
    }
  }
}
