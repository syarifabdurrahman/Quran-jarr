import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/network/dio_client.dart';
import 'package:quran_jarr/features/jar/data/datasources/local_storage_service.dart';
import 'package:quran_jarr/features/jar/data/datasources/quran_api_service.dart';
import 'package:quran_jarr/features/jar/data/repositories/verse_repository_impl.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';
import 'package:quran_jarr/features/jar/domain/usecases/get_daily_verse.dart';
import 'package:quran_jarr/features/jar/domain/usecases/pull_random_verse.dart';
import 'package:quran_jarr/features/jar/domain/usecases/save_verse.dart';

/// Jar State
class JarState {
  final Verse? currentVerse;
  final bool isLoading;
  final String? errorMessage;

  const JarState({
    this.currentVerse,
    this.isLoading = false,
    this.errorMessage,
  });

  JarState copyWith({
    Verse? currentVerse,
    bool? isLoading,
    String? errorMessage,
  }) {
    return JarState(
      currentVerse: currentVerse ?? this.currentVerse,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Jar Notifier
/// Manages the state for the Jar screen using Riverpod
class JarNotifier extends StateNotifier<JarState> {
  final GetDailyVerseUseCase _getDailyVerseUseCase;
  final PullRandomVerseUseCase _pullRandomVerseUseCase;
  final SaveVerseUseCase _saveVerseUseCase;

  JarNotifier({
    required GetDailyVerseUseCase getDailyVerseUseCase,
    required PullRandomVerseUseCase pullRandomVerseUseCase,
    required SaveVerseUseCase saveVerseUseCase,
  })  : _getDailyVerseUseCase = getDailyVerseUseCase,
        _pullRandomVerseUseCase = pullRandomVerseUseCase,
        _saveVerseUseCase = saveVerseUseCase,
        super(const JarState()) {
    _initialize();
  }

  /// Initialize the jar state
  Future<void> _initialize() async {
    await loadDailyVerse();
  }

  /// Load a verse (cached or random)
  Future<void> loadDailyVerse() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getDailyVerseUseCase();

    result.fold(
      (error) => state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
      ),
      (verse) => state = state.copyWith(
        currentVerse: verse,
        isLoading: false,
      ),
    );
  }

  /// Pull a random verse (available anytime)
  Future<void> pullRandomVerse() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _pullRandomVerseUseCase();

    result.fold(
      (error) => state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
      ),
      (verse) => state = state.copyWith(
        currentVerse: verse,
        isLoading: false,
      ),
    );
  }

  /// Save or unsave the current verse
  Future<void> toggleSaveVerse() async {
    final verse = state.currentVerse;
    if (verse == null) return;

    state = state.copyWith(
      currentVerse: verse.copyWith(isSaved: !verse.isSaved),
    );

    final result = await _saveVerseUseCase(verse);

    result.fold(
      (error) => state = state.copyWith(
        errorMessage: error.message,
        currentVerse: verse, // Revert on error
      ),
      (isSaved) => state = state.copyWith(
        currentVerse: state.currentVerse?.copyWith(isSaved: isSaved),
      ),
    );
  }

  /// Clear any error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Providers

// Local Storage Service Provider
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService.instance;
});

// Dio Client Provider
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient.instance..initialize();
});

// Quran API Service Provider
final quranApiServiceProvider = Provider<QuranApiService>((ref) {
  return QuranApiService(ref.watch(dioClientProvider));
});

// Verse Repository Provider
final verseRepositoryProvider = Provider<VerseRepositoryImpl>((ref) {
  return VerseRepositoryImpl(
    apiService: ref.watch(quranApiServiceProvider),
    localStorage: ref.watch(localStorageServiceProvider),
  );
});

// Get Daily Verse Use Case Provider
final getDailyVerseUseCaseProvider = Provider<GetDailyVerseUseCase>((ref) {
  return GetDailyVerseUseCase(ref.watch(verseRepositoryProvider));
});

// Pull Random Verse Use Case Provider
final pullRandomVerseUseCaseProvider = Provider<PullRandomVerseUseCase>((ref) {
  return PullRandomVerseUseCase(ref.watch(verseRepositoryProvider));
});

// Save Verse Use Case Provider
final saveVerseUseCaseProvider = Provider<SaveVerseUseCase>((ref) {
  return SaveVerseUseCase(ref.watch(verseRepositoryProvider));
});

// Jar Notifier Provider
final jarNotifierProvider = StateNotifierProvider<JarNotifier, JarState>((ref) {
  return JarNotifier(
    getDailyVerseUseCase: ref.watch(getDailyVerseUseCaseProvider),
    pullRandomVerseUseCase: ref.watch(pullRandomVerseUseCaseProvider),
    saveVerseUseCase: ref.watch(saveVerseUseCaseProvider),
  );
});
