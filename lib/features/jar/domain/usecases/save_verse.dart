import 'package:dartz/dartz.dart';
import 'package:quran_jarr/core/network/api_exception.dart';
import '../entities/verse.dart';
import '../repositories/verse_repository.dart';

/// Save Verse Use Case
/// Following Single Responsibility Principle - handles only saving verses
class SaveVerseUseCase {
  final VerseRepository _repository;

  SaveVerseUseCase(this._repository);

  /// Execute the use case
  /// Saves a verse to archive or removes it if already saved
  Future<Either<ApiException, bool>> call(Verse verse) async {
    // Check if verse is already saved
    final checkResult = await _repository.isVerseSaved(verse.verseKey);

    return checkResult.fold(
      (error) => Left(error),
      (isSaved) async {
        if (isSaved) {
          // Remove from saved
          final result = await _repository.deleteVerse(verse.verseKey);
          return result.fold(
            (error) => Left(error),
            (_) => const Right(false), // Return false = unsaved
          );
        } else {
          // Save verse
          final result = await _repository.saveVerse(verse);
          return result.fold(
            (error) => Left(error),
            (_) => const Right(true), // Return true = saved
          );
        }
      },
    );
  }
}
