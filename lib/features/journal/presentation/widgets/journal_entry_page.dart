import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';
import 'package:quran_jarr/features/journal/domain/entities/journal_entry.dart';
import 'package:quran_jarr/features/journal/presentation/providers/journal_provider.dart';
import 'package:quran_jarr/features/journal/presentation/widgets/mood_selector.dart';

/// Immersive full-screen journal entry page
class JournalEntryPage extends ConsumerStatefulWidget {
  final Verse verse;

  const JournalEntryPage({super.key, required this.verse});

  @override
  ConsumerState<JournalEntryPage> createState() => _JournalEntryPageState();
}

class _JournalEntryPageState extends ConsumerState<JournalEntryPage> {
  Mood? _selectedMood;
  final _noteController = TextEditingController();
  bool _isSaving = false;
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _noteController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    // Scroll once quickly after keyboard starts to open
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      _scroll();
      // Scroll again after keyboard animation finishes and layout settles
      Future.delayed(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        _scroll();
      });
    });
  }

  void _scroll() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
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
    final bgColor = isDark ? AppColors.midnightBlue : AppColors.cream;

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: primaryColor),
        ),
        title: Row(
          children: [
            Icon(Icons.auto_stories_outlined, color: primaryColor, size: 22),
            const SizedBox(width: 10),
            Text(
              'Journal Entry',
              style: AppTextStyles.loraHeadingForTheme(context).copyWith(
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.check, color: primaryColor),
              label: Text(
                'Save',
                style: TextStyle(color: primaryColor),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Verse reference card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.verse.surahReference,
                          style: AppTextStyles.loraBodySmallForTheme(context)
                              .copyWith(color: primaryColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.verse.arabicText,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Mood selector
            MoodSelector(
              selectedMood: _selectedMood,
              onMoodSelected: (mood) =>
                  setState(() => _selectedMood = mood),
            ),
            const SizedBox(height: 16),
            // Reflection text area
            TextField(
              controller: _noteController,
              focusNode: _focusNode,
              maxLines: null,
              minLines: 8,
              onTap: _scrollToBottom,
              textAlignVertical: TextAlignVertical.top,
              maxLength: 2000,
              textInputAction: TextInputAction.newline,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Write your reflection...',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.textSecondary,
                  fontSize: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkElevated
                    : AppColors.softSand,
                contentPadding: const EdgeInsets.all(16),
                counterStyle: TextStyle(
                  color: primaryColor.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
                alignLabelWithHint: true,
              ),
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.deepUmber,
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
