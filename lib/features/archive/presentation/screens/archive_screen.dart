import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/features/archive/presentation/providers/archive_provider.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';
import 'package:quran_jarr/features/jar/presentation/widgets/verse_card_widget.dart';

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

  void _deleteVerse(Verse verse) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.softSand,
        title: Text(
          'Remove Verse',
          style: AppTextStyles.loraHeading,
        ),
        content: Text(
          'Remove this verse from your archive?',
          style: AppTextStyles.loraBodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.loraBodyMedium
                  .copyWith(color: AppColors.sageGreen),
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
              style: AppTextStyles.loraBodyMedium
                  .copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final archiveState = ref.watch(archiveNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
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
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.sageGreen,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'My Archive',
                      style: AppTextStyles.loraTitle,
                    ),
                  ),
                  // Clear all button
                  if (archiveState.savedVerses.isNotEmpty)
                    IconButton(
                      onPressed: () => _showClearDialog(archiveState),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
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
                  hintStyle: AppTextStyles.loraBodySmall,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.sageGreen,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.sageGreen,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.softSand,
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
                    borderSide: const BorderSide(color: AppColors.sageGreen),
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
                    style: AppTextStyles.loraBodySmall,
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
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.sageGreen),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: AppTextStyles.loraBodyMedium,
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
              color: AppColors.sageGreen.withOpacity(0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No saved verses yet',
              style: AppTextStyles.loraHeading,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon on a verse to save it here',
              style: AppTextStyles.loraBodySmall,
            ),
          ],
        ),
      ).animate().fade();
    }

    return RefreshIndicator(
      color: AppColors.sageGreen,
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
                color: AppColors.error.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.softSand,
        title: Text(
          'Clear Archive',
          style: AppTextStyles.loraHeading,
        ),
        content: Text(
          'Remove all ${state.savedVerses.length} saved verses from your archive?',
          style: AppTextStyles.loraBodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.loraBodyMedium
                  .copyWith(color: AppColors.sageGreen),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(archiveNotifierProvider.notifier).clearArchive();
            },
            child: Text(
              'Clear All',
              style: AppTextStyles.loraBodyMedium
                  .copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
