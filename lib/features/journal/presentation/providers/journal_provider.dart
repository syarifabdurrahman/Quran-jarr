import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/features/journal/data/repositories/journal_storage_service.dart';
import 'package:quran_jarr/features/journal/domain/entities/journal_entry.dart';

final journalStorageServiceProvider = Provider<JournalStorageService>((ref) {
  return JournalStorageService.instance;
});

class JournalState {
  final List<JournalEntry> entries;
  final bool isLoading;

  const JournalState({
    this.entries = const [],
    this.isLoading = false,
  });

  JournalState copyWith({
    List<JournalEntry>? entries,
    bool? isLoading,
  }) {
    return JournalState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class JournalNotifier extends StateNotifier<JournalState> {
  final JournalStorageService _service;

  JournalNotifier(this._service) : super(const JournalState());

  Future<void> loadEntries() async {
    state = state.copyWith(isLoading: true);
    final entries = await _service.getAllEntries();
    state = state.copyWith(entries: entries, isLoading: false);
  }

  Future<String> saveEntry(JournalEntry entry) async {
    final id = await _service.saveEntry(entry);
    await loadEntries();
    return id;
  }

  Future<void> deleteEntry(String id) async {
    await _service.deleteEntry(id);
    await loadEntries();
  }

  Future<List<JournalEntry>> getEntriesForVerse(String verseKey) async {
    return _service.getEntriesForVerse(verseKey);
  }

  Future<void> exportBackup() async {
    await _service.shareBackup();
  }

  Future<String> exportToJson() async {
    return _service.exportToJson();
  }

  Future<int> importFromJson(String jsonString) async {
    final count = await _service.importFromJson(jsonString);
    await loadEntries();
    return count;
  }
}

final journalNotifierProvider =
    StateNotifierProvider<JournalNotifier, JournalState>((ref) {
  return JournalNotifier(JournalStorageService.instance);
});
