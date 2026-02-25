import 'package:dartz/dartz.dart';
import 'package:quran_jarr/core/network/api_exception.dart';
import 'package:quran_jarr/features/archive/domain/repositories/archive_repository.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';

/// Get Saved Verses Use Case
/// Following Single Responsibility Principle - handles only fetching saved verses
class GetSavedVersesUseCase {
  final ArchiveRepository _repository;

  GetSavedVersesUseCase(this._repository);

  /// Execute the use case
  Future<Either<ApiException, List<Verse>>> call() async {
    return await _repository.getSavedVerses();
  }
}

/// Delete Verse Use Case
/// Following Single Responsibility Principle - handles only deleting verses
class DeleteVerseUseCase {
  final ArchiveRepository _repository;

  DeleteVerseUseCase(this._repository);

  /// Execute the use case
  Future<Either<ApiException, void>> call(String verseKey) async {
    return await _repository.deleteVerse(verseKey);
  }
}

/// Search Verses Use Case
/// Following Single Responsibility Principle - handles only searching verses
class SearchVersesUseCase {
  final ArchiveRepository _repository;

  SearchVersesUseCase(this._repository);

  /// Execute the use case
  Future<Either<ApiException, List<Verse>>> call(String query) async {
    if (query.trim().isEmpty) {
      return await _repository.getSavedVerses();
    }
    return await _repository.searchVerses(query);
  }
}

/// Clear Archive Use Case
/// Following Single Responsibility Principle - handles only clearing archive
class ClearArchiveUseCase {
  final ArchiveRepository _repository;

  ClearArchiveUseCase(this._repository);

  /// Execute the use case
  Future<Either<ApiException, void>> call() async {
    return await _repository.clearArchive();
  }
}

/// Get Verse Count Use Case
/// Following Single Responsibility Principle - handles only getting verse count
class GetVerseCountUseCase {
  final ArchiveRepository _repository;

  GetVerseCountUseCase(this._repository);

  /// Execute the use case
  Future<Either<ApiException, int>> call() async {
    return await _repository.getVerseCount();
  }
}
