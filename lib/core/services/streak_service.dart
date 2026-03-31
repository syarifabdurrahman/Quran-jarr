import 'package:hive_flutter/hive_flutter.dart';

/// Streak Service
/// Manages daily reading streak tracking
class StreakService {
  static final StreakService instance = StreakService._();
  StreakService._();

  late Box _streakBox;

  // Box name
  static const String _boxName = 'streak_box';

  // Keys
  static const String _currentStreakKey = 'current_streak';
  static const String _longestStreakKey = 'longest_streak';
  static const String _lastReadDateKey = 'last_read_date';
  static const String _totalVersesReadKey = 'total_verses_read';
  static const String _versesReadTodayKey = 'verses_read_today';
  static const String _todayDateKey = 'today_date';

  /// Initialize the streak service
  Future<void> initialize() async {
    _streakBox = await Hive.openBox(_boxName);
  }

  /// Get current streak count
  int get currentStreak =>
      (_streakBox.get(_currentStreakKey, defaultValue: 0) as num).toInt();

  /// Get longest streak count
  int get longestStreak =>
      (_streakBox.get(_longestStreakKey, defaultValue: 0) as num).toInt();

  /// Get total verses read
  int get totalVersesRead =>
      (_streakBox.get(_totalVersesReadKey, defaultValue: 0) as num).toInt();

  /// Get verses read today
  int get versesReadToday =>
      (_streakBox.get(_versesReadTodayKey, defaultValue: 0) as num).toInt();

  /// Get last read date
  DateTime? get lastReadDate {
    final dateString = _streakBox.get(_lastReadDateKey);
    if (dateString == null) return null;
    return DateTime.parse(dateString as String);
  }

  /// Get today's date (date only, no time)
  DateTime get _today => DateTime.now();
  DateTime get _todayDateOnly =>
      DateTime(_today.year, _today.month, _today.day);

  /// Check if user has read today
  bool get hasReadToday {
    final lastRead = lastReadDate;
    if (lastRead == null) return false;
    final lastReadDateOnly = DateTime(
      lastRead.year,
      lastRead.month,
      lastRead.day,
    );
    return lastReadDateOnly.isAtSameMomentAs(_todayDateOnly);
  }

  /// Record a verse read
  /// Returns true if this is a new streak (consecutive day)
  Future<bool> recordVerseRead() async {
    final now = DateTime.now();
    final todayDateOnly = DateTime(now.year, now.month, now.day);
    final lastRead = lastReadDate;

    // Increment total verses read
    final totalVerses = totalVersesRead + 1;
    await _streakBox.put(_totalVersesReadKey, totalVerses);

    // Update last read date
    await _streakBox.put(_lastReadDateKey, now.toIso8601String());

    // Check if this is a new day
    bool isNewStreak = false;

    if (lastRead == null) {
      // First verse ever read
      await _streakBox.put(_currentStreakKey, 1);
      await _streakBox.put(_versesReadTodayKey, 1);
      await _streakBox.put(_todayDateKey, todayDateOnly.toIso8601String());
      isNewStreak = true;
    } else {
      final lastReadDateOnly = DateTime(
        lastRead.year,
        lastRead.month,
        lastRead.day,
      );

      if (lastReadDateOnly.isAtSameMomentAs(todayDateOnly)) {
        // Same day, just increment verses read today
        final versesToday = versesReadToday + 1;
        await _streakBox.put(_versesReadTodayKey, versesToday);
      } else {
        // Check if it's consecutive (yesterday)
        final yesterday = todayDateOnly.subtract(const Duration(days: 1));

        if (lastReadDateOnly.isAtSameMomentAs(yesterday)) {
          // Consecutive day! Increment streak
          final newStreak = currentStreak + 1;
          await _streakBox.put(_currentStreakKey, newStreak);
          await _streakBox.put(_versesReadTodayKey, 1);
          await _streakBox.put(_todayDateKey, todayDateOnly.toIso8601String());
          isNewStreak = true;

          // Update longest streak if needed
          if (newStreak > longestStreak) {
            await _streakBox.put(_longestStreakKey, newStreak);
          }
        } else {
          // Streak broken, reset to 1
          await _streakBox.put(_currentStreakKey, 1);
          await _streakBox.put(_versesReadTodayKey, 1);
          await _streakBox.put(_todayDateKey, todayDateOnly.toIso8601String());
          isNewStreak = true;
        }
      }
    }

    return isNewStreak;
  }

  /// Check if streak is a milestone (7, 30, 100, etc.)
  bool isMilestone(int streak) {
    return streak == 7 || streak == 30 || streak == 100 || streak == 365;
  }

  /// Get milestone message
  String? getMilestoneMessage(int streak) {
    switch (streak) {
      case 7:
        return '🎉 7-day streak! Keep it up!';
      case 30:
        return '🌟 30-day streak! Amazing!';
      case 100:
        return '🏆 100-day streak! Incredible!';
      case 365:
        return '👑 1-year streak! MashaAllah!';
      default:
        return null;
    }
  }

  /// Reset streak (for testing or user preference)
  Future<void> resetStreak() async {
    await _streakBox.put(_currentStreakKey, 0);
    await _streakBox.put(_versesReadTodayKey, 0);
  }

  /// Get streak status for display
  String getStreakStatus() {
    final streak = currentStreak;
    if (streak == 0) return 'Start your streak today!';
    if (streak == 1) return 'Day 1 of your reading journey';
    return 'Day $streak of daily reading';
  }

  /// Get progress towards next milestone
  double getProgressToNextMilestone() {
    final streak = currentStreak;
    if (streak < 7) return streak / 7;
    if (streak < 30) return (streak - 7) / 23;
    if (streak < 100) return (streak - 30) / 70;
    if (streak < 365) return (streak - 100) / 265;
    return 1.0;
  }

  /// Get next milestone
  int getNextMilestone() {
    final streak = currentStreak;
    if (streak < 7) return 7;
    if (streak < 30) return 30;
    if (streak < 100) return 100;
    if (streak < 365) return 365;
    return 365;
  }

  /// Get verses read this week
  int getVersesThisWeek() {
    // For simplicity, return total verses read
    // In a more complex implementation, you'd track weekly data
    return totalVersesRead;
  }

  /// Get verses read this month
  int getVersesThisMonth() {
    // For simplicity, return total verses read
    // In a more complex implementation, you'd track monthly data
    return totalVersesRead;
  }

  /// Get motivational message based on stats
  String getMotivationalMessage() {
    final total = totalVersesRead;
    if (total >= 100) return "You've read $total verses! MashaAllah!";
    if (total >= 50) return "You've read $total verses this month!";
    if (total >= 20) return "You've read $total verses! Keep going!";
    if (total > 0) return "You've read $total verses!";
    return "Start your reading journey today!";
  }
}
