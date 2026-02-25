import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/config/theme_config.dart';
import 'package:quran_jarr/core/services/preferences_service.dart';
import 'package:quran_jarr/features/jar/data/datasources/local_storage_service.dart';
import 'package:quran_jarr/features/jar/presentation/screens/jar_screen.dart';
import 'package:quran_jarr/core/network/dio_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  DioClient.instance.initialize();
  await LocalStorageService.instance.initialize();
  await PreferencesService.instance.initialize();

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
    return MaterialApp(
      title: 'Quran Jarr',
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.lightTheme,
      home: const JarScreen(),
    );
  }
}
