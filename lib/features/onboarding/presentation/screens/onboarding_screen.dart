import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quran_jarr/core/config/constants.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/core/services/preferences_service.dart';
import 'package:quran_jarr/core/services/notification_service.dart';
import 'package:quran_jarr/features/jar/presentation/screens/jar_screen.dart';

/// Onboarding Screen
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Verses per day selection
  int _selectedVersesPerDay = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await PreferencesService.instance.setVersesPerDay(_selectedVersesPerDay);
    await PreferencesService.instance.setOnboardingCompleted(true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const JarScreen()),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < 3) {
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
            // Skip button (only show on pages 2-3)
            if (_currentPage >= 2)
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
                  _ModeSelectionPage(onNext: _nextPage),
                  _NotificationPermissionPage(
                    onNext: _nextPage,
                    onComplete: _completeOnboarding,
                  ),
                  _VersesPerDayPage(
                    selectedVersesPerDay: _selectedVersesPerDay,
                    onSelectionChanged: (value) {
                      setState(() => _selectedVersesPerDay = value);
                    },
                    onComplete: _completeOnboarding,
                  ),
                ],
              ),
            ),

            // Page Indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
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

/// Mode Selection Page
class _ModeSelectionPage extends StatelessWidget {
  final VoidCallback onNext;

  const _ModeSelectionPage({required this.onNext});

  @override
  Widget build(BuildContext context) {
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
              onNext();
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
              onNext();
            },
          ).animate().fade(delay: 600.ms).slideY(begin: 0.3),
        ],
      ),
    );
  }
}

/// Notification Permission Page
class _NotificationPermissionPage extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onComplete;

  const _NotificationPermissionPage({
    required this.onNext,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.sageGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              size: 60,
              color: AppColors.sageGreen,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

          const SizedBox(height: 40),

          // Title
          Text(
            'Daily Verses',
            style: AppTextStyles.loraTitle().copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ).animate().fade(delay: 200.ms).slideY(begin: 0.3),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Receive a beautiful verse from the Quran every day to start your morning with peace and reflection.',
              style: AppTextStyles.loraBodyMedium(),
              textAlign: TextAlign.center,
            ),
          ).animate().fade(delay: 400.ms).slideY(begin: 0.3),

          const SizedBox(height: 48),

          // Buttons
          Column(
            children: [
              _OnboardingButton(
                text: 'Enable Notifications',
                isPrimary: true,
                onPressed: () async {
                  await NotificationService.instance.requestPermission();
                  await NotificationService.instance.scheduleDailyNotification(
                    const TimeOfDay(hour: 7, minute: 0),
                  );
                  await PreferencesService.instance.setDailyNotificationEnabled(true);
                  onNext();
                },
              ).animate().fade(delay: 600.ms).slideX(begin: 0.3),

              const SizedBox(height: 16),

              _OnboardingButton(
                text: 'Maybe Later',
                isPrimary: false,
                onPressed: () {
                  PreferencesService.instance.setDailyNotificationEnabled(false);
                  onNext();
                },
              ).animate().fade(delay: 700.ms).slideX(begin: -0.3),
            ],
          ),
        ],
      ),
    );
  }
}

/// Verses Per Day Page
class _VersesPerDayPage extends StatelessWidget {
  final int selectedVersesPerDay;
  final ValueChanged<int> onSelectionChanged;
  final VoidCallback onComplete;

  const _VersesPerDayPage({
    required this.selectedVersesPerDay,
    required this.onSelectionChanged,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.sageGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.format_list_numbered_outlined,
              size: 60,
              color: AppColors.sageGreen,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

          const SizedBox(height: 40),

          // Title
          Text(
            'Jar Taps Per Day',
            style: AppTextStyles.loraTitle().copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ).animate().fade(delay: 200.ms).slideY(begin: 0.3),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Choose how many jar taps you\'d like per day. Tap the number to increase, or use +/- buttons. You can change this later in settings.',
              style: AppTextStyles.loraBodyMedium(),
              textAlign: TextAlign.center,
            ),
          ).animate().fade(delay: 400.ms).slideY(begin: 0.3),

          const SizedBox(height: 40),

          // Verse count selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decrease button
              GestureDetector(
                onTap: () => onSelectionChanged(selectedVersesPerDay > 1 ? selectedVersesPerDay - 1 : 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.sageGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.sageGreen.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: AppColors.sageGreen,
                    size: 28,
                  ),
                ),
              ).animate().fade(delay: 500.ms).scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                  ),
              const SizedBox(width: 24),
              // Number display
              GestureDetector(
                onTap: () => onSelectionChanged(selectedVersesPerDay >= 9999 ? 1 : selectedVersesPerDay + 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 100,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.sageGreen,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.sageGreen,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      selectedVersesPerDay >= 9999 ? '∞' : selectedVersesPerDay.toString(),
                      style: AppTextStyles.loraTitle().copyWith(
                        color: AppColors.cream,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  ),
                ),
              ).animate().fade(delay: 600.ms).scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                  ),
              const SizedBox(width: 24),
              // Increase button
              GestureDetector(
                onTap: () => onSelectionChanged(selectedVersesPerDay + 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.sageGreen,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.sageGreen,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.cream,
                    size: 28,
                  ),
                ),
              ).animate().fade(delay: 700.ms).scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                  ),
              const SizedBox(width: 12),
              // Infinity button
              GestureDetector(
                onTap: () => onSelectionChanged(selectedVersesPerDay >= 9999 ? 10 : 9999),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: selectedVersesPerDay >= 9999 ? AppColors.sageGreen : AppColors.sageGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.sageGreen,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.all_inclusive,
                    color: selectedVersesPerDay >= 9999 ? AppColors.cream : AppColors.sageGreen,
                    size: 28,
                  ),
                ),
              ).animate().fade(delay: 800.ms).scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                  ),
            ],
          ),

          const SizedBox(height: 48),

          // Complete button
          _OnboardingButton(
            text: 'Get Started',
            isPrimary: true,
            onPressed: onComplete,
          ).animate().fade(delay: 800.ms).slideY(begin: 0.3),
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
