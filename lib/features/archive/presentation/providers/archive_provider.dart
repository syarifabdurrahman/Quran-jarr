import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/network/api_exception.dart';
import 'package:quran_jarr/features/archive/data/repositories/archive_repository_impl.dart';
import 'package:quran_jarr/features/archive/domain/usecases/archive_usecases.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';
import 'package:quran_jarr/features/jar/presentation/providers/jar_provider.dart' show localStorageServiceProvider, verseRepositoryProvider, jarNotifierProvider;

/// Archive State
class ArchiveState {
  final List<Verse> savedVerses;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final int verseCount;

  const ArchiveState({
    this.savedVerses = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.verseCount = 0,
  });

  ArchiveState copyWith({
    List<Verse>? savedVerses,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    int? verseCount,
  }) {
    return ArchiveState(
      savedVerses: savedVerses ?? this.savedVerses,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      verseCount: verseCount ?? this.verseCount,
    );
  }
}

/// Archive Notifier
/// Manages the state for the Archive screen using Riverpod
class ArchiveNotifier extends StateNotifier<ArchiveState> {
  final GetSavedVersesUseCase _getSavedVersesUseCase;
  final DeleteVerseUseCase _deleteVerseUseCase;
  final SearchVersesUseCase _searchVersesUseCase;
  final ClearArchiveUseCase _clearArchiveUseCase;
  final GetVerseCountUseCase _getVerseCountUseCase;
  final Ref _ref;

  ArchiveNotifier({
    required GetSavedVersesUseCase getSavedVersesUseCase,
    required DeleteVerseUseCase deleteVerseUseCase,
    required SearchVersesUseCase searchVersesUseCase,
    required ClearArchiveUseCase clearArchiveUseCase,
    required GetVerseCountUseCase getVerseCountUseCase,
    required Ref ref,
  })  : _getSavedVersesUseCase = getSavedVersesUseCase,
        _deleteVerseUseCase = deleteVerseUseCase,
        _searchVersesUseCase = searchVersesUseCase,
        _clearArchiveUseCase = clearArchiveUseCase,
        _getVerseCountUseCase = getVerseCountUseCase,
        _ref = ref,
        super(const ArchiveState()) {
    loadSavedVerses();
    loadVerseCount();
  }

  /// Load all saved verses
  Future<void> loadSavedVerses() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getSavedVersesUseCase();

