import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quran_jarr/core/config/constants.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/core/services/preferences_service.dart';
import 'package:quran_jarr/features/jar/presentation/screens/jar_screen.dart';

/// Onboarding Screen
/// First screen: Internet requirement check
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await PreferencesService.instance.setOnboardingCompleted(true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const JarScreen()),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (only show on second page)
            if (_currentPage == 1)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: AppTextStyles.loraBodySmall().copyWith(
                        color: AppColors.sageGreen,
                      ),
                    ),
                  ),
                ),
              ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _InternetCheckPage(onNext: _nextPage),
                  _ModeSelectionPage(onComplete: _completeOnboarding),
                ],
              ),
            ),

            // Page Indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  2,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.sageGreen
                          : AppColors.sageGreen.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
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

/// Internet Check Page
class _InternetCheckPage extends StatelessWidget {
  final VoidCallback onNext;

  const _InternetCheckPage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.sageGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_outlined,
              size: 60,
              color: AppColors.sageGreen,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

          const SizedBox(height: 40),

          // Title
          Text(
            'Internet Connection Required',
            style: AppTextStyles.loraTitle().copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ).animate().fade(delay: 200.ms).slideY(begin: 0.3),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Quran Jarr needs an internet connection to fetch verses, translations, and audio recitations.',
              style: AppTextStyles.loraBodyMedium(),
              textAlign: TextAlign.center,
            ),
          ).animate().fade(delay: 400.ms).slideY(begin: 0.3),

          const SizedBox(height: 48),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _OnboardingButton(
                text: 'Maybe Later',
                isPrimary: false,
                onPressed: () {
                  PreferencesService.instance.setInternetAccepted(false);
                  onNext();
                },
              ).animate().fade(delay: 600.ms).slideX(begin: -0.3),

              const SizedBox(width: 16),

              _OnboardingButton(
                text: 'I Understand',
                isPrimary: true,
                onPressed: () {
                  PreferencesService.instance.setInternetAccepted(true);
                  onNext();
                },
              ).animate().fade(delay: 600.ms).slideX(begin: 0.3),
            ],
          ),
        ],
      ),
    );
  }
}

/// Onboarding Button Widget
class _OnboardingButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _OnboardingButton({
    required this.text,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary
            ? AppColors.sageGreen
            : AppColors.sageGreen.withValues(alpha: 0.1),
        foregroundColor: isPrimary ? AppColors.cream : AppColors.sageGreen,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.loraBodyMedium(),
      ),
    );
  }
}

/// Mode Selection Page
class _ModeSelectionPage extends ConsumerWidget {
  final VoidCallback onComplete;

  const _ModeSelectionPage({required this.onComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Title
          Text(
            'Choose Your Experience',
            style: AppTextStyles.loraTitle().copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ).animate().fade(delay: 200.ms).slideY(begin: 0.3),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select how you\'d like to receive verses from the Quran.',
              style: AppTextStyles.loraBodyMedium(),
              textAlign: TextAlign.center,
            ),
          ).animate().fade(delay: 400.ms).slideY(begin: 0.3),

          const SizedBox(height: 40),

          // Curated Mode Card
          _ModeCard(
            icon: Icons.auto_awesome_outlined,
            title: 'Curated Surahs',
            description: 'Carefully selected surahs focused on hope, comfort, gratitude, and mindfulness.',
            isSelected: false,
            onTap: () async {
              await PreferencesService.instance
                  .setVerseSelectionMode(VerseSelectionMode.curated);
              onComplete();
            },
          ).animate().fade(delay: 500.ms).slideY(begin: 0.3),

          const SizedBox(height: 20),

          // Random Mode Card
          _ModeCard(
            icon: Icons.shuffle_outlined,
            title: 'Random Verses',
            description: 'Completely random verses from all 114 surahs of the Quran.',
            isSelected: true,
            onTap: () async {
              await PreferencesService.instance
                  .setVerseSelectionMode(VerseSelectionMode.random);
              onComplete();
            },
          ).animate().fade(delay: 600.ms).slideY(begin: 0.3),
        ],
      ),
    );
  }
}

/// Mode Card Widget
class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.sageGreen.withValues(alpha: 0.15)
              : AppColors.sageGreen.withValues(alpha: 0.05),
          border: Border.all(
            color: isSelected
                ? AppColors.sageGreen
                : AppColors.sageGreen.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.sageGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: AppColors.sageGreen,
              ),
            ),

            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.loraHeading().copyWith(
                      color: AppColors.sageGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.loraBodySmall(),
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.sageGreen,
            ),
          ],
        ),
      ),
    );
  }
}
