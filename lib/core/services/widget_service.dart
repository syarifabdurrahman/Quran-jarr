import 'dart:io';

import 'package:flutter/services.dart';

/// Widget Service
/// Handles home screen widget updates via platform channels
class WidgetService {
  WidgetService._();

  static final WidgetService _instance = WidgetService._();
  static WidgetService get instance => _instance;

  static const _channel = MethodChannel('com.simpurrapps.quran_jarr/widget');

  bool _isAvailable = false;

  /// Initialize the widget service
  Future<void> initialize() async {
    try {
      // Check if widget is available (Android only)
      if (Platform.isAndroid) {
        await _channel.invokeMethod('initialize');
        _isAvailable = true;
      }
    } catch (e) {
      _isAvailable = false;
    }
  }

  /// Check if widget is available
  bool get isAvailable => _isAvailable;

  /// Update widget with verse data
  Future<void> updateWidget({
    required String arabicText,
    required String translation,
    required String surahName,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    if (!_isAvailable) return;

    try {
      // Sanitize input - limit length and ensure non-empty strings
      final sanitizedArabic = arabicText.isNotEmpty ? arabicText.substring(0, arabicText.length.clamp(0, 500)) : "بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ";
      final sanitizedTranslation = translation.isNotEmpty ? translation.substring(0, translation.length.clamp(0, 500)) : "In the name of Allah, the Most Gracious, the Most Merciful";
      final sanitizedSurahName = surahName.isNotEmpty ? surahName.substring(0, surahName.length.clamp(0, 100)) : "Al-Fatiha";

      await _channel.invokeMethod('updateWidget', {
        'arabicText': sanitizedArabic,
        'translation': sanitizedTranslation,
        'surahName': sanitizedSurahName,
        'surahNumber': surahNumber.clamp(1, 114),
        'ayahNumber': ayahNumber.clamp(1, 286),
      });
    } catch (e) {
      // Log but ignore widget update errors - don't let widget issues crash the app
      // ignore: avoid_print
      print('Widget update error: $e');
    }
  }
}
