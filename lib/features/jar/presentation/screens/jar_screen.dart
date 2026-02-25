import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/config/constants.dart';
import 'package:quran_jarr/core/providers/preferences_provider.dart';
import 'package:quran_jarr/core/services/preferences_service.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/features/about/presentation/screens/about_screen.dart';
import 'package:quran_jarr/features/archive/presentation/screens/archive_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final jarState = ref.watch(jarNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
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
                    style: AppTextStyles.loraTitle,
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await ref.read(jarNotifierProvider.notifier).loadDailyVerse();
                        },
                        icon: const Icon(
                          Icons.refresh_outlined,
                          color: AppColors.sageGreen,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showTranslationPicker(context);
                        },
                        icon: const Icon(
                          Icons.translate_outlined,
                          color: AppColors.sageGreen,
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
                        icon: const Icon(
                          Icons.bookmark_outline_outlined,
                          color: AppColors.sageGreen,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _showSettingsDialog(context);
                        },
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: AppColors.sageGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
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
                      const CircularProgressIndicator(
                        color: AppColors.sageGreen,
                      ),

                    // Verse Card
                    if (_showVerse && jarState.currentVerse != null)
                      VerseCardWidget(
                        verse: jarState.currentVerse!,
                        onSaveToggle: () {
                          ref.read(jarNotifierProvider.notifier).toggleSaveVerse();
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
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                jarState.errorMessage!,
                                style: AppTextStyles.loraBodySmall,
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
          ],
        ),
      ),
    );
  }
}

/// Settings Dialog
/// Allows user to change verse selection mode and access other options
class _SettingsDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(
      preferencesServiceProvider.select((prefs) => prefs.getVerseSelectionMode()),
    );

    return AlertDialog(
      backgroundColor: AppColors.cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Settings',
        style: AppTextStyles.loraHeading,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verse Selection Mode Section
            Text(
              'Verse Selection Mode',
              style: AppTextStyles.loraBodySmall.copyWith(
                color: AppColors.sageGreen,
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
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Close',
            style: AppTextStyles.loraBodyMedium.copyWith(
              color: AppColors.sageGreen,
            ),
          ),
        ),
      ],
    );
  }
}

/// Settings Item Widget
/// Simple list item for settings that aren't mode selection
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
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
              color: AppColors.sageGreen,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTextStyles.loraBodyMedium,
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.sageGreen.withValues(alpha: 0.5),
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

  const _ModeOption({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
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
              ? AppColors.sageGreen.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppColors.sageGreen
                : AppColors.sageGreen.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: AppColors.sageGreen,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.loraBodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTextStyles.loraBodySmall,
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
