import 'package:dartz/dartz.dart';
import 'package:quran_jarr/core/network/api_exception.dart';
import '../entities/verse.dart';

/// Verse Repository Interface
/// Following Dependency Inversion Principle - depends on abstraction
/// Following Interface Segregation Principle - focused, single-purpose interface
abstract class VerseRepository {
  /// Get a random verse from Quran
  /// Returns Right(Verse) on success, Left(ApiException) on failure
  /// Optional surahNumbers parameter for curated mode
  Future<Either<ApiException, Verse>> getRandomVerse({
    String translationId,
    List<int>? surahNumbers,
  });

  /// Get a verse by its key (e.g., "2:255")
  /// Returns Right(Verse) on success, Left(ApiException) on failure
  Future<Either<ApiException, Verse>> getVerseByKey(String verseKey, {String translationId});

  /// Get today's verse (cached or new if 24h passed)
  /// Returns Right(Verse) on success, Left(ApiException) on failure
  /// Optional surahNumbers parameter for curated mode
  Future<Either<ApiException, Verse>> getDailyVerse({
    String translationId,
    List<int>? surahNumbers,
  });

  /// Save a verse to archive
  /// Returns Right(void) on success, Left(ApiException) on failure
  Future<Either<ApiException, void>> saveVerse(Verse verse);

  /// Get all saved verses from archive
  /// Returns Right(List<Verse>) on success, Left(ApiException) on failure
  Future<Either<ApiException, List<Verse>>> getSavedVerses();

  /// Delete a verse from archive
  /// Returns Right(void) on success, Left(ApiException) on failure
  Future<Either<ApiException, void>> deleteVerse(String verseKey);

  /// Check if a verse is saved
  /// Returns Right(bool) on success, Left(ApiException) on failure
  Future<Either<ApiException, bool>> isVerseSaved(String verseKey);

  /// Get tafsir for a specific verse
  /// Returns Right(String) with tafsir text on success, Left(ApiException) on failure
  Future<Either<ApiException, String>> getTafsir(int surahNumber, int ayahNumber, {String translationId});
}
