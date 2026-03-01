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
      await _channel.invokeMethod('updateWidget', {
        'arabicText': arabicText,
        'translation': translation,
        'surahName': surahName,
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
      });
    } catch (e) {
      // Ignore widget update errors
    }
  }
}