    result.fold(
      (error) => state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
      ),
      (verses) => state = state.copyWith(
        savedVerses: verses,
        isLoading: false,
        verseCount: verses.length,
      ),
    );
  }

  /// Search verses by query
  Future<void> searchVerses(String query) async {
    state = state.copyWith(searchQuery: query, isLoading: true);

    final result = await _searchVersesUseCase(query);

    result.fold(
      (error) => state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
      ),
      (verses) => state = state.copyWith(
        savedVerses: verses,
        isLoading: false,
      ),
    );
  }

  /// Delete a verse from archive
  Future<void> deleteVerse(String verseKey) async {
    final result = await _deleteVerseUseCase(verseKey);

    result.fold(
      (error) => state = state.copyWith(errorMessage: error.message),
      (_) async {
        // Refresh the list
        await loadSavedVerses();
        // Invalidate jar provider so it updates isSaved status
        _ref.invalidate(jarNotifierProvider);
      },
    );
  }

  /// Clear all saved verses
  Future<void> clearArchive() async {
    state = state.copyWith(isLoading: true);

    final result = await _clearArchiveUseCase();

    result.fold(
      (error) => state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
      ),
      (_) async {
        await loadSavedVerses();
        // Invalidate jar provider so it updates isSaved status for all verses
        _ref.invalidate(jarNotifierProvider);
      },
    );
  }

  /// Load verse count
  Future<void> loadVerseCount() async {
    final result = await _getVerseCountUseCase();
    result.fold(
      (error) => state = state.copyWith(verseCount: 0),
      (count) => state = state.copyWith(verseCount: count),
    );
  }

  /// Clear any error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Reload all saved verses with a new translation
  Future<void> reloadVersesWithTranslation(String translationId) async {
    final currentVerses = state.savedVerses;
    if (currentVerses.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Get the verse repository to fetch verses with new translation
      final repository = _ref.read(verseRepositoryProvider);

      final List<Verse> updatedVerses = [];
      String? firstError;

      for (final verse in currentVerses) {
        final result = await repository.getVerseByKey(
          verse.verseKey,
          translationId: translationId,
        );

        if (result.isLeft()) {
          // Keep the original verse if fetch fails, but note the error
          updatedVerses.add(verse);
          firstError ??= result.swap().getOrElse(() => ApiException('Unknown error')).message;
          continue;
        }

        final newVerse = result.getOrElse(() => verse);

        // Fetch tafsir for the new translation
        final tafsirResult = await repository.getTafsir(
          newVerse.surahNumber,
          newVerse.ayahNumber,
          translationId: translationId,
        );

        // Merge tafsir maps - preserve existing, add new
        final existingTafsirMap = verse.tafsirByTranslation ?? {};
        final mergedTafsirMap = Map<String, String>.from(existingTafsirMap);

        if (tafsirResult.isRight()) {
          final tafsirText = tafsirResult.getOrElse(() => '');
          if (tafsirText.isNotEmpty) {
            mergedTafsirMap[translationId] = tafsirText;
          }
        }

        // Create updated verse with merged tafsir map
        updatedVerses.add(newVerse.copyWith(
          isSaved: verse.isSaved,
          savedAt: verse.savedAt,
          tafsirByTranslation: mergedTafsirMap.isNotEmpty ? mergedTafsirMap : null,
        ));
      }

      state = state.copyWith(
        savedVerses: updatedVerses,
        isLoading: false,
        errorMessage: firstError,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to reload verses: ${e.toString()}',
      );
    }
  }
}

/// Providers

// Archive Repository Provider
final archiveRepositoryProvider = Provider<ArchiveRepositoryImpl>((ref) {
  return ArchiveRepositoryImpl(
    ref.watch(localStorageServiceProvider),
  );
});

// Get Saved Verses Use Case Provider
final getSavedVersesUseCaseProvider = Provider<GetSavedVersesUseCase>((ref) {
  return GetSavedVersesUseCase(ref.watch(archiveRepositoryProvider));
});

// Delete Verse Use Case Provider
final deleteVerseUseCaseProvider = Provider<DeleteVerseUseCase>((ref) {
  return DeleteVerseUseCase(ref.watch(archiveRepositoryProvider));
});

// Search Verses Use Case Provider
final searchVersesUseCaseProvider = Provider<SearchVersesUseCase>((ref) {
  return SearchVersesUseCase(ref.watch(archiveRepositoryProvider));
});

// Clear Archive Use Case Provider
final clearArchiveUseCaseProvider = Provider<ClearArchiveUseCase>((ref) {
  return ClearArchiveUseCase(ref.watch(archiveRepositoryProvider));
});

// Get Verse Count Use Case Provider
final getVerseCountUseCaseProvider = Provider<GetVerseCountUseCase>((ref) {
  return GetVerseCountUseCase(ref.watch(archiveRepositoryProvider));
});

// Archive Notifier Provider
final archiveNotifierProvider =
    StateNotifierProvider<ArchiveNotifier, ArchiveState>((ref) {
  return ArchiveNotifier(
    getSavedVersesUseCase: ref.watch(getSavedVersesUseCaseProvider),
    deleteVerseUseCase: ref.watch(deleteVerseUseCaseProvider),
    searchVersesUseCase: ref.watch(searchVersesUseCaseProvider),
    clearArchiveUseCase: ref.watch(clearArchiveUseCaseProvider),
    getVerseCountUseCase: ref.watch(getVerseCountUseCaseProvider),
    ref: ref,
  );
});
