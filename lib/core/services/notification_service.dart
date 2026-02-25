import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:quran_jarr/core/services/preferences_service.dart';
import 'package:quran_jarr/features/jar/data/datasources/quran_api_service.dart';

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
  Future<void> scheduleDailyNotification(TimeOfDay time) async {
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
        );
      },
      (verse) async {
        // Create notification details with verse
        final title = verse.surahNameTranslation;
        final reference = '${verse.surahNumber}:${verse.ayahNumber}';
        final body = verse.translation.length > 100
            ? '${verse.translation.substring(0, 100)}...'
            : verse.translation;

        await _scheduleNotification(
          time,
          '$title ($reference)',
          body,
          payload: 'daily_verse_${verse.surahNumber}_${verse.ayahNumber}',
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
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time has passed today, schedule for tomorrow
    final scheduledTime = scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_verse_channel',
      'Daily Verse',
      channelDescription: 'Daily verse notifications from Quran Jarr',
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

    // Schedule the notification using zoned schedule (repeating daily)
    await _notifications.zonedSchedule(
      0, // notification id
      title,
      body,
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time,
    );
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
    // TODO: Navigate to specific verse when notification is tapped
    // This would require passing the verse key as payload and navigating to it
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
