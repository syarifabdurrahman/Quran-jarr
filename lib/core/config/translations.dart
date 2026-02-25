/// Available Quran Translations
class Translation {
  final String id;
  final String name;
  final String author;
  final String language;

  const Translation({
    required this.id,
    required this.name,
    required this.author,
    required this.language,
  });
}

/// Available English Translations
class AvailableTranslations {
  AvailableTranslations._();

  static const List<Translation> englishTranslations = [
    Translation(
      id: '131',
      name: 'Sahih International',
      author: 'Sahih International',
      language: 'en',
    ),
    Translation(
      id: '161',
      name: 'Mustafa Khattab',
      author: 'Mustafa Khattab',
      language: 'en',
    ),
    Translation(
      id: '20',
      name: 'Wahiduddin Khan (Indonesian)',
      author: 'Wahiduddin Khan',
      language: 'id',
    ),
    Translation(
      id: '131',
      name: 'Dr. Mustafa Khattab (The Clear Quran)',
      author: 'Dr. Mustafa Khattab',
      language: 'en',
    ),
  ];

  static Translation get defaultTranslation => englishTranslations.first;

  static Translation getById(String id) {
    return englishTranslations.firstWhere(
      (t) => t.id == id,
      orElse: () => defaultTranslation,
    );
  }
}
