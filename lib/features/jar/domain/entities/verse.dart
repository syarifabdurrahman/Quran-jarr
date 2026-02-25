import 'package:freezed_annotation/freezed_annotation.dart';

part 'verse.freezed.dart';
part 'verse.g.dart';

/// Verse Entity representing a Quranic verse
/// Following SOLID principles - entity is pure data without business logic
@freezed
class Verse with _$Verse {
  const Verse._();

  const factory Verse({
    required int surahNumber,
    required int ayahNumber,
    required String arabicText,
    required String translation,
    required String surahName,
    required String surahNameTranslation,
    required String verseKey, // e.g., "2:255"
    String? audioUrl,
    @Default(false) bool isSaved,
    DateTime? savedAt,
  }) = _Verse;

  factory Verse.fromJson(Map<String, dynamic> json) => _$VerseFromJson(json);

  /// Get display text for surah reference
  String get surahReference => '$surahName ($surahNumber:$ayahNumber)';

  /// Check if verse has audio available
  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;
}
