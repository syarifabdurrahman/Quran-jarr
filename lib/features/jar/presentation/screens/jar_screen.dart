import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/config/constants.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/features/archive/presentation/screens/archive_screen.dart';
import 'package:quran_jarr/features/jar/presentation/providers/jar_provider.dart';
import 'package:quran_jarr/features/jar/presentation/widgets/jar_widget.dart';
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
