import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
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

  // Stream controller for notification tap events with cached value
  String? _cachedVerseKey;
  final _notificationTapController = StreamController<String>.broadcast();

  /// Stream of verse keys when notification is tapped
  /// Emits the cached value immediately when a new listener subscribes
  Stream<String> get notificationTapStream {
    // Create a stream that starts with the cached value if it matches the requested key
    if (_cachedVerseKey != null) {
      return _notificationTapController.stream.startWith(_cachedVerseKey!);
    }
    return _notificationTapController.stream;
  }

  /// Get the pending verse key (if any) from notification tap
  /// This checks both storage and in-memory cache
  Future<String?> getPendingVerseKey() async {
    print('🔔 NotificationService.getPendingVerseKey: _cachedVerseKey = $_cachedVerseKey');

    // First check in-memory cache (for notification taps that happened during init)
    if (_cachedVerseKey != null) {
      final key = _cachedVerseKey;
      _cachedVerseKey = null; // Clear after reading
      return key;
    }

    // Then check storage (for notification taps from terminated state)
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

    // Check if app was launched from a notification (terminated state)
    // This MUST be called AFTER initialization and BEFORE getPendingVerseKey()
    await _checkNotificationAppLaunch();
  }

  /// Check if app was launched from a notification when in terminated state
  Future<void> _checkNotificationAppLaunch() async {
    final details = await _notifications.getNotificationAppLaunchDetails();
    print('🔔 _checkNotificationAppLaunch: details = $details');

    if (details != null && details.didNotificationLaunchApp) {
      final response = details.notificationResponse;
      if (response != null) {
        print('🔔 _checkNotificationAppLaunch: didNotificationLaunchApp = true');
        print('🔔 _checkNotificationAppLaunch: payload = ${response.payload}');

        // Process the notification response
        _onNotificationTap(response);
      }
    } else {
      print('🔔 _checkNotificationAppLaunch: app was not launched from notification');
    }
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

  /// Open app notification settings (for enabling exact alarm permission on Android 12+)
  Future<void> openNotificationSettings() async {
    // This requires the user to manually enable SCHEDULE_EXACT_ALARM in system settings
    // We can't programmatically enable it, but we can guide the user
    print('🔔 Please enable SCHEDULE_EXACT_ALARM permission in app settings');
    print('🔔 Go to: Settings > Apps > Quran Jarr > Alarms & reminders');
  }

  /// Schedule daily notification
  Future<void> scheduleDailyNotification(TimeOfDay time, {bool testMode = false}) async {
    if (!_initialized) await initialize();

    // Ensure permission is granted
    final hasPermission = await isPermissionGranted();
    if (!hasPermission) {
      final granted = await requestPermission();
      if (!granted) {
        print('🔔 Notification permission denied');
        return;
      }
    }

    // Cancel old daily notification (ID 0) before scheduling new one
    // This prevents duplicate notifications when rescheduling
    if (!testMode) {
      await cancel(0);
    }

    final prefs = PreferencesService.instance;
    final translationId = prefs.getTranslationId();

    // Fetch a random verse for the notification
    final verseResult = await _apiService.getRandomVerse(
      translationId: translationId,
    );

    await verseResult.fold(
      (error) async {
        print('🔔 Failed to fetch verse for notification: $error');
        // If fetch fails, schedule with a default message
        await _scheduleNotification(
          time,
          'Quran Jarr',
          'Tap to receive your daily verse from the Quran',
          testMode: testMode,
        );
        // Debug: Print all scheduled notifications
        await debugPrintScheduledNotifications();
      },
      (verse) async {
        print('🔔 Fetched verse ${verse.verseKey} for notification');
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
        print('🔔 Notification scheduled for ${time.hour}:${time.minute}');

        // Debug: Print all scheduled notifications
        await debugPrintScheduledNotifications();
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
      // Use zonedSchedule with exact time matching for daily repeat
      // This is more reliable than periodicallyShow for specific times
      await _notifications.zonedSchedule(
        0, // notification id
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print('🔔 Daily notification scheduled for ${time.hour}:${time.minute}');
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
    print('🔔 NotificationService._onNotificationTap called');
    print('🔔 Response payload: ${response.payload}');

    // Parse verse key from payload (format: "daily_verse_surah_ayah")
    final payload = response.payload;
    if (payload != null && payload.startsWith('daily_verse_')) {
      // Extract verse key from payload
      // Format: "daily_verse_2_255" -> "2:255"
      final parts = payload.replaceFirst('daily_verse_', '').split('_');
      if (parts.length == 2) {
        final verseKey = '${parts[0]}:${parts[1]}';
        print('🔔 Extracted verse key: $verseKey');
        // Store in in-memory cache for immediate retrieval
        _cachedVerseKey = verseKey;
        print('🔔 Cached verse key in memory');
        // Also persist to storage for retrieval after app restart
        PreferencesService.instance.setPendingVerseKey(verseKey);
        print('🔔 Stored pending verse key');
        // Send through stream for real-time handling
        _notificationTapController.add(verseKey);
        print('🔔 Added verse key to stream');
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

  /// Debug: Print all scheduled notifications
  Future<void> debugPrintScheduledNotifications() async {
    final pending = await getPendingNotifications();
    print('🔔 ========== SCHEDULED NOTIFICATIONS ==========');
    print('🔔 Total scheduled: ${pending.length}');
    for (final n in pending) {
      print('🔔   ID: ${n.id}, Title: ${n.title}, Body: ${n.body}, Payload: ${n.payload}');
    }
    print('🔔 ============================================');
  }

  /// Check if daily notification is scheduled
  Future<bool> isDailyNotificationScheduled() async {
    final pending = await getPendingNotifications();
    return pending.any((n) => n.payload?.startsWith('daily_verse') ?? false);
  }
}
