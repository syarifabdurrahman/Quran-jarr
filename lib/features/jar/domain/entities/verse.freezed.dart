// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verse.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Verse _$VerseFromJson(Map<String, dynamic> json) {
  return _Verse.fromJson(json);
}

/// @nodoc
mixin _$Verse {
  int get surahNumber => throw _privateConstructorUsedError;
  int get ayahNumber => throw _privateConstructorUsedError;
  String get arabicText => throw _privateConstructorUsedError;
  String get translation => throw _privateConstructorUsedError;
  String get surahName => throw _privateConstructorUsedError;
  String get surahNameTranslation => throw _privateConstructorUsedError;
  String get verseKey => throw _privateConstructorUsedError; // e.g., "2:255"
  String get translationId =>
      throw _privateConstructorUsedError; // Translation language ID
  String? get audioUrl => throw _privateConstructorUsedError;
  Map<String, String>? get tafsirByTranslation =>
      throw _privateConstructorUsedError; // Tafsir by translation ID (e.g., {'english': '...', 'indonesian': '...'})
  bool get isSaved => throw _privateConstructorUsedError;
  DateTime? get savedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VerseCopyWith<Verse> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerseCopyWith<$Res> {
  factory $VerseCopyWith(Verse value, $Res Function(Verse) then) =
      _$VerseCopyWithImpl<$Res, Verse>;
  @useResult
  $Res call(
      {int surahNumber,
      int ayahNumber,
      String arabicText,
      String translation,
      String surahName,
      String surahNameTranslation,
      String verseKey,
      String translationId,
      String? audioUrl,
      Map<String, String>? tafsirByTranslation,
      bool isSaved,
      DateTime? savedAt});
}

/// @nodoc
class _$VerseCopyWithImpl<$Res, $Val extends Verse>
    implements $VerseCopyWith<$Res> {
  _$VerseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? surahNumber = null,
    Object? ayahNumber = null,
    Object? arabicText = null,
    Object? translation = null,
    Object? surahName = null,
    Object? surahNameTranslation = null,
    Object? verseKey = null,
    Object? translationId = null,
    Object? audioUrl = freezed,
    Object? tafsirByTranslation = freezed,
    Object? isSaved = null,
    Object? savedAt = freezed,
  }) {
    return _then(_value.copyWith(
      surahNumber: null == surahNumber
          ? _value.surahNumber
          : surahNumber // ignore: cast_nullable_to_non_nullable
              as int,
      ayahNumber: null == ayahNumber
          ? _value.ayahNumber
          : ayahNumber // ignore: cast_nullable_to_non_nullable
              as int,
      arabicText: null == arabicText
          ? _value.arabicText
          : arabicText // ignore: cast_nullable_to_non_nullable
              as String,
      translation: null == translation
          ? _value.translation
          : translation // ignore: cast_nullable_to_non_nullable
              as String,
      surahName: null == surahName
          ? _value.surahName
          : surahName // ignore: cast_nullable_to_non_nullable
              as String,
      surahNameTranslation: null == surahNameTranslation
          ? _value.surahNameTranslation
          : surahNameTranslation // ignore: cast_nullable_to_non_nullable
              as String,
      verseKey: null == verseKey
          ? _value.verseKey
          : verseKey // ignore: cast_nullable_to_non_nullable
              as String,
      translationId: null == translationId
          ? _value.translationId
          : translationId // ignore: cast_nullable_to_non_nullable
              as String,
      audioUrl: freezed == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tafsirByTranslation: freezed == tafsirByTranslation
          ? _value.tafsirByTranslation
          : tafsirByTranslation // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      isSaved: null == isSaved
          ? _value.isSaved
          : isSaved // ignore: cast_nullable_to_non_nullable
              as bool,
      savedAt: freezed == savedAt
          ? _value.savedAt
          : savedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VerseImplCopyWith<$Res> implements $VerseCopyWith<$Res> {
  factory _$$VerseImplCopyWith(
          _$VerseImpl value, $Res Function(_$VerseImpl) then) =
      __$$VerseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int surahNumber,
      int ayahNumber,
      String arabicText,
      String translation,
      String surahName,
      String surahNameTranslation,
      String verseKey,
      String translationId,
      String? audioUrl,
      Map<String, String>? tafsirByTranslation,
      bool isSaved,
      DateTime? savedAt});
}

/// @nodoc
class __$$VerseImplCopyWithImpl<$Res>
    extends _$VerseCopyWithImpl<$Res, _$VerseImpl>
    implements _$$VerseImplCopyWith<$Res> {
  __$$VerseImplCopyWithImpl(
      _$VerseImpl _value, $Res Function(_$VerseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? surahNumber = null,
    Object? ayahNumber = null,
    Object? arabicText = null,
    Object? translation = null,
    Object? surahName = null,
    Object? surahNameTranslation = null,
    Object? verseKey = null,
    Object? translationId = null,
    Object? audioUrl = freezed,
    Object? tafsirByTranslation = freezed,
    Object? isSaved = null,
    Object? savedAt = freezed,
  }) {
    return _then(_$VerseImpl(
      surahNumber: null == surahNumber
          ? _value.surahNumber
          : surahNumber // ignore: cast_nullable_to_non_nullable
              as int,
      ayahNumber: null == ayahNumber
          ? _value.ayahNumber
          : ayahNumber // ignore: cast_nullable_to_non_nullable
              as int,
      arabicText: null == arabicText
          ? _value.arabicText
          : arabicText // ignore: cast_nullable_to_non_nullable
              as String,
      translation: null == translation
          ? _value.translation
          : translation // ignore: cast_nullable_to_non_nullable
              as String,
      surahName: null == surahName
          ? _value.surahName
          : surahName // ignore: cast_nullable_to_non_nullable
              as String,
      surahNameTranslation: null == surahNameTranslation
          ? _value.surahNameTranslation
          : surahNameTranslation // ignore: cast_nullable_to_non_nullable
              as String,
      verseKey: null == verseKey
          ? _value.verseKey
          : verseKey // ignore: cast_nullable_to_non_nullable
              as String,
      translationId: null == translationId
          ? _value.translationId
          : translationId // ignore: cast_nullable_to_non_nullable
              as String,
      audioUrl: freezed == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tafsirByTranslation: freezed == tafsirByTranslation
          ? _value._tafsirByTranslation
          : tafsirByTranslation // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      isSaved: null == isSaved
          ? _value.isSaved
          : isSaved // ignore: cast_nullable_to_non_nullable
              as bool,
      savedAt: freezed == savedAt
          ? _value.savedAt
          : savedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VerseImpl extends _Verse {
  const _$VerseImpl(
      {required this.surahNumber,
      required this.ayahNumber,
      required this.arabicText,
      required this.translation,
      required this.surahName,
      required this.surahNameTranslation,
      required this.verseKey,
      this.translationId = 'english',
      this.audioUrl,
      final Map<String, String>? tafsirByTranslation,
      this.isSaved = false,
      this.savedAt})
      : _tafsirByTranslation = tafsirByTranslation,
        super._();

  factory _$VerseImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerseImplFromJson(json);

  @override
  final int surahNumber;
  @override
  final int ayahNumber;
  @override
  final String arabicText;
  @override
  final String translation;
  @override
  final String surahName;
  @override
  final String surahNameTranslation;
  @override
  final String verseKey;
// e.g., "2:255"
  @override
  @JsonKey()
  final String translationId;
// Translation language ID
  @override
  final String? audioUrl;
  final Map<String, String>? _tafsirByTranslation;
  @override
  Map<String, String>? get tafsirByTranslation {
    final value = _tafsirByTranslation;
    if (value == null) return null;
    if (_tafsirByTranslation is EqualUnmodifiableMapView)
      return _tafsirByTranslation;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

// Tafsir by translation ID (e.g., {'english': '...', 'indonesian': '...'})
  @override
  @JsonKey()
  final bool isSaved;
  @override
  final DateTime? savedAt;

  @override
  String toString() {
    return 'Verse(surahNumber: $surahNumber, ayahNumber: $ayahNumber, arabicText: $arabicText, translation: $translation, surahName: $surahName, surahNameTranslation: $surahNameTranslation, verseKey: $verseKey, translationId: $translationId, audioUrl: $audioUrl, tafsirByTranslation: $tafsirByTranslation, isSaved: $isSaved, savedAt: $savedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerseImpl &&
            (identical(other.surahNumber, surahNumber) ||
                other.surahNumber == surahNumber) &&
            (identical(other.ayahNumber, ayahNumber) ||
                other.ayahNumber == ayahNumber) &&
            (identical(other.arabicText, arabicText) ||
                other.arabicText == arabicText) &&
            (identical(other.translation, translation) ||
                other.translation == translation) &&
            (identical(other.surahName, surahName) ||
                other.surahName == surahName) &&
            (identical(other.surahNameTranslation, surahNameTranslation) ||
                other.surahNameTranslation == surahNameTranslation) &&
            (identical(other.verseKey, verseKey) ||
                other.verseKey == verseKey) &&
            (identical(other.translationId, translationId) ||
                other.translationId == translationId) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            const DeepCollectionEquality()
                .equals(other._tafsirByTranslation, _tafsirByTranslation) &&
            (identical(other.isSaved, isSaved) || other.isSaved == isSaved) &&
            (identical(other.savedAt, savedAt) || other.savedAt == savedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      surahNumber,
      ayahNumber,
      arabicText,
      translation,
      surahName,
      surahNameTranslation,
      verseKey,
      translationId,
      audioUrl,
      const DeepCollectionEquality().hash(_tafsirByTranslation),
      isSaved,
      savedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VerseImplCopyWith<_$VerseImpl> get copyWith =>
      __$$VerseImplCopyWithImpl<_$VerseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VerseImplToJson(
      this,
    );
  }
}

abstract class _Verse extends Verse {
  const factory _Verse(
      {required final int surahNumber,
      required final int ayahNumber,
      required final String arabicText,
      required final String translation,
      required final String surahName,
      required final String surahNameTranslation,
      required final String verseKey,
      final String translationId,
      final String? audioUrl,
      final Map<String, String>? tafsirByTranslation,
      final bool isSaved,
      final DateTime? savedAt}) = _$VerseImpl;
  const _Verse._() : super._();

  factory _Verse.fromJson(Map<String, dynamic> json) = _$VerseImpl.fromJson;

  @override
  int get surahNumber;
  @override
  int get ayahNumber;
  @override
  String get arabicText;
  @override
  String get translation;
  @override
  String get surahName;
  @override
  String get surahNameTranslation;
  @override
  String get verseKey;
  @override // e.g., "2:255"
  String get translationId;
  @override // Translation language ID
  String? get audioUrl;
  @override
  Map<String, String>? get tafsirByTranslation;
  @override // Tafsir by translation ID (e.g., {'english': '...', 'indonesian': '...'})
  bool get isSaved;
  @override
  DateTime? get savedAt;
  @override
  @JsonKey(ignore: true)
  _$$VerseImplCopyWith<_$VerseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
