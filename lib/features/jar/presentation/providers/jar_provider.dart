import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/config/constants.dart';
import 'package:quran_jarr/core/data/curated_surahs.dart';
import 'package:quran_jarr/core/network/dio_client.dart';
import 'package:quran_jarr/core/providers/preferences_provider.dart';
import 'package:quran_jarr/core/services/connectivity_service.dart';
import 'package:quran_jarr/core/services/notification_service.dart';
import 'package:quran_jarr/core/services/widget_service.dart';
import 'package:quran_jarr/features/audio/data/datasources/audio_download_service.dart';
import 'package:quran_jarr/features/jar/data/datasources/local_storage_service.dart';
import 'package:quran_jarr/features/jar/data/datasources/quran_api_service.dart';
import 'package:quran_jarr/features/jar/data/models/verse_model.dart';
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
  final Ref _ref;

  StreamSubscription<String>? _notificationTapSubscription;

  JarNotifier({
    required GetDailyVerseUseCase getDailyVerseUseCase,
    required PullRandomVerseUseCase pullRandomVerseUseCase,
    required SaveVerseUseCase saveVerseUseCase,
    required Ref ref,
  })  : _getDailyVerseUseCase = getDailyVerseUseCase,
        _pullRandomVerseUseCase = pullRandomVerseUseCase,
        _saveVerseUseCase = saveVerseUseCase,
        _ref = ref,
        super(const JarState()) {
    // Set up listener FIRST, then initialize
    _listenToNotifications();
    _initialize();
  }

  /// Initialize the jar state
  Future<void> _initialize() async {
    // Check if there's a pending verse key from notification tap
    // This handles the case when app is launched from terminated state via notification
    final pendingVerseKey = await NotificationService.instance.getPendingVerseKey();

    if (pendingVerseKey != null) {
      await loadVerseByKey(pendingVerseKey);
    } else {
      await loadDailyVerse();
    }
  }

  /// Listen for notification taps
  void _listenToNotifications() {
    _notificationTapSubscription = NotificationService.instance.notificationTapStream.listen((verseKey) {
      loadVerseByKey(verseKey);
    });
  }

  /// Load a verse (cached or random)
  Future<void> loadDailyVerse() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Get selected translation ID
    final translationId = _ref.read(selectedTranslationProvider).id;

    // Get curated surah numbers if in curated mode
    final prefs = _ref.read(preferencesServiceProvider);
    final mode = prefs.getVerseSelectionMode();
    final surahNumbers = mode == VerseSelectionMode.curated
        ? CuratedSurahs.surahNumbers
        : null;

    final result = await _getDailyVerseUseCase(
      translationId: translationId,
      surahNumbers: surahNumbers,
    );

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

    // Get selected translation ID
    final translationId = _ref.read(selectedTranslationProvider).id;

    // Get curated surah numbers if in curated mode
    final prefs = _ref.read(preferencesServiceProvider);
    final mode = prefs.getVerseSelectionMode();
    final surahNumbers = mode == VerseSelectionMode.curated
        ? CuratedSurahs.surahNumbers
        : null;

    final result = await _pullRandomVerseUseCase(
      translationId: translationId,
      surahNumbers: surahNumbers,
    );

    result.fold(
      (error) async {
        // Check connectivity on API failure
        await ConnectivityService.instance.verifyConnection();
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        );
      },
      (verse) async {
        state = state.copyWith(
          currentVerse: verse,
          isLoading: false,
        );

        // Update home screen widget (Android only)
        if (WidgetService.instance.isAvailable) {
          await WidgetService.instance.updateWidget(
            arabicText: verse.arabicText,
            translation: verse.translation,
            surahName: verse.surahName,
            surahNumber: verse.surahNumber,
            ayahNumber: verse.ayahNumber,
          );
        }
      },
    );
  }

  /// Save or unsave the current verse
  Future<void> toggleSaveVerse() async {
    final verse = state.currentVerse;
    if (verse == null) return;

    final isSaving = !verse.isSaved;
    state = state.copyWith(
      currentVerse: verse.copyWith(isSaved: isSaving),
    );

    // If saving, fetch tafsir if not already loaded
    Verse verseToSave = verse;
    if (isSaving && (verse.tafsir == null || verse.tafsir!.isEmpty)) {
      final translationId = _ref.read(selectedTranslationProvider).id;
      final tafsirResult = await _ref.read(verseRepositoryProvider).getTafsir(
            verse.surahNumber,
            verse.ayahNumber,
            translationId: translationId,
          );

      tafsirResult.fold(
        (error) {
          // Continue saving even if tafsir fails
        },
        (tafsirText) {
          verseToSave = verse.copyWith(tafsir: tafsirText);
          state = state.copyWith(currentVerse: verseToSave);
        },
      );
    }

    final result = await _saveVerseUseCase(verseToSave);

    result.fold(
      (error) => state = state.copyWith(
        errorMessage: error.message,
        currentVerse: verse, // Revert on error
      ),
      (isSaved) async {
        state = state.copyWith(
          currentVerse: state.currentVerse?.copyWith(isSaved: isSaved),
        );

        // Download audio if verse is saved and has audio
        if (isSaved && verseToSave.hasAudio) {
          AudioDownloadService.instance.downloadAudio(
            verseToSave.verseKey,
            verseToSave.audioUrl!,
          );
        }
      },
    );
  }

  /// Clear any error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Load tafsir for the current verse
  Future<void> loadTafsir() async {
    final verse = state.currentVerse;
    if (verse == null) return;

    // If tafsir is already loaded, do nothing
    if (verse.tafsir != null && verse.tafsir!.isNotEmpty) return;

    final translationId = _ref.read(selectedTranslationProvider).id;
    final result = await _ref.read(verseRepositoryProvider).getTafsir(
          verse.surahNumber,
          verse.ayahNumber,
          translationId: translationId,
        );

    result.fold(
      (error) => state = state.copyWith(
        errorMessage: error.message,
      ),
      (tafsirText) => state = state.copyWith(
        currentVerse: verse.copyWith(tafsir: tafsirText),
      ),
    );
  }

  /// Reload the current verse with a different translation
  Future<void> reloadVerseWithTranslation(String translationId) async {
    final verse = state.currentVerse;
    if (verse == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    // Fetch the same verse with new translation
    final result = await _ref.read(verseRepositoryProvider).getVerseByKey(
          verse.verseKey,
          translationId: translationId,
        );

    result.fold(
      (error) => state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
      ),
      (newVerse) => state = state.copyWith(
        currentVerse: newVerse.copyWith(
          isSaved: verse.isSaved,
          tafsir: null, // Clear tafsir when translation changes - it will be re-fetched in the correct language
        ),
        isLoading: false,
      ),
    );
  }

  /// Load a specific verse by its key (e.g., "2:255")
  /// Used when user taps on a notification
  Future<void> loadVerseByKey(String verseKey) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // First, try to get the saved notification verse from local storage
    final notificationVerse = await NotificationService.instance.getNotificationVerse();

    // If notification verse exists and matches the requested key, use it
    // Otherwise, always fetch fresh from API to ensure users get the latest verse
    if (notificationVerse == null || notificationVerse.verseKey != verseKey) {
      // Fetch from API
      final translationId = _ref.read(selectedTranslationProvider).id;
      final result = await _ref.read(verseRepositoryProvider).getVerseByKey(
            verseKey,
            translationId: translationId,
          );

      result.fold(
        (error) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: error.message,
          );
        },
        (verse) async {
          // Save the newly fetched verse as the notification verse
          await LocalStorageService.instance.saveNotificationVerse(
            VerseModel.fromEntity(verse),
          );
          state = state.copyWith(
            currentVerse: verse,
            isLoading: false,
          );
        },
      );
      return;
    }

    // Use cached verse from today
    state = state.copyWith(
      currentVerse: notificationVerse.toEntity(),
      isLoading: false,
    );
  }

  @override
  void dispose() {
    _notificationTapSubscription?.cancel();
    super.dispose();
  }
}

/// Providers

// Local Storage Service Provider
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService.instance;
});

// Dio Client Provider (no longer needed but kept for potential future use)
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient.instance..initialize();
});

// Quran API Service Provider
final quranApiServiceProvider = Provider<QuranApiService>((ref) {
  return QuranApiService();
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
    ref: ref,
  );
});
