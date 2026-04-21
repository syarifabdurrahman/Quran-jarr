import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/l10n/app_localizations.dart';
import 'package:quran_jarr/core/config/theme_config.dart';
import 'package:quran_jarr/core/providers/locale_provider.dart';
import 'package:quran_jarr/core/providers/preferences_provider.dart';
import 'package:quran_jarr/core/services/locale_service.dart';
import 'package:quran_jarr/core/services/notification_service.dart';
import 'package:quran_jarr/core/services/preferences_service.dart';
import 'package:quran_jarr/core/services/streak_service.dart';
import 'package:quran_jarr/core/services/widget_service.dart';
import 'package:quran_jarr/core/services/ad_service.dart';
import 'package:quran_jarr/features/jar/data/datasources/local_storage_service.dart';
import 'package:quran_jarr/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:quran_jarr/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:quran_jarr/core/network/dio_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Critical services - initialize immediately
  DioClient.instance.initialize();
  await LocalStorageService.instance.initialize();
  await PreferencesService.instance.initialize();
  await StreakService.instance.initialize();

  // Start the app immediately
  runApp(const ProviderScope(child: QuranJarrApp()));

  // Defer non-critical services to after first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeNonCriticalServices();
  });
}

/// Initialize non-critical services after first frame
void _initializeNonCriticalServices() {
  // Run in background without blocking UI
  NotificationService.instance.initialize();
  WidgetService.instance.initialize();
  AdService.instance.initialize();
}

class QuranJarrApp extends ConsumerWidget {
  const QuranJarrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeNotifierProvider);
    final isOnboarded = ref.watch(_onboardingProvider);
    final themeMode = ref.watch(themeModeProvider);
    final reducedMotion = ref.watch(reducedMotionProvider);

    return Builder(
      builder: (context) {
        final systemTextScale = MediaQuery.of(context).textScaler.scale(1.0);
        final clampedTextScale = systemTextScale.clamp(1.0, 1.3);

        ThemeData currentTheme;
        switch (themeMode) {
          case 1:
            currentTheme = ThemeConfig.lightTheme;
            break;
          case 2:
            currentTheme = ThemeConfig.darkTheme;
            break;
          default:
            currentTheme = ThemeConfig.lightTheme;
        }

        if (themeMode == 0) {
          final systemBrightness = MediaQuery.platformBrightnessOf(context);
          currentTheme = systemBrightness == Brightness.dark
              ? ThemeConfig.darkTheme
              : ThemeConfig.lightTheme;
        }

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(clampedTextScale),
            disableAnimations: reducedMotion,
          ),
          child: AnimatedTheme(
            data: currentTheme,
            duration: const Duration(milliseconds: 300),
            child: MaterialApp(
              title: 'Quran Jarr',
              debugShowCheckedModeBanner: false,
              theme: currentTheme,
              locale: locale,
              supportedLocales: LocaleService.instance.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: isOnboarded
                  ? const MainNavigationScreen()
                  : const OnboardingScreen(),
            ),
          ),
        );
      },
    );
  }
}

final _onboardingProvider = Provider<bool>((ref) {
  final prefs = ref.watch(preferencesNotifierProvider).prefs;
  return prefs.isOnboardingCompleted();
});
