// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VerseImpl _$$VerseImplFromJson(Map<String, dynamic> json) => _$VerseImpl(
      surahNumber: (json['surahNumber'] as num).toInt(),
      ayahNumber: (json['ayahNumber'] as num).toInt(),
      arabicText: json['arabicText'] as String,
      translation: json['translation'] as String,
      surahName: json['surahName'] as String,
      surahNameTranslation: json['surahNameTranslation'] as String,
      verseKey: json['verseKey'] as String,
      translationId: json['translationId'] as String? ?? 'english',
      audioUrl: json['audioUrl'] as String?,
      tafsirByTranslation:
          (json['tafsirByTranslation'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      isSaved: json['isSaved'] as bool? ?? false,
      savedAt: json['savedAt'] == null
          ? null
          : DateTime.parse(json['savedAt'] as String),
    );

Map<String, dynamic> _$$VerseImplToJson(_$VerseImpl instance) =>
    <String, dynamic>{
      'surahNumber': instance.surahNumber,
      'ayahNumber': instance.ayahNumber,
      'arabicText': instance.arabicText,
      'translation': instance.translation,
      'surahName': instance.surahName,
      'surahNameTranslation': instance.surahNameTranslation,
      'verseKey': instance.verseKey,
      'translationId': instance.translationId,
      'audioUrl': instance.audioUrl,
      'tafsirByTranslation': instance.tafsirByTranslation,
      'isSaved': instance.isSaved,
      'savedAt': instance.savedAt?.toIso8601String(),
    };
