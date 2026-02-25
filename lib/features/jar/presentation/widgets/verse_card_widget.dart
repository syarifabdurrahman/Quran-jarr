import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/providers/preferences_provider.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/features/audio/presentation/widgets/audio_player_widget.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';
import 'package:quran_jarr/features/jar/presentation/providers/jar_provider.dart';

/// Verse Card Widget
/// Displays a Quranic verse with Arabic text and translation
class VerseCardWidget extends ConsumerStatefulWidget {
  final Verse verse;
  final VoidCallback? onSaveToggle;
  final VoidCallback? onShare;

  const VerseCardWidget({
    super.key,
    required this.verse,
    this.onSaveToggle,
    this.onShare,
  });

  @override
  ConsumerState<VerseCardWidget> createState() => _VerseCardWidgetState();
}

class _VerseCardWidgetState extends ConsumerState<VerseCardWidget> {
  bool _isLoadingTafsir = false;

  @override
  Widget build(BuildContext context) {
    final verse = widget.verse;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSoftSand : AppColors.softSand;
    final primaryColor = isDark ? AppColors.darkSageGreen : AppColors.sageGreen;
    final terracottaColor = isDark ? AppColors.darkTerracotta : AppColors.terracotta;
    final glassBorder = isDark
        ? AppColors.darkGlassBorder
        : AppColors.glassBorder;

    // Font size multipliers
    final arabicFontMultiplier = ref.watch(arabicFontSizeProvider);
    final englishFontMultiplier = ref.watch(englishFontSizeProvider);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: glassBorder.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Surah name and actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Surah reference
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  verse.surahReference,
                  style: AppTextStyles.surahName(arabicFontMultiplier),
                ),
              ),
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.onSaveToggle != null)
                    IconButton(
                      onPressed: widget.onSaveToggle,
                      icon: Icon(
                        verse.isSaved
                            ? Icons.bookmark
                            : Icons.bookmark_border_outlined,
                        color: verse.isSaved
                            ? terracottaColor
                            : primaryColor,
                      ),
                    ),
                  if (widget.onShare != null)
                    IconButton(
                      onPressed: widget.onShare,
                      icon: Icon(
                        Icons.share_outlined,
                        color: primaryColor,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Arabic verse
          Text(
            verse.arabicText,
            style: AppTextStyles.amiriVerseLarge(arabicFontMultiplier),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 20),
          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  glassBorder.withValues(alpha: 0),
                  glassBorder,
                  glassBorder.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Translation
          Text(
            verse.translation,
            style: AppTextStyles.loraBodyLarge(englishFontMultiplier),
            textAlign: TextAlign.center,
          ),
          // Audio player (if available)
          if (verse.hasAudio) ...[
            const SizedBox(height: 16),
            AudioPlayerWidget(audioUrl: verse.audioUrl!),
          ],
          // Tafsir button at bottom
          const SizedBox(height: 16),
          // Tafsir button
          InkWell(
            onTap: _isLoadingTafsir
                ? null
                : () => _handleTafsirPress(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: _isLoadingTafsir
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          verse.hasTafsir
                              ? Icons.menu_book
                              : Icons.menu_book_outlined,
                          size: 18,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          verse.hasTafsir
                              ? 'View Tafsir (Ibn Kathir)'
                              : 'Load Tafsir',
                          style: AppTextStyles.loraBodyMedium(englishFontMultiplier).copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleTafsirPress(BuildContext context) async {
    final verse = widget.verse;

    if (!verse.hasTafsir) {
      // Load tafsir first
      setState(() => _isLoadingTafsir = true);
      await ref.read(jarNotifierProvider.notifier).loadTafsir();
      setState(() => _isLoadingTafsir = false);
    }

    // Show tafsir sheet (after loading or if already loaded)
    if (mounted) {
      _showTafsirSheet(context);
    }
  }

  void _showTafsirSheet(BuildContext context) {
    // Get the latest verse from state (in case tafsir was just loaded)
    final jarState = ref.watch(jarNotifierProvider);
    final verse = jarState.currentVerse;

    if (verse == null || !verse.hasTafsir) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSoftSand : AppColors.softSand;
    final primaryColor = isDark ? AppColors.darkSageGreen : AppColors.sageGreen;
    final glassBorder = isDark
        ? AppColors.darkGlassBorder
        : AppColors.glassBorder;
    final tafsirTextColor = isDark ? AppColors.darkTextPrimary : AppColors.deepUmber;

    // Font size multipliers
    final englishFontMultiplier = ref.read(englishFontSizeProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: glassBorder.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.menu_book,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tafsir Ibn Kathir',
                      style: AppTextStyles.loraTitle(englishFontMultiplier),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: glassBorder.withValues(alpha: 0.3),
              ),
            ),
            // Tafsir content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Text(
                  verse.tafsir!,
                  style: AppTextStyles.loraBodyMedium(englishFontMultiplier).copyWith(
                    color: tafsirTextColor,
                    height: 1.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
