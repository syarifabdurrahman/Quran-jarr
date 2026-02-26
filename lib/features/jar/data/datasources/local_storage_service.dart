import 'package:hive_flutter/hive_flutter.dart';
import 'package:quran_jarr/core/config/constants.dart';
import '../models/verse_model.dart';

/// Local Storage Service using Hive
/// Handles all local data persistence
class LocalStorageService {
  LocalStorageService._();

  static final LocalStorageService _instance = LocalStorageService._();
  static LocalStorageService get instance => _instance;

  late Box _versesBox;
  late Box _appDataBox;

  /// Initialize Hive boxes
  Future<void> initialize() async {
    await Hive.initFlutter();
    _versesBox = await Hive.openBox(AppConstants.keySavedVerses);
    _appDataBox = await Hive.openBox('app_data');
  }

  /// Save today's verse with timestamp
  Future<void> saveTodayVerse(VerseModel verse) async {
    await _appDataBox.put(AppConstants.keyTodayVerse, verse.toJson());
    await _appDataBox.put('${AppConstants.keyTodayVerse}_timestamp', DateTime.now().toIso8601String());
  }

  /// Get today's verse (only if less than 24 hours old)
  Future<VerseModel?> getTodayVerse() async {
    final json = _appDataBox.get(AppConstants.keyTodayVerse);
    if (json == null) return null;

    // Check timestamp
    final timestampStr = _appDataBox.get('${AppConstants.keyTodayVerse}_timestamp');
    if (timestampStr != null) {
      final timestamp = DateTime.parse(timestampStr as String);
      final now = DateTime.now();
      final hoursPassed = now.difference(timestamp).inHours;

      // If more than 24 hours have passed, return null to force refresh
      if (hoursPassed >= 24) {
        return null;
      }
    }

    // Convert Map<dynamic, dynamic> to Map<String, dynamic>
    final map = Map<String, dynamic>.from(json as Map);
    return VerseModel.fromJson(map);
  }

  /// Save a verse to archive
  Future<void> saveVerseToArchive(VerseModel verse) async {
    final updatedVerse = verse.copyWith(
      isSaved: true,
      savedAt: DateTime.now(),
    );
    await _versesBox.put(verse.verseKey, updatedVerse.toJson());
  }

  /// Remove a verse from archive
  Future<void> removeVerseFromArchive(String verseKey) async {
    await _versesBox.delete(verseKey);
  }

  /// Get all saved verses
  Future<List<VerseModel>> getSavedVerses() async {
    final keys = _versesBox.keys;
    final verses = <VerseModel>[];

    for (final key in keys) {
      final json = _versesBox.get(key);
      if (json != null) {
        // Convert Map<dynamic, dynamic> to Map<String, dynamic>
        final map = Map<String, dynamic>.from(json as Map);
        final verse = VerseModel.fromJson(map);
        // Ensure all verses from archive are marked as saved
        // This handles old data that might not have isSaved set
        verses.add(verse.copyWith(isSaved: true));
      }
    }

    // Sort by savedAt descending (newest first)
    verses.sort((a, b) {
      final aTime = a.savedAt ?? DateTime(0);
      final bTime = b.savedAt ?? DateTime(0);
      return bTime.compareTo(aTime);
    });

    return verses;
  }

  /// Check if a verse is saved
  Future<bool> isVerseSaved(String verseKey) async {
    return _versesBox.containsKey(verseKey);
  }

  /// Clear all saved verses
  Future<void> clearArchive() async {
    await _versesBox.clear();
  }

  /// Get verse count
  int get savedVerseCount => _versesBox.length;

  /// Save notification verse for later retrieval when notification is tapped
  Future<void> saveNotificationVerse(VerseModel verse) async {
    await _appDataBox.put('notification_verse', verse.toJson());
    await _appDataBox.put('notification_verse_timestamp', DateTime.now().toIso8601String());
  }

  /// Get notification verse (returns null if not found or not from today)
  Future<VerseModel?> getNotificationVerse() async {
    final json = _appDataBox.get('notification_verse');
    if (json == null) return null;

    // Check timestamp - only return if from today
    final timestampStr = _appDataBox.get('notification_verse_timestamp');
    if (timestampStr != null) {
      final timestamp = DateTime.parse(timestampStr as String);
      final now = DateTime.now();

      // Check if the cached verse is from today (same calendar day)
      final cachedDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
      final today = DateTime(now.year, now.month, now.day);

      if (cachedDate != today) {
        // Cached verse is from a previous day, clear it and return null
        await clearNotificationVerse();
        return null;
      }
    }

    // Convert Map<dynamic, dynamic> to Map<String, dynamic>
    final map = Map<String, dynamic>.from(json as Map);
    return VerseModel.fromJson(map);
  }

  /// Clear notification verse
  Future<void> clearNotificationVerse() async {
    await _appDataBox.delete('notification_verse');
    await _appDataBox.delete('notification_verse_timestamp');
  }

  /// Close all boxes
  Future<void> close() async {
    await _versesBox.close();
    await _appDataBox.close();
  }
}
