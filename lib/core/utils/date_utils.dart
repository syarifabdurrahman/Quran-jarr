import 'package:hive_flutter/hive_flutter.dart';
import '../config/constants.dart';

/// Date Utilities for Daily Pull Logic
class DateUtils {
  DateUtils._();

  /// Check if a new verse is available (24h passed since last pull)
  static Future<bool> isNewVerseAvailable() async {
    final box = await Hive.openBox<dynamic>('app_data');
    final lastPullTimestamp = box.get(AppConstants.keyLastPullTimestamp);

    if (lastPullTimestamp == null) {
      return true; // First time user
    }

    final lastPull = DateTime.fromMillisecondsSinceEpoch(lastPullTimestamp as int);
    final now = DateTime.now();
    final difference = now.difference(lastPull);

    return difference >= AppConstants.dailyPullDuration;
  }

  /// Save the last pull timestamp
  static Future<void> saveLastPullTimestamp() async {
    final box = await Hive.openBox<dynamic>('app_data');
    await box.put(AppConstants.keyLastPullTimestamp, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get the last pull timestamp
  static Future<DateTime?> getLastPullTimestamp() async {
    final box = await Hive.openBox<dynamic>('app_data');
    final timestamp = box.get(AppConstants.keyLastPullTimestamp);

    if (timestamp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(timestamp as int);
  }

  /// Get time until next verse is available
  static Future<Duration?> getTimeUntilNextVerse() async {
    final lastPull = await getLastPullTimestamp();
    if (lastPull == null) return Duration.zero;

    final nextAvailable = lastPull.add(AppConstants.dailyPullDuration);
    final now = DateTime.now();
    final difference = nextAvailable.difference(now);

    return difference.isNegative ? Duration.zero : difference;
  }

  /// Format duration to human readable string
  static String formatDuration(Duration duration) {
    if (duration <= Duration.zero) return 'Available now';

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours hour${hours > 1 ? "s" : ""} $minutes minute${minutes != 1 ? "s" : ""}';
    }
    return '$minutes minute${minutes != 1 ? "s" : ""}';
  }
}
