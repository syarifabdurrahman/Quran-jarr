import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/config/constants.dart';
import 'package:quran_jarr/core/providers/connectivity_provider.dart';
import 'package:quran_jarr/core/providers/preferences_provider.dart';
import 'package:quran_jarr/core/services/preferences_service.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/features/about/presentation/screens/about_screen.dart';
import 'package:quran_jarr/features/archive/presentation/screens/archive_screen.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';
import 'package:quran_jarr/features/jar/presentation/providers/jar_provider.dart';
import 'package:quran_jarr/features/jar/presentation/widgets/jar_widget.dart';
import 'package:quran_jarr/features/jar/presentation/widgets/translation_picker_widget.dart';
import 'package:quran_jarr/features/jar/presentation/widgets/verse_card_widget.dart';

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
  bool _showVerse = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConstants.jarAnimationDurationMs),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleJarTap() async {
    // Pull a new verse anytime - no restrictions
    await _pullVerseAnimation();
  }

  Future<void> _pullVerseAnimation() async {
    setState(() => _showVerse = false);
    await _animationController.forward();
    await ref.read(jarNotifierProvider.notifier).pullRandomVerse();
    setState(() => _showVerse = true);
    _animationController.reset();
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SettingsDialog(),
    );
  }

  void _shareVerse(Verse verse) {
    final shareText = '''
${verse.arabicText}

"${verse.translation}"

${verse.surahName} (${verse.surahReference})

— Shared via Quran Jarr''';

    Clipboard.setData(ClipboardData(text: shareText.trim()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Verse copied to clipboard!',
          style: AppTextStyles.loraBodySmall().copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.sageGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jarState = ref.watch(jarNotifierProvider);
    final isConnected = ref.watch(connectivityProvider);
    final primaryColor = AppColors.sageGreen;
    final bgColor = AppColors.cream;
    final errorColor = AppColors.error;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quran Jarr',
                    style: AppTextStyles.loraTitle(),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await ref.read(jarNotifierProvider.notifier).pullRandomVerse();
                        },
                        icon: Icon(
                          Icons.refresh_outlined,
                          color: primaryColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showTranslationPicker(context);
                        },
                        icon: Icon(
                          Icons.translate_outlined,
                          color: primaryColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ArchiveScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.bookmark_outline_outlined,
                          color: primaryColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _showSettingsDialog(context);
                        },
                        icon: Icon(
                          Icons.settings_outlined,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
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
                    Icon(
                      Icons.wifi_off,
                      color: errorColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No Internet Connection',
                            style: AppTextStyles.loraBodyMedium().copyWith(
                              color: errorColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Some features may not work offline',
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
                      icon: Icon(
                        Icons.refresh,
                        color: errorColor,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Retry',
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

            // Main Content
            Expanded(
              child: RefreshIndicator(
                color: primaryColor,
                backgroundColor: bgColor,
                onRefresh: () async {
                  await ref.read(jarNotifierProvider.notifier).pullRandomVerse();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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

                      const SizedBox(height: 30),

                      // Loading indicator
                      if (jarState.isLoading)
                        CircularProgressIndicator(
                          color: primaryColor,
                        ),

                      // Verse Card
                      if (_showVerse && jarState.currentVerse != null)
                        VerseCardWidget(
                          verse: jarState.currentVerse!,
                          onSaveToggle: () {
                            ref.read(jarNotifierProvider.notifier).toggleSaveVerse();
                          },
                          onShare: () {
                            _shareVerse(jarState.currentVerse!);
                          },
                        ).animate().fade(duration: 400.ms).slideY(
                          begin: 0.3,
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
                              Icon(
                                Icons.error_outline,
                                color: errorColor,
                              ),
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
                                  ref.read(jarNotifierProvider.notifier).clearError();
                                },
                              ),
                            ],
                          ),
                        ).animate().shake(),
                    ],
                  ),
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
  @override
  Widget build(BuildContext context) {
    final currentMode = ref.watch(
      preferencesServiceProvider.select((prefs) => prefs.getVerseSelectionMode()),
    );
    final isNotificationEnabled = ref.watch(dailyNotificationEnabledProvider);
    final notificationTime = ref.watch(notificationTimeProvider);
    final arabicFontSize = ref.watch(arabicFontSizeProvider);
    final englishFontSize = ref.watch(englishFontSizeProvider);
    final primaryColor = AppColors.sageGreen;
    final bgColor = AppColors.cream;

    // Get screen height for responsive sizing
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogMaxHeight = screenHeight * 0.75;

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: dialogMaxHeight,
          maxWidth: 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Settings',
                    style: AppTextStyles.loraHeading(),
                  ),
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
                    // Daily Notification Toggle
                    _SettingsToggle(
                      icon: Icons.notifications_outlined,
                      title: 'Daily Notification',
                      value: isNotificationEnabled,
                      onChanged: (value) async {
                        await ref.read(preferencesNotifierProvider.notifier).setDailyNotificationEnabled(value);
                      },
                      primaryColor: primaryColor,
                    ),

                    // Notification Time Picker (only show when enabled)
                    if (isNotificationEnabled) ...[
                      const SizedBox(height: 8),
                      _NotificationTimePicker(
                        time: notificationTime,
                        onTimeChanged: (time) async {
                          await ref.read(preferencesNotifierProvider.notifier).setNotificationTime(time);
                        },
                        primaryColor: primaryColor,
                      ),
                      // Test Notification Button
                      const SizedBox(height: 8),
                      _SettingsItem(
                        icon: Icons.notifications_active,
                        title: 'Test Notification',
                        onTap: () async {
                          await ref.read(preferencesNotifierProvider.notifier).scheduleTestNotification();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Test notification sent!'),
                                backgroundColor: primaryColor,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        primaryColor: primaryColor,
                      ),
                    ],

                    const SizedBox(height: 24),

            // Font Size Section
            Text(
              'Font Size',
              style: AppTextStyles.loraBodySmall().copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _FontSizeSlider(
              icon: Icons.text_fields,
              title: 'Arabic Text',
              value: arabicFontSize,
              min: 0.8,
              max: 1.5,
              onChanged: (value) {
                ref.read(preferencesNotifierProvider.notifier).setArabicFontSize(value);
              },
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 8),
            _FontSizeSlider(
              icon: Icons.translate,
              title: 'Translation Text',
              value: englishFontSize,
              min: 0.8,
              max: 1.5,
              onChanged: (value) {
                ref.read(preferencesNotifierProvider.notifier).setEnglishFontSize(value);
              },
              primaryColor: primaryColor,
            ),

            const SizedBox(height: 24),

            // Verse Selection Mode Section
            Text(
              'Verse Selection Mode',
              style: AppTextStyles.loraBodySmall().copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _ModeOption(
              title: 'Curated Surahs',
              description: 'Selected surahs for hope, comfort & gratitude',
              isSelected: currentMode == VerseSelectionMode.curated,
              onTap: () async {
                await PreferencesService.instance
                    .setVerseSelectionMode(VerseSelectionMode.curated);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  await ref.read(jarNotifierProvider.notifier).loadDailyVerse();
                }
              },
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 8),
            _ModeOption(
              title: 'Random Verses',
              description: 'Completely random from all 114 surahs',
              isSelected: currentMode == VerseSelectionMode.random,
              onTap: () async {
                await PreferencesService.instance
                    .setVerseSelectionMode(VerseSelectionMode.random);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  await ref.read(jarNotifierProvider.notifier).loadDailyVerse();
                }
              },
              primaryColor: primaryColor,
            ),

            const SizedBox(height: 24),

            // About Section
            _SettingsItem(
              icon: Icons.info_outline,
              title: 'About Us',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
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
            Icon(
              icon,
              size: 20,
              color: primaryColor,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTextStyles.loraBodyMedium(),
            ),
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
                  Text(
                    description,
                    style: AppTextStyles.loraBodySmall(),
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: primaryColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.loraBodyMedium(),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              size: 20,
              color: primaryColor.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Notification Time',
                style: AppTextStyles.loraBodyMedium().copyWith(
                  color: primaryColor.withValues(alpha: 0.8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: primaryColor.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.loraBodyMedium().copyWith(
                    color: primaryColor.withValues(alpha: 0.8),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$percentage%',
                  style: AppTextStyles.loraBodySmall().copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
