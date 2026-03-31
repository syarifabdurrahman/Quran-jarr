import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Timezone Helper
/// Provides consistent timezone handling across the app
class TimezoneHelper {
  TimezoneHelper._();

  static bool _initialized = false;

  /// Initialize timezone data
  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    // Set local timezone to device's timezone
    final localTimeZone = getTimeZoneByOffset(DateTime.now().timeZoneOffset);
    tz.setLocalLocation(tz.getLocation(localTimeZone));

    _initialized = true;
  }

  /// Get timezone by offset (supports global timezones)
  static String getTimeZoneByOffset(Duration offset) {
    final int hours = offset.inHours;

    // Map common offsets to IANA timezone names
    switch (hours) {
      // Indonesia
      case 7:
        return 'Asia/Jakarta'; // WIB
      case 8:
        return 'Asia/Makassar'; // WITA
      case 9:
        return 'Asia/Jayapura'; // WIT
      // Middle East
      case 3:
        return 'Asia/Riyadh';
      // Europe
      case 0:
        return 'Europe/London';
      case 1:
        return 'Europe/Paris';
      case 2:
        return 'Europe/Helsinki';
      // Americas
      case -5:
        return 'America/New_York';
      case -6:
        return 'America/Chicago';
      case -7:
        return 'America/Denver';
      case -8:
        return 'America/Los_Angeles';
      // Asia
      case 5:
        return 'Asia/Karachi';
      case 5.5:
        return 'Asia/Kolkata';
      case 6:
        return 'Asia/Dhaka';
      case 10:
        return 'Australia/Sydney';
      case 11:
        return 'Pacific/Auckland';
      default:
        // Use UTC for unknown offsets
        return 'UTC';
    }
  }

  /// Get current local time as TZDateTime
  static tz.TZDateTime now() {
    return tz.TZDateTime.now(tz.local);
  }

  /// Create TZDateTime from components
  static tz.TZDateTime createDateTime(
    int year,
    int month,
    int day,
    int hour,
    int minute,
  ) {
    return tz.TZDateTime(tz.local, year, month, day, hour, minute);
  }

  /// Get time until midnight in local timezone
  static Duration timeUntilMidnight() {
    final now = tz.TZDateTime.now(tz.local);
    final midnight = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }

  /// Get time until specific hour/minute
  static Duration timeUntil(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var target = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If target time has passed today, calculate for tomorrow
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }

    return target.difference(now);
  }

  /// Format duration as "Xh Ym" or "Ym"
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
