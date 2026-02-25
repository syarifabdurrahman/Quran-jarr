import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/verse.dart';

part 'verse_model.freezed.dart';
part 'verse_model.g.dart';

/// Verse Model for API responses and local storage
/// Handles JSON serialization and conversion to/from Verse entity
@freezed
class VerseModel with _$VerseModel {
  const VerseModel._();

  const factory VerseModel({
    required int surahNumber,
    required int ayahNumber,
    required String arabicText,
    required String translation,
    required String surahName,
    @Default('') String surahNameTranslation,
    required String verseKey,
    String? audioUrl,
    @Default(false) bool isSaved,
    DateTime? savedAt,
  }) = _VerseModel;

  factory VerseModel.fromJson(Map<String, dynamic> json) =>
      _$VerseModelFromJson(json);

  /// Convert VerseModel to Verse entity
  Verse toEntity() => Verse(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        arabicText: arabicText,
        translation: translation,
        surahName: surahName,
        surahNameTranslation: surahNameTranslation,
        verseKey: verseKey,
        audioUrl: audioUrl,
        isSaved: isSaved,
        savedAt: savedAt,
      );

  /// Convert Verse entity to VerseModel
  factory VerseModel.fromEntity(Verse verse) => VerseModel(
        surahNumber: verse.surahNumber,
        ayahNumber: verse.ayahNumber,
        arabicText: verse.arabicText,
        translation: verse.translation,
        surahName: verse.surahName,
        surahNameTranslation: verse.surahNameTranslation,
        verseKey: verse.verseKey,
        audioUrl: verse.audioUrl,
        isSaved: verse.isSaved,
        savedAt: verse.savedAt,
      );
}
