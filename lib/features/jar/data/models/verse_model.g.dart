// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VerseModelImpl _$$VerseModelImplFromJson(Map<String, dynamic> json) =>
    _$VerseModelImpl(
      surahNumber: (json['surahNumber'] as num).toInt(),
      ayahNumber: (json['ayahNumber'] as num).toInt(),
      arabicText: json['arabicText'] as String,
      translation: json['translation'] as String,
      surahName: json['surahName'] as String,
      surahNameTranslation: json['surahNameTranslation'] as String? ?? '',
      verseKey: json['verseKey'] as String,
      audioUrl: json['audioUrl'] as String?,
      isSaved: json['isSaved'] as bool? ?? false,
      savedAt: json['savedAt'] == null
          ? null
          : DateTime.parse(json['savedAt'] as String),
    );

Map<String, dynamic> _$$VerseModelImplToJson(_$VerseModelImpl instance) =>
    <String, dynamic>{
      'surahNumber': instance.surahNumber,
      'ayahNumber': instance.ayahNumber,
      'arabicText': instance.arabicText,
      'translation': instance.translation,
      'surahName': instance.surahName,
      'surahNameTranslation': instance.surahNameTranslation,
      'verseKey': instance.verseKey,
      'audioUrl': instance.audioUrl,
      'isSaved': instance.isSaved,
      'savedAt': instance.savedAt?.toIso8601String(),
    };
