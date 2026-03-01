import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quran_jarr/core/config/constants.dart';
import 'package:quran_jarr/core/config/translations.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/core/providers/preferences_provider.dart';
import 'package:quran_jarr/core/services/preferences_service.dart';
import 'package:quran_jarr/core/services/notification_service.dart';
import 'package:quran_jarr/l10n/app_localizations.dart';
import 'package:quran_jarr/core/services/locale_service.dart';

/// Onboarding Screen
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Language/Locale selection (English by default)
  String _selectedTranslationId = 'english';

  // Verses per day selection
  int _selectedVersesPerDay = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Save translation immediately when language is selected
  Future<void> _onLanguageChanged(String translationId) async {
    setState(() => _selectedTranslationId = translationId);
    final translation = AvailableTranslations.getById(translationId);
    await ref.read(preferencesNotifierProvider.notifier).setTranslation(translation);
  }

  Future<void> _completeOnboarding() async {
    // Translation is already saved when selected, no need to save again here
    // Save other preferences using the notifier
    await ref.read(preferencesNotifierProvider.notifier).setVersesPerDay(_selectedVersesPerDay);

    // Save onboarding completed LAST - this will trigger the app to rebuild and show JarScreen
    await ref.read(preferencesNotifierProvider.notifier).setOnboardingCompleted(true);

    // Don't navigate - let the provider change trigger a rebuild of the main app
  }

  void _nextPage() {
    if (_currentPage < 4) {
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
            // Skip button (only show on pages 3-4, not on language page)
            if (_currentPage >= 3)
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
                  _LanguageSelectionPage(
                    selectedTranslationId: _selectedTranslationId,
                    onSelectionChanged: _onLanguageChanged,
                    onNext: _nextPage,
                    onSkip: _completeOnboarding,
                  ),
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
                  5,
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

/// Language Selection Page
class _LanguageSelectionPage extends StatelessWidget {
  final String selectedTranslationId;
  final Future<void> Function(String) onSelectionChanged;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _LanguageSelectionPage({
    required this.selectedTranslationId,
    required this.onSelectionChanged,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
              Icons.language_outlined,
              size: 60,
              color: AppColors.sageGreen,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

          const SizedBox(height: 40),

          // Title
          Text(
            l10n.chooseYourLanguage,
            style: AppTextStyles.loraTitle().copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ).animate().fade(delay: 200.ms).slideY(begin: 0.3),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.selectYourPreferredLanguage,
              style: AppTextStyles.loraBodyMedium(),
              textAlign: TextAlign.center,
            ),
          ).animate().fade(delay: 400.ms).slideY(begin: 0.3),

          const SizedBox(height: 40),

          // English Card
          _LanguageCard(
            languageName: l10n.english,
            languageCode: 'en',
            translationAuthor: 'Quran API',
            isSelected: selectedTranslationId == 'english',
            onTap: () => onSelectionChanged('english'),
          ).animate().fade(delay: 500.ms).slideY(begin: 0.3),

          const SizedBox(height: 20),

          // Indonesian Card
          _LanguageCard(
            languageName: l10n.bahasaIndonesia,
            languageCode: 'id',
            translationAuthor: 'Kemenag RI',
            isSelected: selectedTranslationId == 'indonesian',
            onTap: () => onSelectionChanged('indonesian'),
          ).animate().fade(delay: 600.ms).slideY(begin: 0.3),

          const SizedBox(height: 40),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Skip Button
              TextButton(
                onPressed: onSkip,
                child: Text(
                  l10n.cancel,
                  style: AppTextStyles.loraBodyMedium().copyWith(
                    color: AppColors.sageGreen,
                  ),
                ),
              ).animate().fade(delay: 700.ms).slideX(begin: -0.3),

              const SizedBox(width: 16),

              // OK Button
              ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sageGreen,
                  foregroundColor: AppColors.cream,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.ok,
                  style: AppTextStyles.loraBodyMedium(),
                ),
              ).animate().fade(delay: 700.ms).slideX(begin: 0.3),
            ],
          ),
        ],
      ),
    );
  }
}

/// Language Card Widget
class _LanguageCard extends StatelessWidget {
  final String languageName;
  final String languageCode;
  final String translationAuthor;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.languageName,
    required this.languageCode,
    required this.translationAuthor,
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
            // Language Code Badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.sageGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  languageCode.toUpperCase(),
                  style: AppTextStyles.loraHeading().copyWith(
                    color: AppColors.sageGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageName,
                    style: AppTextStyles.loraHeading().copyWith(
                      color: AppColors.sageGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Translation: $translationAuthor',
                    style: AppTextStyles.loraBodySmall(),
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 24,
                color: AppColors.sageGreen,
              )
            else
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

/// Internet Check Page
class _InternetCheckPage extends StatelessWidget {
  final VoidCallback onNext;

  const _InternetCheckPage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
            l10n.internetConnectionRequired,
            style: AppTextStyles.loraTitle().copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ).animate().fade(delay: 200.ms).slideY(begin: 0.3),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.internetConnectionDesc,
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
                text: l10n.maybeLater,
                isPrimary: false,
                onPressed: () {
                  PreferencesService.instance.setInternetAccepted(false);
                  onNext();
                },
              ).animate().fade(delay: 600.ms).slideX(begin: -0.3),

              const SizedBox(width: 16),

              _OnboardingButton(
                text: l10n.iUnderstand,
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
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Title
          Text(
            l10n.chooseYourExperience,
            style: AppTextStyles.loraTitle().copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ).animate().fade(delay: 200.ms).slideY(begin: 0.3),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.selectYourExperienceDesc,
              style: AppTextStyles.loraBodyMedium(),
              textAlign: TextAlign.center,
            ),
          ).animate().fade(delay: 400.ms).slideY(begin: 0.3),

          const SizedBox(height: 40),

          // Curated Mode Card
          _ModeCard(
            icon: Icons.auto_awesome_outlined,
            title: l10n.curatedSurahs,
            description: l10n.curatedSurahsDesc,
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
            title: l10n.randomVerses,
            description: l10n.randomVersesDesc,
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
    final l10n = context.l10n;
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
            l10n.dailyNotification,
            style: AppTextStyles.loraTitle().copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ).animate().fade(delay: 200.ms).slideY(begin: 0.3),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.dailyNotificationDesc,
              style: AppTextStyles.loraBodyMedium(),
              textAlign: TextAlign.center,
            ),
          ).animate().fade(delay: 400.ms).slideY(begin: 0.3),

          const SizedBox(height: 48),

          // Buttons
          Column(
            children: [
              _OnboardingButton(
                text: l10n.enableNotifications,
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
                text: l10n.maybeLater,
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
    final l10n = context.l10n;
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
            l10n.jarTapsPerDay,
            style: AppTextStyles.loraTitle().copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ).animate().fade(delay: 200.ms).slideY(begin: 0.3),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.jarTapsPerDayDesc,
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
            text: l10n.getStarted,
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
