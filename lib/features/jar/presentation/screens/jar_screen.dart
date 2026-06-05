import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/config/ad_config.dart';
import 'package:quran_jarr/core/config/constants.dart';
import 'package:quran_jarr/core/providers/connectivity_provider.dart';
import 'package:quran_jarr/core/providers/preferences_provider.dart';
import 'package:quran_jarr/core/providers/streak_provider.dart';
import 'package:quran_jarr/core/services/ad_service.dart';
import 'package:quran_jarr/core/config/translations.dart';
import 'package:quran_jarr/features/rating/presentation/soft_rate_dialog.dart';
import 'package:quran_jarr/core/services/share_service.dart';
import 'package:quran_jarr/core/services/sound_effects_service.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/core/utils/timezone_helper.dart';
import 'package:quran_jarr/core/widgets/animated_background.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';
import 'package:quran_jarr/features/jar/presentation/providers/jar_provider.dart';
import 'package:quran_jarr/features/dhikr/presentation/screens/dhikr_screen.dart';
import 'package:quran_jarr/features/jar/presentation/widgets/jar_widget.dart';
import 'package:quran_jarr/features/jar/presentation/widgets/verse_card_widget.dart';
import 'package:quran_jarr/features/jar/presentation/widgets/verse_skeleton_loader.dart';
import 'package:quran_jarr/core/services/locale_service.dart';
import 'package:quran_jarr/features/ads/presentation/widgets/native_ad_widget.dart';

/// Jar Screen
/// Main screen with jar visualization and verse display
class JarScreen extends ConsumerStatefulWidget {
  const JarScreen({super.key});

  @override
  ConsumerState<JarScreen> createState() => _JarScreenState();
}

