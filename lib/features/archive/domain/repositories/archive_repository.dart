import 'package:dartz/dartz.dart';
import 'package:quran_jarr/core/network/api_exception.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';

/// Archive Repository Interface
/// Following Interface Segregation Principle - focused, single-purpose interface
abstract class ArchiveRepository {
  /// Get all saved verses from archive
  /// Returns Right(List<Verse>) on success, Left(ApiException) on failure
  Future<Either<ApiException, List<Verse>>> getSavedVerses();

  /// Delete a verse from archive
  /// Returns Right(void) on success, Left(ApiException) on failure
  Future<Either<ApiException, void>> deleteVerse(String verseKey);

  /// Search saved verses by text (Arabic or translation)
  /// Returns Right(List<Verse>) on success, Left(ApiException) on failure
  Future<Either<ApiException, List<Verse>>> searchVerses(String query);

  /// Clear all saved verses
  /// Returns Right(void) on success, Left(ApiException) on failure
  Future<Either<ApiException, void>> clearArchive();

  /// Get the count of saved verses
  /// Returns Right(int) on success, Left(ApiException) on failure
  Future<Either<ApiException, int>> getVerseCount();
}
