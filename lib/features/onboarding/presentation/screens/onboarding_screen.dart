import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quran_jarr/core/config/constants.dart';
import 'package:quran_jarr/core/config/translations.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/core/providers/preferences_provider.dart';
import 'package:quran_jarr/core/services/ad_service.dart';
import 'package:quran_jarr/core/services/preferences_service.dart';
import 'package:quran_jarr/core/services/notification_service.dart';
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

  // Jar type selection (0 = classic)
  int _selectedJarType = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Save translation immediately when language is selected
  Future<void> _onLanguageChanged(String translationId) async {
    setState(() => _selectedTranslationId = translationId);
    final translation = AvailableTranslations.getById(translationId);
    await ref
        .read(preferencesNotifierProvider.notifier)
        .setTranslation(translation);
  }

  Future<void> _completeOnboarding() async {
    // Translation is already saved when selected, no need to save again here
    // Save other preferences using the notifier
    await ref
        .read(preferencesNotifierProvider.notifier)
        .setVersesPerDay(_selectedVersesPerDay);

    // Save jar type selection
    await ref
        .read(preferencesNotifierProvider.notifier)
        .setJarType(_selectedJarType);

    // Save onboarding completed LAST - this will trigger the app to rebuild and show JarScreen
    await ref
        .read(preferencesNotifierProvider.notifier)
        .setOnboardingCompleted(true);

    // Show interstitial ad after onboarding (delayed to not interrupt)
    Future.delayed(const Duration(seconds: 1), () {
      AdService.instance.showInterstitialAd();
    });

    // Don't navigate - let the provider change trigger a rebuild of the main app
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.midnightPeriwinkle : AppColors.sageGreen;
    final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.cream;

    return Scaffold(
      backgroundColor: bgColor,
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
                      style: AppTextStyles.loraBodySmallForTheme(context).copyWith(
                        color: primaryColor,
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
                    primaryColor: primaryColor,
                    selectedTranslationId: _selectedTranslationId,
                    onSelectionChanged: _onLanguageChanged,
                    onNext: _nextPage,
                    onSkip: _completeOnboarding,
                  ),
                  _InternetCheckPage(
                    primaryColor: primaryColor,
                    onNext: _nextPage,
                  ),
                  _ModeSelectionPage(
                    primaryColor: primaryColor,
                    onNext: _nextPage,
                  ),
                  _NotificationPermissionPage(
                    primaryColor: primaryColor,
                    onNext: _nextPage,
                    onComplete: _completeOnboarding,
                  ),
                  _VersesPerDayPage(
                    primaryColor: primaryColor,
                    selectedVersesPerDay: _selectedVersesPerDay,
                    onSelectionChanged: (value) {
                      setState(() => _selectedVersesPerDay = value);
                    },
                    onComplete: _nextPage,
                  ),
                  _JarTypeSelectionPage(
                    primaryColor: primaryColor,
                    selectedJarType: _selectedJarType,
                    onSelectionChanged: (value) {
                      setState(() => _selectedJarType = value);
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
                  6,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? primaryColor
                          : primaryColor.withValues(alpha: 0.3),
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
  final Color primaryColor;
  final String selectedTranslationId;
  final Future<void> Function(String) onSelectionChanged;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _LanguageSelectionPage({
    required this.primaryColor,
    required this.selectedTranslationId,
    required this.onSelectionChanged,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 120,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.language_outlined,
                  size: 60,
                  color: primaryColor,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 40),

              // Title
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  l10n.chooseYourLanguage,
                  style: AppTextStyles.loraTitleForTheme(context).copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.3),

              const SizedBox(height: 16),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.selectYourPreferredLanguage,
                  style: AppTextStyles.loraBodyMediumForTheme(context),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ).animate().fade(delay: 400.ms).slideY(begin: 0.3),

              const SizedBox(height: 40),

              // English Card
              _LanguageCard(
                primaryColor: primaryColor,
                languageName: l10n.english,
                languageCode: 'en',
                translationAuthor: 'Quran API',
                isSelected: selectedTranslationId == 'english',
                onTap: () => onSelectionChanged('english'),
              ).animate().fade(delay: 500.ms).slideY(begin: 0.3),

              const SizedBox(height: 20),

              // Indonesian Card
              _LanguageCard(
                primaryColor: primaryColor,
                languageName: l10n.bahasaIndonesia,
                languageCode: 'id',
                translationAuthor: 'Kemenag RI',
                isSelected: selectedTranslationId == 'indonesian',
                onTap: () => onSelectionChanged('indonesian'),
              ).animate().fade(delay: 600.ms).slideY(begin: 0.3),

              const SizedBox(height: 40),

              // Action Buttons
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Skip Button
                    TextButton(
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        l10n.cancel,
                        style: AppTextStyles.loraBodyMediumForTheme(context).copyWith(
                          color: primaryColor,
                        ),
                      ),
                    ).animate().fade(delay: 700.ms).slideX(begin: -0.3),

                    const SizedBox(width: 12),

                    // OK Button
                    ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: isDark ? AppColors.midnightSlate : AppColors.cream,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        l10n.ok,
                        style: AppTextStyles.loraBodyMediumForTheme(context),
                      ),
                    ).animate().fade(delay: 700.ms).slideX(begin: 0.3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Language Card Widget
class _LanguageCard extends StatelessWidget {
  final Color primaryColor;
  final String languageName;
  final String languageCode;
  final String translationAuthor;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.primaryColor,
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
              ? primaryColor.withValues(alpha: 0.15)
              : primaryColor.withValues(alpha: 0.05),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : primaryColor.withValues(alpha: 0.3),
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
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  languageCode.toUpperCase(),
                  style: AppTextStyles.loraHeadingForTheme(context).copyWith(
                    color: primaryColor,
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
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      languageName,
                      style: AppTextStyles.loraHeadingForTheme(context).copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Translation: $translationAuthor',
                    style: AppTextStyles.loraBodySmallForTheme(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Icon(Icons.check_circle, size: 24, color: primaryColor)
            else
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

/// Internet Check Page
class _InternetCheckPage extends StatelessWidget {
  final Color primaryColor;
  final VoidCallback onNext;

  const _InternetCheckPage({
    required this.primaryColor,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 120,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_outlined,
                  size: 60,
                  color: primaryColor,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 40),

              // Title
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  l10n.internetConnectionRequired,
                  style: AppTextStyles.loraTitleForTheme(context).copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.3),

              const SizedBox(height: 16),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.internetConnectionDesc,
                  style: AppTextStyles.loraBodyMediumForTheme(context),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
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
                    primaryColor: primaryColor,
                    onPressed: () {
                      PreferencesService.instance.setInternetAccepted(false);
                      onNext();
                    },
                  ).animate().fade(delay: 600.ms).slideX(begin: -0.3),

                  const SizedBox(width: 16),

                  _OnboardingButton(
                    text: l10n.iUnderstand,
                    isPrimary: true,
                    primaryColor: primaryColor,
                    onPressed: () {
                      PreferencesService.instance.setInternetAccepted(true);
                      onNext();
                    },
                  ).animate().fade(delay: 600.ms).slideX(begin: 0.3),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mode Selection Page
class _ModeSelectionPage extends StatelessWidget {
  final Color primaryColor;
  final VoidCallback onNext;

  const _ModeSelectionPage({
    required this.primaryColor,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 120,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Title
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  l10n.chooseYourExperience,
                  style: AppTextStyles.loraTitleForTheme(context).copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.3),

              const SizedBox(height: 16),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.selectYourExperienceDesc,
                  style: AppTextStyles.loraBodyMediumForTheme(context),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ).animate().fade(delay: 400.ms).slideY(begin: 0.3),

              const SizedBox(height: 40),

              // Curated Mode Card
              _ModeCard(
                icon: Icons.auto_awesome_outlined,
                title: l10n.curatedSurahs,
                description: l10n.curatedSurahsDesc,
                isSelected: false,
                primaryColor: primaryColor,
                onTap: () async {
                  await PreferencesService.instance.setVerseSelectionMode(
                    VerseSelectionMode.curated,
                  );
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
                primaryColor: primaryColor,
                onTap: () async {
                  await PreferencesService.instance.setVerseSelectionMode(
                    VerseSelectionMode.random,
                  );
                  onNext();
                },
              ).animate().fade(delay: 600.ms).slideY(begin: 0.3),
            ],
          ),
        ),
      ),
    );
  }
}

