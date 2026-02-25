import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/config/theme_config.dart';
import 'package:quran_jarr/core/providers/preferences_provider.dart';
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
    final isDarkMode = ref.watch(darkModeProvider);

    return MaterialApp(
      title: 'Quran Jarr',
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: FutureBuilder<bool>(
        future: _checkOnboarding(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: isDarkMode
                  ? const Color(0xFF1A1915)
                  : const Color(0xFFFFF8F0),
              body: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF7CB342),
                ),
              ),
            );
          }
          final isOnboarded = snapshot.data ?? false;
          return isOnboarded ? const JarScreen() : const OnboardingScreen();
        },
      ),
    );
  }

  Future<bool> _checkOnboarding() async {
    return PreferencesService.instance.isOnboardingCompleted();
  }
}
