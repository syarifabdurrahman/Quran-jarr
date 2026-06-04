enum Mood {
  peaceful('peaceful', '😌'),
  grateful('grateful', '🥹'),
  hopeful('hopeful', '🌱'),
  reflective('reflective', '🤔'),
  joyful('joyful', '😊'),
  anxious('anxious', '😰'),
  sad('sad', '😢'),
  inspired('inspired', '✨'),
  loved('loved', '💚'),
  tested('tested', '🤲');

  final String label;
  final String emoji;

  const Mood(this.label, this.emoji);
}

class JournalEntry {
  final String id;
  final String verseKey;
  final String arabicText;
  final String translation;
  final String surahReference;
  final Mood? mood;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry({
    required this.id,
    required this.verseKey,
    required this.arabicText,
    required this.translation,
    required this.surahReference,
    this.mood,
    this.note,
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  JournalEntry copyWith({
    String? id,
    String? verseKey,
    String? arabicText,
    String? translation,
    String? surahReference,
    Mood? mood,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearMood = false,
    bool clearNote = false,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      verseKey: verseKey ?? this.verseKey,
      arabicText: arabicText ?? this.arabicText,
      translation: translation ?? this.translation,
      surahReference: surahReference ?? this.surahReference,
      mood: clearMood ? null : (mood ?? this.mood),
      note: clearNote ? null : (note ?? this.note),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'verseKey': verseKey,
        'arabicText': arabicText,
        'translation': translation,
        'surahReference': surahReference,
        'mood': mood?.name,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        verseKey: json['verseKey'] as String,
        arabicText: json['arabicText'] as String,
        translation: json['translation'] as String,
        surahReference: json['surahReference'] as String,
        mood: json['mood'] != null
            ? Mood.values.firstWhere(
                (m) => m.name == json['mood'],
                orElse: () => Mood.peaceful,
              )
            : null,
        note: json['note'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
