import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/features/audio/presentation/providers/audio_provider.dart';

/// Audio Player Widget
/// Shows minimal glassmorphic play/pause controls and progress bar
class AudioPlayerWidget extends ConsumerStatefulWidget {
  final String audioUrl;
  final String verseKey;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    required this.verseKey,
  });

  @override
  ConsumerState<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends ConsumerState<AudioPlayerWidget> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.midnightPeriwinkle : AppColors.sageGreen;
    final accentColor = isDark ? AppColors.midnightGold : AppColors.terracotta;
    
    final audioState = ref.watch(audioPlayerNotifierProvider);
    final audioNotifier = ref.read(audioPlayerNotifierProvider.notifier);

    final isCurrentAudio = audioState.currentUrl == widget.audioUrl ||
        audioState.currentVerseKey == widget.verseKey;
    final isLoading = isCurrentAudio && audioState.isLoading;
    final isPlaying = isCurrentAudio && audioState.isPlaying;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.glassNight 
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark 
                  ? AppColors.glassNightBorder 
                  : AppColors.glassBorder.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Play/Pause with Pulse Animation
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isPlaying)
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor.withValues(alpha: 0.3),
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .scale(begin: const Offset(1, 1), end: const Offset(1.6, 1.6), duration: 1200.ms, curve: Curves.easeOut)
                        .fadeOut(duration: 1200.ms),
                      
                      GestureDetector(
                        onTap: () {
                          if (isPlaying) {
                            audioNotifier.pause();
                          } else {
                            audioNotifier.play(widget.audioUrl, verseKey: widget.verseKey);
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isPlaying ? accentColor : primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isPlaying ? accentColor : primaryColor).withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Icon(
                                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  
                  // Progress and Timer
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isCurrentAudio && audioState.duration != null) ...[
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                              activeTrackColor: accentColor,
                              inactiveTrackColor: primaryColor.withValues(alpha: 0.2),
                              thumbColor: accentColor,
                              overlayColor: accentColor.withValues(alpha: 0.2),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(audioState.position),
                                  style: AppTextStyles.loraCaptionForTheme(context).copyWith(
                                    fontSize: 10,
                                    color: primaryColor.withValues(alpha: 0.8),
                                  ),
                                ),
                                Text(
                                  _formatDuration(audioState.duration!),
                                  style: AppTextStyles.loraCaptionForTheme(context).copyWith(
                                    fontSize: 10,
                                    color: primaryColor.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                           Text(
                            'Tap to recite verse',
                            style: AppTextStyles.loraBodySmallForTheme(context).copyWith(
                              color: primaryColor.withValues(alpha: 0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Controls
                  if (isCurrentAudio) ...[
                    IconButton(
                      onPressed: audioNotifier.restart,
                      icon: Icon(Icons.replay_rounded, color: primaryColor.withValues(alpha: 0.6), size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Restart',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: audioNotifier.stop,
                      icon: Icon(Icons.stop_rounded, color: primaryColor.withValues(alpha: 0.6), size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Stop',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
