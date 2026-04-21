import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/providers/preferences_provider.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/features/archive/presentation/providers/archive_provider.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';
import 'package:quran_jarr/features/jar/presentation/widgets/verse_card_widget.dart';
import 'package:quran_jarr/features/jar/presentation/widgets/translation_picker_widget.dart';
import 'package:quran_jarr/features/ads/presentation/widgets/native_ad_widget.dart';

/// Sort options for archive
enum SortOption {
  newest,
  oldest,
  surah;

  String get displayName {
    switch (this) {
      case SortOption.newest:
        return 'Newest First';
      case SortOption.oldest:
        return 'Oldest First';
      case SortOption.surah:
        return 'By Surah';
    }
  }
}

/// Archive Screen - Optimized with lazy loading
class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  final TextEditingController _searchController = TextEditingController();
  SortOption _currentSort = SortOption.newest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(archiveNotifierProvider.notifier).searchVerses(query);
  }

  void _showTranslationPicker() {
    showTranslationPicker(
      context,
      onTranslationChanged: (translationId) {
        return ref
            .read(archiveNotifierProvider.notifier)
            .reloadVersesWithTranslation(translationId);
      },
    );
  }

  void _deleteVerse(Verse verse) {
    ref.read(archiveNotifierProvider.notifier).deleteVerse(verse.verseKey);
    ref.read(jarShakeTriggerProvider.notifier).state++;
  }

  List<Verse> _getThisDayLastMonth(List<Verse> verses) {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, now.day);
    return verses.where((verse) {
      if (verse.savedAt == null) return false;
      final savedDate = verse.savedAt!;
      return savedDate.year == lastMonth.year &&
          savedDate.month == lastMonth.month &&
          savedDate.day == lastMonth.day;
    }).toList();
  }

  Verse? _getVerseOfTheWeek(List<Verse> verses) {
    if (verses.isEmpty) return null;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final thisWeekVerses = verses.where((verse) {
      if (verse.savedAt == null) return false;
      return verse.savedAt!.isAfter(weekAgo);
    }).toList();
    if (thisWeekVerses.isEmpty) return null;
    return thisWeekVerses.first;
  }

  List<Verse> _getSortedVerses(List<Verse> verses) {
    final sorted = List<Verse>.from(verses);
    switch (_currentSort) {
      case SortOption.newest:
        sorted.sort((a, b) {
          if (a.savedAt == null || b.savedAt == null) return 0;
          return b.savedAt!.compareTo(a.savedAt!);
        });
      case SortOption.oldest:
        sorted.sort((a, b) {
          if (a.savedAt == null || b.savedAt == null) return 0;
          return a.savedAt!.compareTo(b.savedAt!);
        });
      case SortOption.surah:
        sorted.sort((a, b) => a.surahNumber.compareTo(b.surahNumber));
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final archiveState = ref.watch(archiveNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.midnightBlue : AppColors.cream;
    final primaryColor = isDark
        ? AppColors.midnightPeriwinkle
        : AppColors.sageGreen;
    final searchFillColor = isDark
        ? AppColors.darkElevated
        : AppColors.softSand;
    final errorColor = AppColors.error;

    final sortedVerses = _getSortedVerses(archiveState.savedVerses);
    final thisDayLastMonth = _getThisDayLastMonth(archiveState.savedVerses);
    final verseOfTheWeek = _getVerseOfTheWeek(archiveState.savedVerses);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'My Archive',
                      style: AppTextStyles.loraTitleForTheme(context),
                      maxLines: 1,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showTranslationPicker(),
                    icon: Icon(Icons.translate_outlined, color: primaryColor),
                  ),
                  PopupMenuButton<SortOption>(
                    icon: Icon(Icons.sort, color: primaryColor),
                    onSelected: (option) =>
                        setState(() => _currentSort = option),
                    itemBuilder: (context) => SortOption.values.map((option) {
                      return PopupMenuItem(
                        value: option,
                        child: Row(
                          children: [
                            if (option == _currentSort)
                              Icon(Icons.check, size: 18, color: primaryColor),
                            if (option == _currentSort)
                              const SizedBox(width: 8),
                            Text(option.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  if (archiveState.savedVerses.isNotEmpty)
                    IconButton(
                      onPressed: () => _showClearDialog(archiveState),
                      icon: Icon(Icons.delete_outline, color: errorColor),
                    ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search verses...',
                  hintStyle: AppTextStyles.loraBodySmallForTheme(context),
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: primaryColor),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: searchFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: _buildContent(
                archiveState,
                sortedVerses,
                thisDayLastMonth,
                verseOfTheWeek,
                primaryColor,
                errorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    ArchiveState state,
    List<Verse> sortedVerses,
    List<Verse> thisDayLastMonth,
    Verse? verseOfTheWeek,
    Color primaryColor,
    Color errorColor,
  ) {
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: errorColor, size: 48),
              const SizedBox(height: 16),
              Text(state.errorMessage!, style: AppTextStyles.loraBodyMediumForTheme(context)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(archiveNotifierProvider.notifier).clearError();
                  ref.read(archiveNotifierProvider.notifier).loadSavedVerses();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.savedVerses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border_outlined,
              color: primaryColor.withValues(alpha: 0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text('No saved verses yet', style: AppTextStyles.loraHeadingForTheme(context)),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon on a verse to save it here',
              style: AppTextStyles.loraBodySmallForTheme(context),
            ),
          ],
        ),
      );
    }

    // Build items list
    final List<Widget> headerItems = [];

    if (thisDayLastMonth.isNotEmpty) {
      headerItems.add(
        _SectionHeader(
          title: 'This Day Last Month',
          icon: Icons.calendar_month,
          color: primaryColor,
        ),
      );
      for (final verse in thisDayLastMonth) {
        headerItems.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: VerseCardWidget(
              verse: verse,
              onSaveToggle: () => _deleteVerse(verse),
            ),
          ),
        );
      }
      headerItems.add(const SizedBox(height: 16));
    }

    if (verseOfTheWeek != null) {
      headerItems.add(
        _SectionHeader(
          title: 'Verse of the Week',
          icon: Icons.star,
          color: AppColors.mutedGold,
        ),
      );
      headerItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: VerseCardWidget(
            verse: verseOfTheWeek,
            onSaveToggle: () => _deleteVerse(verseOfTheWeek),
          ),
        ),
      );
      headerItems.add(const SizedBox(height: 16));
    }

    // Insert Native Ad after highlights but before all verses
    if (state.savedVerses.isNotEmpty) {
      headerItems.add(const NativeAdWidget());
      headerItems.add(const SizedBox(height: 16));
    }

    if (sortedVerses.isNotEmpty) {
      headerItems.add(
        _SectionHeader(
          title: 'All Saved Verses',
          icon: Icons.bookmark,
          color: primaryColor,
        ),
      );
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () =>
          ref.read(archiveNotifierProvider.notifier).loadSavedVerses(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: headerItems.length + sortedVerses.length,
        cacheExtent: 500,
        itemBuilder: (context, index) {
          if (index < headerItems.length) {
            return headerItems[index];
          }

          final verseIndex = index - headerItems.length;
          final verse = sortedVerses[verseIndex];

          return RepaintBoundary(
            child: Dismissible(
              key: Key(verse.verseKey),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                HapticFeedback.mediumImpact();
                _deleteVerse(verse);
              },
              background: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: errorColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: Icon(Icons.delete_outline, color: errorColor),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: VerseCardWidget(
                  verse: verse,
                  onSaveToggle: () => _deleteVerse(verse),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showClearDialog(ArchiveState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkCard : AppColors.softSand;
    final primaryColor = isDark
        ? AppColors.midnightPeriwinkle
        : AppColors.sageGreen;
    final errorColor = AppColors.error;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        title: Text('Clear Archive', style: AppTextStyles.loraHeadingForTheme(context)),
        content: Text(
          'Remove all ${state.savedVerses.length} saved verses from your archive?',
          style: AppTextStyles.loraBodyMediumForTheme(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: primaryColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(archiveNotifierProvider.notifier).clearArchive();
            },
            child: Text('Clear All', style: TextStyle(color: errorColor)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.loraBodyMediumForTheme(context).copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
