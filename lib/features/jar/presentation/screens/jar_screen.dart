import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/config/constants.dart';
import 'package:quran_jarr/core/providers/connectivity_provider.dart';
import 'package:quran_jarr/core/providers/preferences_provider.dart';
import 'package:quran_jarr/core/providers/streak_provider.dart';
import 'package:quran_jarr/core/services/notification_service.dart';
import 'package:quran_jarr/core/services/preferences_service.dart';
import 'package:quran_jarr/core/services/share_service.dart';
import 'package:quran_jarr/core/services/sound_effects_service.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/core/utils/responsive_utils.dart';
import 'package:quran_jarr/core/utils/timezone_helper.dart';
import 'package:quran_jarr/features/about/presentation/screens/about_screen.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';
import 'package:quran_jarr/features/jar/presentation/providers/jar_provider.dart';
import 'package:quran_jarr/features/jar/presentation/widgets/jar_widget.dart';
import 'package:quran_jarr/features/jar/presentation/widgets/translation_picker_widget.dart';
import 'package:quran_jarr/features/jar/presentation/widgets/verse_card_widget.dart';
import 'package:quran_jarr/features/jar/presentation/widgets/verse_skeleton_loader.dart';
import 'package:quran_jarr/core/services/locale_service.dart';
import 'package:quran_jarr/core/services/ad_service.dart';

/// Jar Screen
/// Main screen with jar visualization and verse display
class JarScreen extends ConsumerStatefulWidget {
  const JarScreen({super.key});

  @override
  ConsumerState<JarScreen> createState() => _JarScreenState();
}

