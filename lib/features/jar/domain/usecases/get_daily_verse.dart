import 'package:dartz/dartz.dart';
import 'package:quran_jarr/core/network/api_exception.dart';
import '../entities/verse.dart';
import '../repositories/verse_repository.dart';

/// Get Daily Verse Use Case
/// Following Single Responsibility Principle - handles only verse retrieval
class GetDailyVerseUseCase {
  final VerseRepository _repository;

  GetDailyVerseUseCase(this._repository);

  /// Execute the use case
  /// Returns a verse (cached or new)
  /// Optional surahNumbers parameter for curated mode
  Future<Either<ApiException, Verse>> call({
    String translationId = 'english', // Default translation
    List<int>? surahNumbers, // Optional list of surah numbers for curated mode
  }) async {
    // Return cached verse if available, or get a new one
    return await _repository.getDailyVerse(
      translationId: translationId,
      surahNumbers: surahNumbers,
    );
  }
}
