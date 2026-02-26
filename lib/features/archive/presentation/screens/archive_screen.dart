import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/features/archive/presentation/providers/archive_provider.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';
import 'package:quran_jarr/features/jar/presentation/widgets/verse_card_widget.dart';
import 'package:quran_jarr/features/jar/presentation/widgets/translation_picker_widget.dart';

/// Archive Screen
/// Displays all saved/favorite verses
class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  final TextEditingController _searchController = TextEditingController();

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
        return ref.read(archiveNotifierProvider.notifier).reloadVersesWithTranslation(translationId);
      },
    );
  }

  void _deleteVerse(Verse verse) {
    final bgColor = AppColors.softSand;
    final primaryColor = AppColors.sageGreen;
    final errorColor = AppColors.error;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        title: Text(
          'Remove Verse',
          style: AppTextStyles.loraHeading(),
        ),
        content: Text(
          'Remove this verse from your archive?',
          style: AppTextStyles.loraBodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.loraBodyMedium()
                  .copyWith(color: primaryColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(archiveNotifierProvider.notifier)
                  .deleteVerse(verse.verseKey);
            },
            child: Text(
              'Remove',
              style: AppTextStyles.loraBodyMedium()
                  .copyWith(color: errorColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final archiveState = ref.watch(archiveNotifierProvider);
    final bgColor = AppColors.cream;
    final primaryColor = AppColors.sageGreen;
    final searchFillColor = AppColors.softSand;
    final errorColor = AppColors.error;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: primaryColor,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'My Archive',
                      style: AppTextStyles.loraTitle(),
                    ),
                  ),
                  // Translation button
                  IconButton(
                    onPressed: () => _showTranslationPicker(),
                    icon: Icon(
                      Icons.translate_outlined,
                      color: primaryColor,
                    ),
                    tooltip: 'Change translation',
                  ),
                  // Clear all button
                  if (archiveState.savedVerses.isNotEmpty)
                    IconButton(
                      onPressed: () => _showClearDialog(archiveState),
                      icon: Icon(
                        Icons.delete_outline,
                        color: errorColor,
                      ),
                      tooltip: 'Clear all',
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
                  hintStyle: AppTextStyles.loraBodySmall(),
                  prefixIcon: Icon(
                    Icons.search,
                    color: primaryColor,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: primaryColor,
                          ),
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
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
            ),

            // Verse Count
            if (archiveState.savedVerses.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${archiveState.savedVerses.length} verse${archiveState.savedVerses.length != 1 ? 's' : ''} saved',
                    style: AppTextStyles.loraBodySmall(),
                  ),
                ),
              ),

            // Content
            Expanded(
              child: _buildContent(archiveState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ArchiveState state) {
    final primaryColor = AppColors.sageGreen;
    final errorColor = AppColors.error;

    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: errorColor,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: AppTextStyles.loraBodyMedium(),
                textAlign: TextAlign.center,
              ),
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
            Text(
              'No saved verses yet',
              style: AppTextStyles.loraHeading(),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon on a verse to save it here',
              style: AppTextStyles.loraBodySmall(),
            ),
          ],
        ),
      ).animate().fade();
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () =>
          ref.read(archiveNotifierProvider.notifier).loadSavedVerses(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: state.savedVerses.length,
        itemBuilder: (context, index) {
          final verse = state.savedVerses[index];
          return Dismissible(
            key: Key(verse.verseKey),
            direction: DismissDirection.endToStart,
            onDismissed: (_) {
              ref
                  .read(archiveNotifierProvider.notifier)
                  .deleteVerse(verse.verseKey);
            },
            background: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: Icon(
                Icons.delete_outline,
                color: errorColor,
              ),
            ),
            child: VerseCardWidget(
              verse: verse,
              onSaveToggle: () {
                _deleteVerse(verse);
              },
            ),
          ).animate().fade(delay: (index * 50).ms).slideX(begin: 0.1);
        },
      ),
    );
  }

  void _showClearDialog(ArchiveState state) {
    final bgColor = AppColors.softSand;
    final primaryColor = AppColors.sageGreen;
    final errorColor = AppColors.error;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        title: Text(
          'Clear Archive',
          style: AppTextStyles.loraHeading(),
        ),
        content: Text(
          'Remove all ${state.savedVerses.length} saved verses from your archive?',
          style: AppTextStyles.loraBodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.loraBodyMedium()
                  .copyWith(color: primaryColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(archiveNotifierProvider.notifier).clearArchive();
            },
            child: Text(
              'Clear All',
              style: AppTextStyles.loraBodyMedium()
                  .copyWith(color: errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
