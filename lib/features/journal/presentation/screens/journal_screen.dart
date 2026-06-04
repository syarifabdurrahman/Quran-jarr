import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/features/journal/domain/entities/journal_entry.dart';
import 'package:quran_jarr/features/journal/presentation/providers/journal_provider.dart';
import 'package:quran_jarr/features/journal/presentation/widgets/journal_card.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(journalNotifierProvider.notifier).loadEntries();
    });
  }

  void _showDeleteConfirm(JournalEntry entry) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Entry'),
        content: const Text('Remove this journal entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(journalNotifierProvider.notifier).deleteEntry(entry.id);
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final journalState = ref.watch(journalNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.midnightPeriwinkle : AppColors.sageGreen;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          if (journalState.entries.isNotEmpty)
            IconButton(
              onPressed: () =>
                  ref.read(journalNotifierProvider.notifier).exportBackup(),
              icon: Icon(Icons.backup, color: primaryColor),
              tooltip: 'Backup Journal',
            ),
        ],
      ),
      body: journalState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : journalState.entries.isEmpty
              ? _buildEmptyState(context)
              : _buildJournalList(context, journalState),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.midnightPeriwinkle : AppColors.sageGreen;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 80,
              color: primaryColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Reflection Journal',
              style: AppTextStyles.loraHeadingForTheme(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'After reading a verse, save it with your thoughts and mood.\nTap the journal icon on any verse to start.',
              style: AppTextStyles.loraBodyMediumForTheme(context).copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalList(BuildContext context, JournalState journalState) {
    return RefreshIndicator(
      onRefresh: () => ref.read(journalNotifierProvider.notifier).loadEntries(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: journalState.entries.length,
        itemBuilder: (context, index) {
          final entry = journalState.entries[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: JournalCard(
              entry: entry,
              onTap: () => _showEntryDetail(context, entry),
              onDelete: () => _showDeleteConfirm(entry),
            ),
          );
        },
      ),
    );
  }

  void _showEntryDetail(BuildContext context, JournalEntry entry) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.midnightPeriwinkle : AppColors.sageGreen;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.cream,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (entry.mood != null) ...[
                          Text(entry.mood!.emoji,
                              style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            entry.surahReference,
                            style:
                                AppTextStyles.loraTitleForTheme(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            entry.arabicText,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            entry.translation,
                            textAlign: TextAlign.center,
                            style: AppTextStyles
                                .loraBodyMediumForTheme(context)
                                .copyWith(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                    if (entry.note != null &&
                        entry.note!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'My Reflection',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.note!,
                        style: AppTextStyles
                            .loraBodyMediumForTheme(context)
                            .copyWith(height: 1.6),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