class _JarScreenState extends ConsumerState<JarScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  final GlobalKey _verseCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: AppConstants.jarAnimationDurationMs,
      ),
    );
    // Initialize sound effects service
    SoundEffectsService.instance.initialize();

    // If verse is already loaded (from notification), show it immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jarState = ref.read(jarNotifierProvider);
      if (jarState.currentVerse != null) {
        setState(() {}); // Trigger rebuild to show verse card
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _handleJarTap() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Check if user can tap the jar today
    if (!ref.read(preferencesNotifierProvider.notifier).canTapJarToday()) {
      // Show limit reached message with softer colors and an option to unlock extra tap
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.lock_clock_outlined,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Daily limit reached. Unlock one more?',
                    style: AppTextStyles.loraBodySmallForTheme(
                      context,
                    ).copyWith(color: Colors.white.withValues(alpha: 0.95)),
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'WATCH AD',
              textColor: AppColors.midnightGold,
              onPressed: () {
                AdService.instance.showRewardedAd(
                  onUserEarnedReward: () {
                    if (!mounted) return;
                    ref
                        .read(preferencesNotifierProvider.notifier)
                        .grantExtraTap();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Extra tap granted! Try tapping the jar again.',
                        ),
                      ),
                    );
                  },
                  onAdFailedToLoad: () {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sorry, no ad available right now.'),
                        ),
                      );
                    }
                  },
                );
              },
            ),
            backgroundColor: isDark
                ? AppColors.midnightSlate
                : AppColors.sageGreen.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
      return;
    }

    // Haptic feedback for normal tap
    HapticFeedback.lightImpact();
    // Play shake sound when jar is tapped
    SoundEffectsService.instance.playJarShake();
    // Pull a new verse
    await _pullVerseAnimation();
  }

  Future<void> _pullVerseAnimation() async {
    // Phase 1: Jar shake animation (smoother, longer)
    await _animationController?.forward();

    // Phase 2: Anticipation delay (1.5 seconds) - creates ritual moment
    await Future.delayed(const Duration(milliseconds: 1500));

    // Phase 3: Pull the verse (this is when the "paper slip" comes out)
    await ref.read(jarNotifierProvider.notifier).pullRandomVerse();

    // Phase 4: Breath moment - pause before showing actions
    await Future.delayed(const Duration(milliseconds: 500));

    // Play whoosh sound when verse appears
    SoundEffectsService.instance.playWhoosh();

    // Haptic feedback for verse reveal
    HapticFeedback.mediumImpact();

    // Only increment tap count if connected to internet
    final isConnected = ref.read(connectivityProvider);
    if (isConnected) {
      await ref
          .read(preferencesNotifierProvider.notifier)
          .incrementJarTapCount();

      // Record verse read for streak
      final isNewStreak = await ref
          .read(streakProvider.notifier)
          .recordVerseRead();

      // Check for milestone celebration
      if (isNewStreak && mounted) {
        final milestoneMessage = ref
            .read(streakProvider.notifier)
            .milestoneMessage;
        if (milestoneMessage != null) {
          // Show milestone celebration
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.celebration, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      milestoneMessage,
                      style: AppTextStyles.loraBodyMediumForTheme(context)
                          .copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.mutedGold,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }

      // Improved Rate Us Experience: Show soft prompt on milestones
      if (mounted) {
        final streakState = ref.read(streakProvider);
        SoftRateDialog.showIfNeeded(context, ref, streakState.currentStreak);
      }

      // Ad experience - Interstitial trigger
      if (!mounted) return;
      final streakState = ref.read(streakProvider);
      final versesReadToday = streakState.versesReadToday;
      if (versesReadToday > 0 &&
          versesReadToday % AdConfig.versesBetweenAds == 0) {
        // Show interstitial ad after a slight delay
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            AdService.instance.showInterstitialAd();
          }
        });
      }
    }

    _animationController?.reset();
  }

  Future<void> _shareVerse(Verse verse) async {
    await ShareService.instance.showShareOptions(
      context,
      verse,
      cardKey: _verseCardKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final jarState = ref.watch(jarNotifierProvider);
    final isConnected = ref.watch(connectivityProvider);
    final l10n = context.l10n;
    final dailyLimit = ref.watch(jarTapLimitProvider);
    final remainingTaps = ref.watch(remainingJarTapsProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.midnightPeriwinkle
        : AppColors.sageGreen;
    final bgColor = isDark ? null : AppColors.cream;
    final errorColor = AppColors.error;

    return Scaffold(
      backgroundColor: bgColor,
      body: AnimatedBackground(
          isDark: isDark,
          child: SafeArea(
            child: Column(
              children: [
                // Custom Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.appTitle,
                          style: AppTextStyles.loraHeadingForTheme(
                            context,
                          ).copyWith(fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _DhikrButton(primaryColor: primaryColor),
                          _TranslationButton(primaryColor: primaryColor),
                        ],
                      ),
                    ],
                  ),
                ),

                // Offline Warning Banner
                if (!isConnected)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: errorColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off, color: errorColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.noInternet,
                            style: AppTextStyles.loraBodySmallForTheme(
                              context,
                            ).copyWith(color: errorColor),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Status Bar
                _StatusBar(
                  remainingTaps: remainingTaps,
                  dailyLimit: dailyLimit,
                  primaryColor: primaryColor,
                ),

                const SizedBox(height: 20),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                        children: [
                          // Jar Area with Glow
                          SizedBox(
                            height:
                                350, // Increased height to push jar slightly up and prevent overlap
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedBuilder(
                                  animation:
                                      _animationController ??
                                      kAlwaysDismissedAnimation,
                                  child: RepaintBoundary(
                                    child: JarWidget(
                                      isEmpty: jarState.currentVerse == null,
                                      onTap: () => _handleJarTap(),
                                    ),
                                  ),
                                  builder: (context, child) {
                                    final controllerValue =
                                        _animationController?.value ?? 0.0;
                                    final floatValue = sin(
                                      controllerValue * 2 * pi,
                                    );
                                    final glowValue =
                                        (sin(controllerValue * 2 * pi) + 1) / 2;

                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Mystic Glow
                                        if (isDark)
                                          Container(
                                            width: 220,
                                            height: 220,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: primaryColor
                                                      .withValues(
                                                        alpha:
                                                            0.05 *
                                                            (1 + glowValue),
                                                      ),
                                                  blurRadius:
                                                      60 + (10 * glowValue),
                                                  spreadRadius:
                                                      20 + (5 * glowValue),
                                                ),
                                              ],
                                            ),
                                          ),

                                        // Floating Jar
                                        Transform.translate(
                                          offset: Offset(
                                            0,
                                            floatValue * 8 - 10,
                                          ), // -10 moves it slightly up
                                          child: child,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Reading Journey Card (Moved here to avoid blocking the jar)
                          _StreakDisplay(
                            primaryColor: primaryColor,
                            isDark: isDark,
                          ),

                          const SizedBox(height: 16),

                          // Countdown Timer (show when limit reached)
                          if (remainingTaps <= 0)
                            _CountdownTimer(
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),

                          // Verse Display
                          if (jarState.isLoading &&
                              jarState.currentVerse == null)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: VerseSkeletonLoader(),
                            )
                          else if (jarState.currentVerse != null)
                            VerseCardWidget(
                              verse: jarState.currentVerse!,
                              onSaveToggle: () => ref
                                  .read(jarNotifierProvider.notifier)
                                  .toggleSaveVerse(),
                              onShare: () =>
                                  _shareVerse(jarState.currentVerse!),
                            ),

                          // Error message
                          if (jarState.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: TweenAnimationBuilder<double>(
                                key: ValueKey(jarState.errorMessage),
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  final shake =
                                      sin(value * 3.14159 * 4) *
                                      8 *
                                      (1 - value);
                                  return Transform.translate(
                                    offset: Offset(shake, 0),
                                    child: child,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: errorColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: errorColor,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          jarState.errorMessage!,
                                          style:
                                              AppTextStyles.loraBodySmallForTheme(
                                                context,
                                              ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 20),
                                        onPressed: () => ref
                                            .read(jarNotifierProvider.notifier)
                                            .clearError(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 40),

                          // Native Ad - same layout as stats screen
                          const NativeAdWidget(),

                          const SizedBox(height: 40),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}

/// Translation Button
class _TranslationButton extends ConsumerWidget {
  final Color primaryColor;

  const _TranslationButton({required this.primaryColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTranslation = ref.watch(selectedTranslationProvider);
    final isIndonesian = currentTranslation.id == 'indonesian';

    return IconButton(
      onPressed: () async {
        final translation = isIndonesian
            ? AvailableTranslations.allTranslations.firstWhere(
                (t) => t.id == 'english',
              )
            : AvailableTranslations.allTranslations.firstWhere(
                (t) => t.id == 'indonesian',
              );

        await ref
            .read(preferencesNotifierProvider.notifier)
            .setTranslation(translation);

        // Reload Jar verse with new translation if verse is already fetched
        if (context.mounted) {
          await ref
              .read(jarNotifierProvider.notifier)
              .reloadVerseWithTranslation(translation.id);
        }
      },
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
        ),
        child: Text(
          isIndonesian ? 'ID' : 'EN',
          style: AppTextStyles.loraCaptionForTheme(
            context,
          ).copyWith(color: primaryColor, fontWeight: FontWeight.bold),
        ),
      ),
      tooltip: 'Toggle Language',
    );
  }
}

/// Dhikr Button
class _DhikrButton extends StatelessWidget {
  final Color primaryColor;

  const _DhikrButton({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const DhikrScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.easeOutQuart;
                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
            opaque: false,
            barrierDismissible: true,
          ),
        );
      },
      icon: Icon(
        Icons.mosque_rounded,
        color: primaryColor,
      ),
      tooltip: 'Dhikr',
    );
  }
}

/// Status Bar
class _StatusBar extends StatelessWidget {
  final int remainingTaps;
  final int dailyLimit;
  final Color primaryColor;

  const _StatusBar({
    required this.remainingTaps,
    required this.dailyLimit,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return _RemainingTapsIndicator(
      remainingTaps: remainingTaps,
      dailyLimit: dailyLimit,
      primaryColor: primaryColor,
    );
  }
}

/// Remaining Taps Indicator Widget
/// Shows how many jar taps are remaining for today
class _RemainingTapsIndicator extends StatelessWidget {
  final int remainingTaps;
  final int dailyLimit;
  final Color primaryColor;

  const _RemainingTapsIndicator({
    required this.remainingTaps,
    required this.dailyLimit,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.9,
      ),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 14,
            color: primaryColor.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '$remainingTaps of $dailyLimit taps remaining',
                style: AppTextStyles.loraBodySmallForTheme(
                  context,
                ).copyWith(color: primaryColor.withValues(alpha: 0.8)),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Streak Display Widget
/// Shows compact current streak and daily verse count
class _StreakDisplay extends ConsumerWidget {
  final Color primaryColor;
  final bool isDark;

  const _StreakDisplay({required this.primaryColor, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakState = ref.watch(streakProvider);
    final streakNotifier = ref.watch(streakProvider.notifier);
    final streak = streakState.currentStreak;
    final versesToday = streakState.versesReadToday;
    final dailyLimit = ref.watch(jarTapLimitProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.softSand,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: primaryColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            streak > 0 ? streakNotifier.streakStatus : 'No streak',
            style: AppTextStyles.loraBodySmallForTheme(context).copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.deepUmber,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 1,
            height: 14,
            color: primaryColor.withValues(alpha: 0.2),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.touch_app_outlined,
            color: primaryColor.withValues(alpha: 0.7),
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '$versesToday/$dailyLimit',
            style: AppTextStyles.loraBodySmallForTheme(context).copyWith(
              color: primaryColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Countdown Timer Widget
/// Shows time until next verse is available
class _CountdownTimer extends StatefulWidget {
  final Color primaryColor;
  final bool isDark;

  const _CountdownTimer({required this.primaryColor, required this.isDark});

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  Duration _timeUntilMidnight = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateTimeUntilMidnight();
    // Update every 30 seconds for more accuracy
    _startTimer();
  }

  void _calculateTimeUntilMidnight() {
    setState(() {
      _timeUntilMidnight = TimezoneHelper.timeUntilMidnight();
    });
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _calculateTimeUntilMidnight();
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: widget.isDark
            ? AppColors.darkElevated
            : AppColors.softSand.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_outlined,
            color: widget.primaryColor.withValues(alpha: 0.6),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Next verse in: ${TimezoneHelper.formatDuration(_timeUntilMidnight)}',
            style: AppTextStyles.loraBodySmallForTheme(
              context,
            ).copyWith(color: textColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
