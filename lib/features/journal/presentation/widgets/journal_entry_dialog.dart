import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';
import 'package:quran_jarr/features/journal/domain/entities/journal_entry.dart';
import 'package:quran_jarr/features/journal/presentation/providers/journal_provider.dart';
import 'package:quran_jarr/features/journal/presentation/widgets/mood_selector.dart';

class JournalEntryDialog extends ConsumerStatefulWidget {
  final Verse verse;

  const JournalEntryDialog({super.key, required this.verse});

  @override
  ConsumerState<JournalEntryDialog> createState() =>
      _JournalEntryDialogState();
}

class _JournalEntryDialogState extends ConsumerState<JournalEntryDialog> {
  Mood? _selectedMood;
  final _noteController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final verse = widget.verse;
    final entry = JournalEntry(
      id: '${verse.verseKey}_${DateTime.now().millisecondsSinceEpoch}',
      verseKey: verse.verseKey,
      arabicText: verse.arabicText,
      translation: verse.translation,
      surahReference: verse.surahReference,
      mood: _selectedMood,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      createdAt: DateTime.now(),
    );
    await ref.read(journalNotifierProvider.notifier).saveEntry(entry);
    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved to Journal ✨'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.midnightPeriwinkle : AppColors.sageGreen;
    final bgColor = isDark ? AppColors.darkCard : AppColors.cream;

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.auto_stories, color: primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Journal Entry',
                  style: AppTextStyles.loraHeadingForTheme(context),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    widget.verse.arabicText,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.verse.surahReference,
                    style: AppTextStyles.loraCaptionForTheme(context)
                        .copyWith(color: primaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            MoodSelector(
              selectedMood: _selectedMood,
              onMoodSelected: (mood) =>
                  setState(() => _selectedMood = mood),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 4,
              maxLength: 1000,
              decoration: InputDecoration(
                hintText: 'Write your reflection...',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkElevated
                    : AppColors.softSand,
                counterStyle: TextStyle(
                  color: primaryColor.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Reflection'),
            ),
          ],
        ),
      ),
    );
  }
}
