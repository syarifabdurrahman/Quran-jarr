import 'dart:math';

/// Personalized Notification Messages
/// Provides time-aware, gentle reminder messages for daily verse notifications
class NotificationMessages {
  NotificationMessages._();

  static final _random = Random();

  /// Get time-aware greeting based on hour of day
  static String getTimeAwareGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return _getRandomMessage(_morningGreetings);
    } else if (hour >= 12 && hour < 17) {
      return _getRandomMessage(_afternoonGreetings);
    } else if (hour >= 17 && hour < 21) {
      return _getRandomMessage(_eveningGreetings);
    } else {
      return _getRandomMessage(_nightGreetings);
    }
  }

  /// Get gentle reminder title
  static String getReminderTitle() {
    return _getRandomMessage(_reminderTitles);
  }

  /// Get motivational message
  static String getMotivationalMessage() {
    return _getRandomMessage(_motivationalMessages);
  }

  /// Get verse preview introduction
  static String getVersePreviewIntro() {
    return _getRandomMessage(_versePreviewIntros);
  }

  /// Get complete personalized notification
  /// Returns (title, body) tuple
  static (String, String) getPersonalizedNotification({
    required String surahName,
    required String verseReference,
    required String versePreview,
  }) {
    final greeting = getTimeAwareGreeting();
    final title = '$greeting \u2022 $surahName ($verseReference)';

    // Truncate verse preview if too long
    final preview = versePreview.length > 80
        ? '${versePreview.substring(0, 80)}...'
        : versePreview;

    final body = '${getVersePreviewIntro()} $preview';

    return (title, body);
  }

  /// Get fallback notification when verse fetch fails
  static (String, String) getFallbackNotification() {
    final title = getReminderTitle();
    final body = getMotivationalMessage();
    return (title, body);
  }

  /// Get random message from list
  static String _getRandomMessage(List<String> messages) {
    return messages[_random.nextInt(messages.length)];
  }

  // ==================== Message Lists ====================

  static const List<String> _morningGreetings = [
    'Good morning',
    'Rise and reflect',
    'Start your day',
    'Morning inspiration',
    'Begin with peace',
  ];

  static const List<String> _afternoonGreetings = [
    'Good afternoon',
    'Midday reflection',
    'Take a moment',
    'Afternoon pause',
    'Refresh your spirit',
  ];

  static const List<String> _eveningGreetings = [
    'Good evening',
    'Evening reflection',
    'Wind down with wisdom',
    'Peaceful evening',
    'End your day well',
  ];

  static const List<String> _nightGreetings = [
    'Night reflection',
    'Peaceful night',
    'Rest with wisdom',
    'Calm your mind',
    'Nighttime peace',
  ];

  static const List<String> _reminderTitles = [
    'Your Daily Verse Awaits',
    'Time for Reflection',
    'A Moment of Peace',
    'Daily Inspiration',
    'Your Verse for Today',
  ];

  static const List<String> _motivationalMessages = [
    'Take a moment to connect with the Quran today.',
    'A verse a day keeps the heart at peace.',
    'Let the words of the Quran guide your day.',
    'Find strength and comfort in today\'s verse.',
    'Pause, reflect, and find inner peace.',
    'The Quran has a message waiting for you.',
    'Start your journey of reflection today.',
    'Let wisdom guide your thoughts today.',
  ];

  static const List<String> _versePreviewIntros = [
    'Today\'s verse:',
    'Reflect on:',
    'Consider this:',
    'Ponder upon:',
    'Meditate on:',
    'Think about:',
    'Read and reflect:',
    'Today\'s wisdom:',
  ];
}
