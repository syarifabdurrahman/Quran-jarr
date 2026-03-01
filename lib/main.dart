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
import 'package:quran_jarr/core/services/widget_service.dart';
import 'package:quran_jarr/features/jar/data/datasources/local_storage_service.dart';
import 'package:quran_jarr/features/jar/presentation/screens/jar_screen.dart';
import 'package:quran_jarr/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:quran_jarr/core/network/dio_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  DioClient.instance.initialize();
  await LocalStorageService.instance.initialize();
  await PreferencesService.instance.initialize();
  await NotificationService.instance.initialize();
  await WidgetService.instance.initialize();

  runApp(
    const ProviderScope(
      child: QuranJarrApp(),
    ),
  );
}

class QuranJarrApp extends ConsumerWidget {
  const QuranJarrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeNotifierProvider);
    final isOnboarded = ref.watch(_onboardingProvider);

    return MaterialApp(
      title: 'Quran Jarr',
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.lightTheme,
      locale: locale,
      supportedLocales: LocaleService.instance.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: isOnboarded ? const JarScreen() : const OnboardingScreen(),
    );
  }
}

/// Provider for checking onboarding status (reacts to preference changes)
final _onboardingProvider = Provider<bool>((ref) {
  // Watch preferences provider to trigger updates when preferences change
  final prefs = ref.watch(preferencesNotifierProvider).prefs;
  return prefs.isOnboardingCompleted();
});
