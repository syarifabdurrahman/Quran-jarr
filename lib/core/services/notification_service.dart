import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:quran_jarr/core/services/preferences_service.dart';
import 'package:quran_jarr/core/data/surah_names.dart';
import 'package:quran_jarr/features/jar/data/datasources/quran_api_service.dart';
import 'package:quran_jarr/features/jar/data/datasources/local_storage_service.dart';
import 'package:quran_jarr/features/jar/data/models/verse_model.dart';

/// Notification Service
/// Handles daily verse notifications
class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  final QuranApiService _apiService = QuranApiService();

  bool _initialized = false;

  // Stream controller for notification tap events
  final _notificationTapController = StreamController<String>.broadcast();

  /// Stream of verse keys when notification is tapped
  Stream<String> get notificationTapStream => _notificationTapController.stream;

  /// Get the pending verse key (if any) from notification tap
  /// This should be called when jar screen initializes to load the verse
  Future<String?> getPendingVerseKey() async {
    return PreferencesService.instance.getAndClearPendingVerseKey();
  }

  /// Get the saved notification verse from local storage
  /// Returns null if not found or too old (24+ hours)
  Future<VerseModel?> getNotificationVerse() async {
    return await LocalStorageService.instance.getNotificationVerse();
  }

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    final result = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    return result ?? false;
  }

  /// Check if permission is granted
  Future<bool> isPermissionGranted() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (android == null) return true;

    return await android.areNotificationsEnabled() ?? false;
  }

  /// Schedule daily notification
  Future<void> scheduleDailyNotification(TimeOfDay time, {bool testMode = false}) async {
    if (!_initialized) await initialize();

    final prefs = PreferencesService.instance;
    final translationId = prefs.getTranslationId();

    // Fetch a random verse for the notification
    final verseResult = await _apiService.getRandomVerse(
      translationId: translationId,
    );

    await verseResult.fold(
      (error) async {
        // If fetch fails, schedule with a default message
        await _scheduleNotification(
          time,
          'Quran Jarr',
          'Tap to receive your daily verse from the Quran',
          testMode: testMode,
        );
      },
      (verse) async {
        // Save the verse to local storage for retrieval when notification is tapped
        await LocalStorageService.instance.saveNotificationVerse(verse);

        // Create notification details with verse
        final title = getArabicSurahName(verse.surahNumber);
        final reference = '${verse.surahNumber}:${verse.ayahNumber}';
        final body = verse.translation.length > 100
            ? '${verse.translation.substring(0, 100)}...'
            : verse.translation;

        await _scheduleNotification(
          time,
          '$title ($reference)',
          body,
          payload: 'daily_verse_${verse.surahNumber}_${verse.ayahNumber}',
          testMode: testMode,
        );
      },
    );
  }

  /// Schedule notification at specific time
  Future<void> _scheduleNotification(
    TimeOfDay time,
    String title,
    String body, {
    String? payload,
    bool testMode = false,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    // For test mode, schedule every 5 minutes from now
    final scheduledTime = testMode
        ? now.add(const Duration(minutes: 5))
        : tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day,
            time.hour,
            time.minute,
          );

    // If the time has passed today (and not test mode), schedule for tomorrow
    final scheduledDate = !testMode && scheduledTime.isBefore(now)
        ? scheduledTime.add(const Duration(days: 1))
        : scheduledTime;

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      testMode ? 'test_verse_channel' : 'daily_verse_channel',
      testMode ? 'Test Verse' : 'Daily Verse',
      channelDescription: testMode
          ? 'Test notifications (every 5 minutes)'
          : 'Daily verse notifications from Quran Jarr',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: const BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // For test mode: show immediately
    // For normal mode: schedule repeating daily at specific time
    if (testMode) {
      // Show test notification immediately
      await _notifications.show(
        999, // test notification id
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } else {
      await _notifications.zonedSchedule(
        0, // notification id
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    // Parse verse key from payload (format: "daily_verse_surah_ayah")
    final payload = response.payload;
    if (payload != null && payload.startsWith('daily_verse_')) {
      // Extract verse key from payload
      // Format: "daily_verse_2_255" -> "2:255"
      final parts = payload.replaceFirst('daily_verse_', '').split('_');
      if (parts.length == 2) {
        final verseKey = '${parts[0]}:${parts[1]}';
        // Persist the pending verse key for retrieval after app launch
        PreferencesService.instance.setPendingVerseKey(verseKey);
        // Also send through stream for real-time handling
        _notificationTapController.add(verseKey);
      }
    }
  }

  /// Dispose the stream controller
  void dispose() {
    _notificationTapController.close();
  }

  /// Get scheduled notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Check if daily notification is scheduled
  Future<bool> isDailyNotificationScheduled() async {
    final pending = await getPendingNotifications();
    return pending.any((n) => n.payload?.startsWith('daily_verse') ?? false);
  }
}
