import 'package:dartz/dartz.dart';
import 'package:quran_jarr/core/network/api_exception.dart';
import '../entities/verse.dart';
import '../repositories/verse_repository.dart';

/// Pull Random Verse Use Case
/// Following Single Responsibility Principle - handles only random verse pulling
class PullRandomVerseUseCase {
  final VerseRepository _repository;

  PullRandomVerseUseCase(this._repository);

  /// Execute the use case
  /// Pulls a random verse
  /// Optional surahNumbers parameter for curated mode
  Future<Either<ApiException, Verse>> call({
    String translationId = 'english', // Default translation
    List<int>? surahNumbers, // Optional list of surah numbers for curated mode
  }) async {
    final result = await _repository.getRandomVerse(
      translationId: translationId,
      surahNumbers: surahNumbers,
    );
    return result;
  }
}