/// Notification Permission Page
class _NotificationPermissionPage extends StatelessWidget {
  final Color primaryColor;
  final VoidCallback onNext;
  final VoidCallback onComplete;

  const _NotificationPermissionPage({
    required this.primaryColor,
    required this.onNext,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 60,
              color: primaryColor,
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            l10n.dailyNotification,
            style: AppTextStyles.loraTitleForTheme(context).copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            l10n.dailyNotificationDesc,
            style: AppTextStyles.loraBodyMediumForTheme(context),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // Buttons
          SizedBox(
            width: double.infinity,
            child: _OnboardingButton(
              text: l10n.enableNotifications,
              isPrimary: true,
              primaryColor: primaryColor,
              onPressed: () async {
                await NotificationService.instance.requestPermission();
                await NotificationService.instance
                    .scheduleDailyNotification(
                      const TimeOfDay(hour: 7, minute: 0),
                    );
                await PreferencesService.instance
                    .setDailyNotificationEnabled(true);
                onNext();
              },
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: _OnboardingButton(
              text: l10n.maybeLater,
              isPrimary: false,
              primaryColor: primaryColor,
              onPressed: () {
                PreferencesService.instance.setDailyNotificationEnabled(
                  false,
                );
                onNext();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Verses Per Day Page
class _VersesPerDayPage extends StatelessWidget {
  final Color primaryColor;
  final int selectedVersesPerDay;
  final ValueChanged<int> onSelectionChanged;
  final VoidCallback onComplete;

  const _VersesPerDayPage({
    required this.primaryColor,
    required this.selectedVersesPerDay,
    required this.onSelectionChanged,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 120,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.format_list_numbered_outlined,
                  size: 60,
                  color: primaryColor,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 40),

              // Title
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  l10n.jarTapsPerDay,
                  style: AppTextStyles.loraTitleForTheme(context).copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.3),

              const SizedBox(height: 16),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.jarTapsPerDayDesc,
                  style: AppTextStyles.loraBodyMediumForTheme(context),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ).animate().fade(delay: 400.ms).slideY(begin: 0.3),

              const SizedBox(height: 40),

              // Verse count selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decrease button
                  GestureDetector(
                        onTap: () => onSelectionChanged(
                          selectedVersesPerDay > 1
                              ? selectedVersesPerDay - 1
                              : 1,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.remove,
                            color: primaryColor,
                            size: 28,
                          ),
                        ),
                      )
                      .animate()
                      .fade(delay: 500.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                      ),
                  const SizedBox(width: 24),
                  // Number display
                  GestureDetector(
                        onTap: () => onSelectionChanged(
                          selectedVersesPerDay >= 9999
                              ? 1
                              : selectedVersesPerDay + 1,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 100,
                          height: 64,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              selectedVersesPerDay >= 9999
                                  ? '∞'
                                  : selectedVersesPerDay.toString(),
                              style: AppTextStyles.loraTitleForTheme(context).copyWith(
                                color: isDark ? AppColors.darkCard : AppColors.cream,
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fade(delay: 600.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                      ),
                  const SizedBox(width: 24),
                  // Increase button
                  GestureDetector(
                        onTap: () =>
                            onSelectionChanged(selectedVersesPerDay + 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.add,
                            color: isDark ? AppColors.darkCard : AppColors.cream,
                            size: 28,
                          ),
                        ),
                      )
                      .animate()
                      .fade(delay: 700.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                      ),
                  const SizedBox(width: 12),
                  // Infinity button
                  GestureDetector(
                        onTap: () => onSelectionChanged(
                          selectedVersesPerDay >= 9999 ? 10 : 9999,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: selectedVersesPerDay >= 9999
                                ? primaryColor
                                : primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.all_inclusive,
                            color: selectedVersesPerDay >= 9999
                                ? (isDark ? AppColors.darkCard : AppColors.cream)
                                : primaryColor,
                            size: 28,
                          ),
                        ),
                      )
                      .animate()
                      .fade(delay: 800.ms)
                      .scale(
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
                primaryColor: primaryColor,
                onPressed: onComplete,
              ).animate().fade(delay: 800.ms).slideY(begin: 0.3),
            ],
          ),
        ),
      ),
    );
  }
}

