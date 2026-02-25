import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:quran_jarr/features/audio/data/datasources/audio_download_service.dart';

/// Audio Player State
class AudioPlayerState {
  final String? currentUrl;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration? duration;
  final String? errorMessage;
  final String? currentVerseKey;
  final bool isAudioDownloaded;
  final bool isDownloading;
  final double downloadProgress;

  const AudioPlayerState({
    this.currentUrl,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration,
    this.errorMessage,
    this.currentVerseKey,
    this.isAudioDownloaded = false,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
  });

  AudioPlayerState copyWith({
    String? currentUrl,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    String? errorMessage,
    String? currentVerseKey,
    bool? isAudioDownloaded,
    bool? isDownloading,
    double? downloadProgress,
  }) {
    return AudioPlayerState(
      currentUrl: currentUrl ?? this.currentUrl,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      errorMessage: errorMessage,
      currentVerseKey: currentVerseKey ?? this.currentVerseKey,
      isAudioDownloaded: isAudioDownloaded ?? this.isAudioDownloaded,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }
}

/// Audio Player Notifier
/// Manages the state for audio playback using Riverpod
class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final AudioPlayer _player;

  AudioPlayerNotifier({required AudioPlayer player})
      : _player = player,
        super(const AudioPlayerState()) {
    _initializeListeners();
  }

  /// Initialize audio player listeners
  void _initializeListeners() {
    _player.playerStateStream.listen((playerState) {
      state = state.copyWith(
        isPlaying: playerState.playing,
        isLoading: playerState.processingState == ProcessingState.loading ||
                  playerState.processingState == ProcessingState.buffering,
      );
    });

    _player.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    _player.durationStream.listen((duration) {
      state = state.copyWith(duration: duration);
    });

    _player.playbackEventStream.listen((event) {},
      onError: (Object e, StackTrace stackTrace) {
        state = state.copyWith(
          errorMessage: e.toString(),
          isPlaying: false,
        );
      },
    );
  }

  /// Initialize audio session
  Future<void> initialize() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to initialize audio: $e');
    }
  }

  /// Play audio from URL or local file
  Future<void> play(String url, {String? verseKey}) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Check for local file if verseKey is provided
      String? localPath;
      if (verseKey != null) {
        localPath = await AudioDownloadService.instance.getLocalAudioPath(verseKey);
        state = state.copyWith(
          currentVerseKey: verseKey,
          isAudioDownloaded: localPath != null,
        );
      }

      final sourceToPlay = localPath ?? url;

      // If same source, just resume
      if (state.currentUrl == sourceToPlay && state.isPlaying == false) {
        await _player.play();
        return;
      }

      // If different source or first play, set new source
      if (state.currentUrl != sourceToPlay) {
        if (localPath != null) {
          // Play from local file
          await _player.setFilePath(localPath);
        } else {
          // Play from URL
          await _player.setUrl(url);
        }
        state = state.copyWith(currentUrl: sourceToPlay);
      }

      await _player.play();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to play audio: $e',
        isLoading: false,
        isPlaying: false,
      );
    }
  }

  /// Pause audio
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to pause audio: $e');
    }
  }

  /// Stop audio
  Future<void> stop() async {
    try {
      await _player.stop();
      state = state.copyWith(
        currentUrl: null,
        isPlaying: false,
        position: Duration.zero,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to stop audio: $e');
    }
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to seek: $e');
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Download audio for offline playback
  Future<void> downloadAudio(String verseKey, String audioUrl) async {
    try {
      state = state.copyWith(
        isDownloading: true,
        downloadProgress: 0.0,
        errorMessage: null,
      );

      final path = await AudioDownloadService.instance.downloadAudio(
        verseKey,
        audioUrl,
      );

      if (path != null) {
        state = state.copyWith(
          isDownloading: false,
          isAudioDownloaded: true,
          downloadProgress: 1.0,
        );
      } else {
        state = state.copyWith(
          isDownloading: false,
          errorMessage: 'Failed to download audio',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isDownloading: false,
        errorMessage: 'Download failed: $e',
      );
    }
  }

  /// Check if audio is downloaded for a verse
  Future<bool> isAudioDownloaded(String verseKey) async {
    return await AudioDownloadService.instance.isAudioDownloaded(verseKey);
  }

  /// Delete downloaded audio for a verse
  Future<void> deleteAudio(String verseKey) async {
    await AudioDownloadService.instance.deleteAudio(verseKey);
    state = state.copyWith(isAudioDownloaded: false);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

/// Providers

// Audio Player Provider
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  return AudioPlayer();
});

// Audio Player Notifier Provider
final audioPlayerNotifierProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  final player = ref.watch(audioPlayerProvider);
  final notifier = AudioPlayerNotifier(player: player);

  // Initialize on creation
  notifier.initialize();

  // Dispose when provider is disposed
  ref.onDispose(() {
    notifier.dispose();
  });

  return notifier;
});
