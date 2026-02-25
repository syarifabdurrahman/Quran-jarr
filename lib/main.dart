import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/config/theme_config.dart';
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

class QuranJarrApp extends StatelessWidget {
  const QuranJarrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkOnboarding(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            title: 'Quran Jarr',
            debugShowCheckedModeBanner: false,
            theme: ThemeConfig.lightTheme,
            home: Scaffold(
              backgroundColor: const Color(0xFFFFF8F0),
              body: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF7CB342),
                ),
              ),
            ),
          );
        }
        final isOnboarded = snapshot.data ?? false;
        return MaterialApp(
          title: 'Quran Jarr',
          debugShowCheckedModeBanner: false,
          theme: ThemeConfig.lightTheme,
          home: isOnboarded ? const JarScreen() : const OnboardingScreen(),
        );
      },
    );
  }

  Future<bool> _checkOnboarding() async {
    return PreferencesService.instance.isOnboardingCompleted();
  }
}
