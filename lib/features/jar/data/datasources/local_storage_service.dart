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

  /// Save today's verse
  Future<void> saveTodayVerse(VerseModel verse) async {
    await _appDataBox.put(AppConstants.keyTodayVerse, verse.toJson());
  }

  /// Get today's verse
  Future<VerseModel?> getTodayVerse() async {
    final json = _appDataBox.get(AppConstants.keyTodayVerse);
    if (json == null) return null;
    return VerseModel.fromJson(json as Map<String, dynamic>);
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
        verses.add(VerseModel.fromJson(json as Map<String, dynamic>));
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

  /// Close all boxes
  Future<void> close() async {
    await _versesBox.close();
    await _appDataBox.close();
  }
}