/// Jar Type Selection Page
class _JarTypeSelectionPage extends StatelessWidget {
  final Color primaryColor;
  final int selectedJarType;
  final ValueChanged<int> onSelectionChanged;
  final VoidCallback onComplete;

  const _JarTypeSelectionPage({
    required this.primaryColor,
    required this.selectedJarType,
    required this.onSelectionChanged,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 120,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.local_drink, size: 60, color: primaryColor),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 40),

              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Choose Your Jar',
                  style: AppTextStyles.loraTitleForTheme(context).copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.3),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Select a jar style that speaks to you. You can change this anytime in settings.',
                  style: AppTextStyles.loraBodyMediumForTheme(context),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ).animate().fade(delay: 400.ms).slideY(begin: 0.3),

              const SizedBox(height: 40),

              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _JarTypeOption(
                    label: 'Classic',
                    icon: Icons.local_drink,
                    isSelected: selectedJarType == 0,
                    onTap: () => onSelectionChanged(0),
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                  _JarTypeOption(
                    label: 'Vintage',
                    icon: Icons.wine_bar,
                    isSelected: selectedJarType == 1,
                    onTap: () => onSelectionChanged(1),
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                  _JarTypeOption(
                    label: 'Modern',
                    icon: Icons.water_drop,
                    isSelected: selectedJarType == 2,
                    onTap: () => onSelectionChanged(2),
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                  _JarTypeOption(
                    label: 'Ornate',
                    icon: Icons.liquor,
                    isSelected: selectedJarType == 3,
                    onTap: () => onSelectionChanged(3),
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                ],
              ).animate().fade(delay: 600.ms).slideY(begin: 0.2),

              const SizedBox(height: 48),

              _OnboardingButton(
                text: 'Continue',
                isPrimary: true,
                primaryColor: primaryColor,
                onPressed: onComplete,
              ).animate().fade(delay: 800.ms).slideY(begin: 0.3),
            ],
          ),
        ),
      ),
    );
  }
}

class _JarTypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;
  final bool isDark;

  const _JarTypeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.15)
              : (isDark ? AppColors.darkElevated : AppColors.softSand),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : primaryColor.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? primaryColor
                  : primaryColor.withValues(alpha: 0.7),
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.loraBodyMediumForTheme(context).copyWith(
                color: isSelected ? primaryColor : null,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Onboarding Button Widget
class _OnboardingButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final Color primaryColor;
  final VoidCallback onPressed;

  const _OnboardingButton({
    required this.text,
    required this.isPrimary,
    required this.primaryColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary
            ? primaryColor
            : primaryColor.withValues(alpha: 0.1),
        foregroundColor: isPrimary ? (isDark ? AppColors.midnightSlate : AppColors.cream) : primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, style: AppTextStyles.loraBodyMediumForTheme(context), maxLines: 1),
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
  final Color primaryColor;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.15)
              : primaryColor.withValues(alpha: 0.05),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : primaryColor.withValues(alpha: 0.3),
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
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: primaryColor),
            ),

            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: AppTextStyles.loraHeadingForTheme(context).copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.loraBodySmallForTheme(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
          ],
        ),
      ),
    );
  }
}
