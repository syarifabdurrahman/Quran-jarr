import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

/// Audio Player State
class AudioPlayerState {
  final String? currentUrl;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration? duration;
  final String? errorMessage;

  const AudioPlayerState({
    this.currentUrl,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration,
    this.errorMessage,
  });

  AudioPlayerState copyWith({
    String? currentUrl,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    String? errorMessage,
  }) {
    return AudioPlayerState(
      currentUrl: currentUrl ?? this.currentUrl,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      errorMessage: errorMessage,
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

  /// Play audio from URL
  Future<void> play(String url) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // If same URL, just resume
      if (state.currentUrl == url && state.isPlaying == false) {
        await _player.play();
        return;
      }

      // If different URL or first play, set new source
      if (state.currentUrl != url) {
        await _player.setUrl(url);
        state = state.copyWith(currentUrl: url);
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
