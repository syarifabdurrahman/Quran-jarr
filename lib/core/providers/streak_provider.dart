import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/services/streak_service.dart';

/// Streak State
class StreakState {
  final int currentStreak;
  final int longestStreak;
  final int totalVersesRead;
  final int versesReadToday;
  final bool hasReadToday;

  const StreakState({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalVersesRead = 0,
    this.versesReadToday = 0,
    this.hasReadToday = false,
  });

  StreakState copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalVersesRead,
    int? versesReadToday,
    bool? hasReadToday,
  }) {
    return StreakState(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalVersesRead: totalVersesRead ?? this.totalVersesRead,
      versesReadToday: versesReadToday ?? this.versesReadToday,
      hasReadToday: hasReadToday ?? this.hasReadToday,
    );
  }
}

/// Streak Notifier
class StreakNotifier extends StateNotifier<StreakState> {
  final StreakService _streakService = StreakService.instance;

  StreakNotifier() : super(const StreakState()) {
    _loadStreak();
  }

  void _loadStreak() {
    state = StreakState(
      currentStreak: _streakService.currentStreak,
      longestStreak: _streakService.longestStreak,
      totalVersesRead: _streakService.totalVersesRead,
      versesReadToday: _streakService.versesReadToday,
      hasReadToday: _streakService.hasReadToday,
    );
  }

  /// Record a verse read and update state
  /// Returns true if this is a new streak (consecutive day)
  Future<bool> recordVerseRead() async {
    final isNewStreak = await _streakService.recordVerseRead();
    _loadStreak();
    return isNewStreak;
  }

  /// Refresh streak state
  void refresh() {
    _loadStreak();
  }

  /// Check if current streak is a milestone
  bool get isMilestone => _streakService.isMilestone(state.currentStreak);

  /// Get milestone message
  String? get milestoneMessage =>
      _streakService.getMilestoneMessage(state.currentStreak);

  /// Get streak status message
  String get streakStatus => _streakService.getStreakStatus();

  /// Get progress to next milestone
  double get progressToNextMilestone =>
      _streakService.getProgressToNextMilestone();

  /// Get next milestone
  int get nextMilestone => _streakService.getNextMilestone();

  /// Get verses read this week
  int get versesThisWeek => _streakService.getVersesThisWeek();

  /// Get verses read this month
  int get versesThisMonth => _streakService.getVersesThisMonth();

  /// Get motivational message
  String get motivationalMessage => _streakService.getMotivationalMessage();
}

/// Streak Provider
final streakProvider = StateNotifierProvider<StreakNotifier, StreakState>((
  ref,
) {
  return StreakNotifier();
});

/// Quick access providers
final currentStreakProvider = Provider<int>((ref) {
  return ref.watch(streakProvider).currentStreak;
});

final longestStreakProvider = Provider<int>((ref) {
  return ref.watch(streakProvider).longestStreak;
});

final streakStatusProvider = Provider<String>((ref) {
  return ref.watch(streakProvider.notifier).streakStatus;
});
