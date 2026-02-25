/// Curated Surahs Data
/// List of surahs selected for their aesthetic of hope, comfort, gratitude, and mindfulness
class CuratedSurahs {
  CuratedSurahs._();

  /// Map of surah name to surah number
  static const Map<String, int> curatedSurahMap = {
    'Al-Fatihah': 1,
    'Ar-Rahman': 55,
    'Ad-Duha': 93,
    'Ash-Sharh': 94,
    'Al-Asr': 103,
    'Al-Ikhlas': 112,
    'Al-Falaq': 113,
    'An-Nas': 114,
    'Al-Mulk': 67,
    'Al-Fajr': 89,
    'At-Tin': 95,
    'Al-Kawthar': 108,
    'Al-Qadr': 97,
    'Ash-Shams': 91,
    'Al-Layl': 92,
    'Al-Ghashiyah': 88,
    'Al-A\'la': 87,
    'Al-Balad': 90,
    'Quraish': 106,
    'Al-Ma\'un': 107,
    'At-Takathur': 102,
    'Al-Buruj': 85,
    'At-Tariq': 86,
    'Al-Infitar': 82,
    'Al-Alaq': 96,
    'Al-Zalzalah': 99,
    'Al-Adiyat': 100,
    'Al-Qari\'ah': 101,
    'An-Naba': 78,
    'An-Naziat': 79,
    'Abasa': 80,
    'At-Takwir': 81,
    'Al-Mutaffifin': 83,
    'Al-Inshiqaq': 84,
    'Al-Humazah': 104,
    'Al-Fil': 105,
    'Al-Kafirun': 109,
    'An-Nasr': 110,
    'Al-Masad': 111,
  };

  /// Get list of curated surah numbers
  static List<int> get surahNumbers => curatedSurahMap.values.toList();

  /// Get random curated surah number
  static int getRandomSurahNumber() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return surahNumbers[random % surahNumbers.length];
  }

  /// Get surah number by name
  static int? getSurahNumber(String name) => curatedSurahMap[name];

  /// Get surah name by number
  static String? getSurahName(int number) {
    for (final entry in curatedSurahMap.entries) {
      if (entry.value == number) return entry.key;
    }
    return null;
  }
}
