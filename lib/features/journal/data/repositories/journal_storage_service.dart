import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/journal_entry.dart';

class JournalStorageService {
  JournalStorageService._();

  static final JournalStorageService instance = JournalStorageService._();

  Box? _box;

  Box get _b {
    if (_box == null) {
      throw StateError('JournalStorageService must be initialized before use');
    }
    return _box!;
  }

  static const String _boxName = 'journal_box';

  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<String> saveEntry(JournalEntry entry) async {
    await _b.put(entry.id, entry.toJson());
    return entry.id;
  }

  Future<JournalEntry?> getEntry(String id) async {
    final json = _b.get(id);
    if (json == null) return null;
    return JournalEntry.fromJson(Map<String, dynamic>.from(json as Map));
  }

  Future<List<JournalEntry>> getAllEntries() async {
    final entries = <JournalEntry>[];
    for (final key in _b.keys) {
      try {
        final json = _b.get(key);
        if (json != null) {
          entries.add(JournalEntry.fromJson(
            Map<String, dynamic>.from(json as Map),
          ));
        }
      } catch (_) {}
    }
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  Future<List<JournalEntry>> getEntriesForVerse(String verseKey) async {
    final all = await getAllEntries();
    return all.where((e) => e.verseKey == verseKey).toList();
  }

  Future<void> deleteEntry(String id) async {
    await _b.delete(id);
  }

  Future<void> deleteAll() async {
    await _b.clear();
  }

  int get entryCount => _b.length;

  Future<String> exportToJson() async {
    final entries = await getAllEntries();
    final jsonList = entries.map((e) => e.toJson()).toList();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonList);

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/quran_jarr_journal_${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await file.writeAsString(jsonStr);
    return file.path;
  }

  Future<void> shareBackup() async {
    final path = await exportToJson();
    await Share.shareXFiles(
      [XFile(path)],
      text: 'Quran Jarr - Journal Backup',
    );
  }

  Future<int> importFromJson(String jsonString) async {
    final List<dynamic> list = json.decode(jsonString) as List<dynamic>;
    int count = 0;
    for (final item in list) {
      try {
        final entry = JournalEntry.fromJson(item as Map<String, dynamic>);
        await saveEntry(entry);
        count++;
      } catch (_) {}
    }
    return count;
  }

  Future<void> close() async {
    if (_box != null && _b.isOpen) {
      await _b.close();
    }
  }
}
