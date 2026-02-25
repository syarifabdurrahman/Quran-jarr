import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/features/audio/presentation/providers/audio_provider.dart';

/// Audio Player Widget
/// Shows play/pause controls and progress bar for verse audio
class AudioPlayerWidget extends ConsumerWidget {
  final String audioUrl;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerNotifierProvider);
    final audioNotifier = ref.read(audioPlayerNotifierProvider.notifier);

    final isCurrentAudio = audioState.currentUrl == audioUrl;
    final isLoading = isCurrentAudio && audioState.isLoading;
    final isPlaying = isCurrentAudio && audioState.isPlaying;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.sageGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.sageGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.headphones,
                color: AppColors.sageGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Verse Recitation',
                style: AppTextStyles.loraBodySmall().copyWith(
                  color: AppColors.sageGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (isCurrentAudio && audioState.errorMessage != null)
                GestureDetector(
                  onTap: audioNotifier.clearError,
                  child: Icon(
                    Icons.close,
                    color: AppColors.deepUmber.withOpacity(0.5),
                    size: 20,
                  ),
                ),
            ],
          ),

          if (isCurrentAudio && audioState.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              audioState.errorMessage!,
              style: AppTextStyles.loraBodySmall().copyWith(
                color: Colors.red.shade700,
              ),
            ),
          ],

          // Progress bar (only show when playing/paused this audio)
          if (isCurrentAudio && audioState.duration != null) ...[
            const SizedBox(height: 12),
            Column(
              children: [
                // Progress bar
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: AppColors.sageGreen,
                    inactiveTrackColor: AppColors.sageGreen.withOpacity(0.2),
                    thumbColor: AppColors.sageGreen,
                    overlayColor: AppColors.sageGreen.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: audioState.position.inMilliseconds.clamp(
                      0.0,
                      audioState.duration!.inMilliseconds.toDouble(),
                    ).toDouble(),
                    max: audioState.duration!.inMilliseconds.toDouble(),
                    onChanged: (value) {
                      audioNotifier.seek(Duration(milliseconds: value.toInt()));
                    },
                  ),
                ),
                // Time labels
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(audioState.position),
                        style: AppTextStyles.loraBodySmall().copyWith(
                          color: AppColors.deepUmber.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        _formatDuration(audioState.duration ?? Duration.zero),
                        style: AppTextStyles.loraBodySmall().copyWith(
                          color: AppColors.deepUmber.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          // Controls
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Play/Pause button
              GestureDetector(
                onTap: () {
                  if (isPlaying) {
                    audioNotifier.pause();
                  } else {
                    audioNotifier.play(audioUrl);
                  }
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.sageGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sageGreen.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                ),
              ),

              // Stop button (only show when playing this audio)
              if (isCurrentAudio) ...[
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: audioNotifier.stop,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.deepUmber.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.deepUmber.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.stop,
                      color: AppColors.deepUmber.withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