class _JarScreenState extends ConsumerState<JarScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

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
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleJarTap() async {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Check if user can tap the jar today
    if (!ref.read(preferencesNotifierProvider.notifier).canTapJarToday()) {
      // Haptic feedback for limit reached
      HapticFeedback.mediumImpact();
      // Show limit reached message with softer colors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.limitReached,
                    style: AppTextStyles.loraBodySmall().copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              ],
            ),
            // Softer color for limit reached state
            backgroundColor: isDark
                ? AppColors.midnightSlate
                : AppColors.sageGreen.withValues(alpha: 0.85),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
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
    await _animationController.forward();

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
                      style: AppTextStyles.loraBodyMedium().copyWith(
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
    }

    _animationController.reset();
  }

  void _showSettingsDialog(BuildContext context) {
    // Show interstitial ad (respecting throttling/cooldown)
    AdService.instance.showInterstitialAd();

    showDialog(context: context, builder: (context) => _SettingsDialog());
  }

  Future<void> _shareVerse(Verse verse) async {
    await ShareService.instance.showShareOptions(context, verse);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final jarState = ref.watch(jarNotifierProvider);
    final isConnected = ref.watch(connectivityProvider);
    final remainingTaps = ref.watch(remainingJarTapsProvider);
    final dailyLimit = ref.watch(jarTapLimitProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.midnightPeriwinkle
        : AppColors.sageGreen;
    final bgColor = isDark ? AppColors.midnightBlue : AppColors.cream;
    final errorColor = AppColors.error;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 48,
                  maxHeight: MediaQuery.of(context).size.height * 0.15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.appTitle,
                          style: AppTextStyles.loraTitle(),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        onPressed: () {
                          showTranslationPicker(context);
                        },
                        icon: Icon(
                          Icons.translate_outlined,
                          color: primaryColor,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Offline Warning Banner
            if (!isConnected)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: errorColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off, color: errorColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.noInternet,
                            style: AppTextStyles.loraBodyMedium().copyWith(
                              color: errorColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            l10n.noInternetDesc,
                            style: AppTextStyles.loraBodySmall().copyWith(
                              color: errorColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ref.read(connectivityProvider.notifier).check();
                      },
                      icon: Icon(Icons.refresh, color: errorColor, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: l10n.retry,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Jar Widget
                    JarWidget(
                      isEmpty: jarState.currentVerse == null,
                      onTap: _handleJarTap,
                    ).animate().scale(
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    ),

                    const SizedBox(height: 20),

                    // Remaining Taps Indicator
                    _RemainingTapsIndicator(
                      remainingTaps: remainingTaps,
                      dailyLimit: dailyLimit,
                      primaryColor: primaryColor,
                    ).animate().fade(delay: 300.ms).slideY(begin: 0.2),

                    // Countdown Timer (show when limit reached)
                    if (remainingTaps <= 0 && dailyLimit < 9999)
                      _CountdownTimer(
                        primaryColor: primaryColor,
                        isDark: isDark,
                      ).animate().fade(delay: 400.ms),

                    const SizedBox(height: 20),

                    // Loading indicator
                    if (jarState.isLoading && jarState.currentVerse == null)
                      const VerseSkeletonLoader(),

                    // Verse Card with breath moment animation
                    if (jarState.currentVerse != null)
                      VerseCardWidget(
                            verse: jarState.currentVerse!,
                            onSaveToggle: () {
                              ref
                                  .read(jarNotifierProvider.notifier)
                                  .toggleSaveVerse();
                            },
                            onShare: () {
                              _shareVerse(jarState.currentVerse!);
                            },
                          )
                          .animate()
                          // Breath moment: fade in slowly
                          .fade(duration: 800.ms, curve: Curves.easeOut)
                          // Slide up smoothly
                          .slideY(
                            begin: 0.4,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          )
                          // Subtle scale effect for emphasis
                          .scale(
                            begin: const Offset(0.95, 0.95),
                            end: const Offset(1.0, 1.0),
                            duration: 600.ms,
                            curve: Curves.easeOut,
                          ),

                    // Error message
                    if (jarState.errorMessage != null)
                      Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: errorColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                jarState.errorMessage!,
                                style: AppTextStyles.loraBodySmall(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                ref
                                    .read(jarNotifierProvider.notifier)
                                    .clearError();
                              },
                            ),
                          ],
                        ),
                      ).animate().shake(),

                    // Streak Display at the bottom
                    const SizedBox(height: 16),
                    _StreakDisplay(
                      primaryColor: primaryColor,
                      isDark: isDark,
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings Dialog
/// Allows user to change verse selection mode and access other options
class _SettingsDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<_SettingsDialog> {
  /// Show dialog explaining exact alarm permission is needed
  Future<bool?> _showExactAlarmDialog(BuildContext context) async {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.midnightPeriwinkle
        : AppColors.sageGreen;
    final bgColor = isDark ? AppColors.darkCard : AppColors.cream;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.deepUmber;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getBorderRadius(context),
          ),
        ),
        title: Row(
          children: [
            Icon(
              Icons.alarm,
              color: primaryColor,
              size: ResponsiveUtils.getIconSize(context),
            ),
            SizedBox(width: ResponsiveUtils.getSpacing(context) * 0.75),
            Expanded(
              child: Text(
                'Enable Alarms & Reminders',
                style: AppTextStyles.loraHeading().copyWith(color: textColor),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For daily notifications to work reliably, you need to enable "Alarms & reminders" permission.',
              style: AppTextStyles.loraBodyMedium().copyWith(color: textColor),
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context) * 0.75),
            Text(
              'This is required on Android 12+ for exact timing of notifications.',
              style: AppTextStyles.loraBodySmall().copyWith(
                color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: TextStyle(color: primaryColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              await NotificationService.instance.openNotificationSettings();
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: Text(
              l10n.settings,
              style: TextStyle(
                color: isDark ? AppColors.darkSurface : AppColors.cream,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentMode = ref.watch(
      preferencesServiceProvider.select(
        (prefs) => prefs.getVerseSelectionMode(),
      ),
    );
    final isNotificationEnabled = ref.watch(dailyNotificationEnabledProvider);
    final notificationTime = ref.watch(notificationTimeProvider);
    final versesPerDay = ref.watch(versesPerDayProvider);
    final soundEffectsEnabled = SoundEffectsService.instance.isEnabled;
    final arabicFontSize = ref.watch(arabicFontSizeProvider);
    final englishFontSize = ref.watch(englishFontSizeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.midnightPeriwinkle
        : AppColors.sageGreen;
    final bgColor = isDark ? AppColors.darkCard : AppColors.cream;

    // Use responsive sizing
    final dialogMaxWidth = ResponsiveUtils.getDialogMaxWidth(context);
    final dialogMaxHeight = ResponsiveUtils.getDialogMaxHeight(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getBorderRadius(context),
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight * dialogMaxHeight,
          maxWidth: dialogMaxWidth,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: ResponsiveUtils.getPadding(context),
              child: Row(
                children: [
                  Text(l10n.settings, style: AppTextStyles.loraHeading()),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: primaryColor),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Jar Taps Per Day Section
                    Text(
                      l10n.jarTapsPerDay,
                      style: AppTextStyles.loraBodySmall().copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _VersesPerDaySelector(
                      versesPerDay: versesPerDay,
                      onValueChanged: (value) async {
                        await ref
                            .read(preferencesNotifierProvider.notifier)
                            .setVersesPerDay(value);
                      },
                      primaryColor: primaryColor,
                    ),

                    const SizedBox(height: 24),

                    // Sound Effects Toggle
                    _SettingsToggle(
                      icon: Icons.volume_up_outlined,
                      title: l10n.soundEffects,
                      value: soundEffectsEnabled,
                      onChanged: (value) {
                        setState(() {
                          SoundEffectsService.instance.setEnabled(value);
                        });
                      },
                      primaryColor: primaryColor,
                    ),

                    const SizedBox(height: 24),

                    // Notification Settings Section
                    Text(
                      l10n.dailyNotification,
                      style: AppTextStyles.loraBodySmall().copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Daily Notification Toggle
                    _SettingsToggle(
                      icon: Icons.notifications_outlined,
                      title: 'Daily Notification',
                      value: isNotificationEnabled,
                      onChanged: (value) async {
                        if (value) {
                          // Check exact alarm permission before enabling
                          final hasPermission = await NotificationService
                              .instance
                              .checkExactAlarmPermission();
                          if (!hasPermission && context.mounted) {
                            // Show dialog explaining permission is needed
                            final shouldProceed = await _showExactAlarmDialog(
                              context,
                            );
                            if (shouldProceed != true) {
                              // User chose not to proceed
                              return;
                            }
                          }
                        }
                        await ref
                            .read(preferencesNotifierProvider.notifier)
                            .setDailyNotificationEnabled(value);
                      },
                      primaryColor: primaryColor,
                    ),

                    // Notification Time Picker (only show when enabled)
                    if (isNotificationEnabled) ...[
                      const SizedBox(height: 8),
                      _NotificationTimePicker(
                        time: notificationTime,
                        onTimeChanged: (time) async {
                          await ref
                              .read(preferencesNotifierProvider.notifier)
                              .setNotificationTime(time);
                        },
                        primaryColor: primaryColor,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Font Size Section
                    Text(
                      l10n.fontSize,
                      style: AppTextStyles.loraBodySmall().copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FontSizeSlider(
                      icon: Icons.text_fields,
                      title: l10n.arabicText,
                      value: arabicFontSize,
                      min: 0.8,
                      max: 1.5,
                      onChanged: (value) {
                        ref
                            .read(preferencesNotifierProvider.notifier)
                            .setArabicFontSize(value);
                      },
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 8),
                    _FontSizeSlider(
                      icon: Icons.translate,
                      title: l10n.translationText,
                      value: englishFontSize,
                      min: 0.8,
                      max: 1.5,
                      onChanged: (value) {
                        ref
                            .read(preferencesNotifierProvider.notifier)
                            .setEnglishFontSize(value);
                      },
                      primaryColor: primaryColor,
                    ),

                    const SizedBox(height: 24),

                    // Verse Selection Mode Section
                    Text(
                      l10n.verseSelection,
                      style: AppTextStyles.loraBodySmall().copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ModeOption(
                      title: l10n.curatedSurahs,
                      description: l10n.curatedSurahsDesc,
                      isSelected: currentMode == VerseSelectionMode.curated,
                      onTap: () async {
                        await PreferencesService.instance.setVerseSelectionMode(
                          VerseSelectionMode.curated,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          await ref
                              .read(jarNotifierProvider.notifier)
                              .loadDailyVerse();
                        }
                      },
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 8),
                    _ModeOption(
                      title: l10n.randomVerses,
                      description: l10n.randomVersesDesc,
                      isSelected: currentMode == VerseSelectionMode.random,
                      onTap: () async {
                        await PreferencesService.instance.setVerseSelectionMode(
                          VerseSelectionMode.random,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          await ref
                              .read(jarNotifierProvider.notifier)
                              .loadDailyVerse();
                        }
                      },
                      primaryColor: primaryColor,
                    ),

                    const SizedBox(height: 24),

                    // About Section
                    _SettingsItem(
                      icon: Icons.info_outline,
                      title: l10n.aboutUs,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AboutScreen(),
                          ),
                        );
                      },
                      primaryColor: primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings Item Widget
/// Simple list item for settings that aren't mode selection
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color primaryColor;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: primaryColor),
            const SizedBox(width: 16),
            Text(title, style: AppTextStyles.loraBodyMedium()),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: primaryColor.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mode Option Widget for Settings Dialog
class _ModeOption extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;

  const _ModeOption({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? primaryColor
                : primaryColor.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: primaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.loraBodyMedium().copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(description, style: AppTextStyles.loraBodySmall()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings Toggle Widget
/// Used for toggle switches in settings
class _SettingsToggle extends ConsumerWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color primaryColor;

  const _SettingsToggle({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: AppTextStyles.loraBodyMedium(),
                maxLines: 1,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: primaryColor.withValues(alpha: 0.5),
            activeThumbColor: primaryColor,
          ),
        ],
      ),
    );
  }
}

/// Notification Time Picker Widget
/// Allows user to pick the time for daily notification
class _NotificationTimePicker extends StatelessWidget {
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final Color primaryColor;

  const _NotificationTimePicker({
    required this.time,
    required this.onTimeChanged,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) {
          onTimeChanged(picked);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              size: 18,
              color: primaryColor.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.notificationTime,
                  style: AppTextStyles.loraBodyMedium().copyWith(
                    color: primaryColor.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FittedBox(
                child: Text(
                  _formatTime(time),
                  style: AppTextStyles.loraBodySmall().copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour}:${time.minute.toString().padLeft(2, '0')} $period';
  }
}

/// Font Size Slider Widget
/// Allows user to adjust font size for Arabic and English text
class _FontSizeSlider extends ConsumerWidget {
  final IconData icon;
  final String title;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final Color primaryColor;

  const _FontSizeSlider({
    required this.icon,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Convert to percentage (80-150%)
    final percentage = (value * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: primaryColor.withValues(alpha: 0.7)),
              const SizedBox(width: 10),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: AppTextStyles.loraBodyMedium().copyWith(
                      color: primaryColor.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$percentage%',
                    style: AppTextStyles.loraBodySmall().copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: primaryColor,
              inactiveTrackColor: primaryColor.withValues(alpha: 0.3),
              thumbColor: primaryColor,
              overlayColor: primaryColor.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: ((max - min) / 0.1).round(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// Verses Per Day Selector Widget
/// Allows user to select how many jar taps allowed per day (unlimited)
class _VersesPerDaySelector extends StatelessWidget {
  final int versesPerDay;
  final ValueChanged<int> onValueChanged;
  final Color primaryColor;

  const _VersesPerDaySelector({
    required this.versesPerDay,
    required this.onValueChanged,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_list_numbered_outlined,
                size: 18,
                color: primaryColor.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.jarTapsPerDay,
                    style: AppTextStyles.loraBodyMedium().copyWith(
                      color: primaryColor.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Decrease button
              GestureDetector(
                onTap: () =>
                    onValueChanged(versesPerDay > 1 ? versesPerDay - 1 : 1),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(Icons.remove, color: primaryColor, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              // Number display
              Expanded(
                child: GestureDetector(
                  onTap: () => onValueChanged(
                    versesPerDay >= 9999 ? 1 : versesPerDay + 1,
                  ),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: FittedBox(
                      child: Text(
                        versesPerDay >= 9999 ? '∞' : versesPerDay.toString(),
                        style: AppTextStyles.loraBodyLarge().copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Increase button
              GestureDetector(
                onTap: () => onValueChanged(versesPerDay + 1),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor, width: 2),
                  ),
                  child: Icon(Icons.add, color: AppColors.cream, size: 18),
                ),
              ),
              const SizedBox(width: 6),
              // Infinity button
              GestureDetector(
                onTap: () => onValueChanged(versesPerDay >= 9999 ? 10 : 9999),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: versesPerDay >= 9999
                        ? primaryColor
                        : primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: versesPerDay >= 9999
                          ? primaryColor
                          : primaryColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.all_inclusive,
                    color: versesPerDay >= 9999
                        ? AppColors.cream
                        : primaryColor,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
    // If limit is 9999 or higher, show unlimited
    final bool isUnlimited = dailyLimit >= 9999;

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
                isUnlimited
                    ? '∞ Unlimited taps'
                    : '$remainingTaps of $dailyLimit taps remaining',
                style: AppTextStyles.loraBodySmall().copyWith(
                  color: primaryColor.withValues(alpha: 0.8),
                ),
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
/// Shows current streak, daily verse counter, and progress towards next milestone
class _StreakDisplay extends ConsumerWidget {
  final Color primaryColor;
  final bool isDark;

  const _StreakDisplay({required this.primaryColor, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakState = ref.watch(streakProvider);
    final streakNotifier = ref.watch(streakProvider.notifier);
    final streak = streakState.currentStreak;
    final nextMilestone = streakNotifier.nextMilestone;
    final progress = streakNotifier.progressToNextMilestone;
    final versesToday = streakState.versesReadToday;
    final dailyLimit = ref.watch(jarTapLimitProvider);
    final dailyProgress = dailyLimit >= 9999
        ? 0.0
        : (versesToday / dailyLimit).clamp(0.0, 1.0);
    final totalVerses = streakState.totalVersesRead;
    final motivationalMessage = streakNotifier.motivationalMessage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.softSand,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Top row: Streak and Daily Counter
          Row(
            children: [
              // Streak icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Streak info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      streakNotifier.streakStatus,
                      style: AppTextStyles.loraBodyMedium().copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Daily verse counter
                    if (dailyLimit < 9999)
                      Text(
                        '$versesToday/$dailyLimit verses today',
                        style: AppTextStyles.loraBodySmall().copyWith(
                          color: primaryColor.withValues(alpha: 0.8),
                        ),
                      )
                    else
                      Text(
                        '$versesToday verses today',
                        style: AppTextStyles.loraBodySmall().copyWith(
                          color: primaryColor.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Daily Progress Bar
          if (dailyLimit < 9999)
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: dailyProgress,
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(dailyProgress * 100).round()}%',
                  style: AppTextStyles.loraBodySmall().copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          // Streak Progress to Milestone
          if (streak > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        primaryColor.withValues(alpha: 0.6),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$streak/$nextMilestone',
                  style: AppTextStyles.loraBodySmall().copyWith(
                    color: primaryColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
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
            style: AppTextStyles.loraBodySmall().copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
