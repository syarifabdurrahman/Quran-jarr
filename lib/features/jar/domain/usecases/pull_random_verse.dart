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
  Future<Either<ApiException, Verse>> call({
    String translationId = '131', // Default to Sahih International
  }) async {
    final result = await _repository.getRandomVerse(translationId: translationId);
    return result;
  }
}
