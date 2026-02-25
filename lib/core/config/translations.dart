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

/// Available Translations from Quran API
class AvailableTranslations {
  AvailableTranslations._();

  static const List<Translation> allTranslations = [
    // English
    Translation(
      id: 'english',
      name: 'English',
      author: 'Quran API',
      language: 'en',
    ),
    // Indonesian
    Translation(
      id: 'indonesian',
      name: 'Indonesian',
      author: 'Kemenag RI',
      language: 'id',
    ),
  ];

  static Translation get defaultTranslation => allTranslations.first;

  static Translation getById(String id) {
    return allTranslations.firstWhere(
      (t) => t.id == id,
      orElse: () => defaultTranslation,
    );
  }
}
