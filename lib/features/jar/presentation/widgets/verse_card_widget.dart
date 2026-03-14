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
    final cardColor = AppColors.softSand;
    final primaryColor = AppColors.sageGreen;
    final terracottaColor = AppColors.terracotta;
    final glassBorder = AppColors.glassBorder;

    // Font size multipliers
    final arabicFontMultiplier = ref.watch(arabicFontSizeProvider);
    final englishFontMultiplier = ref.watch(englishFontSizeProvider);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(20),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Surah name and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Surah reference
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        verse.surahReference,
                        style: AppTextStyles.surahName(arabicFontMultiplier),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        ),
                      if (widget.onShare != null)
                        IconButton(
                          onPressed: widget.onShare,
                          icon: Icon(
                            Icons.share_outlined,
                            color: primaryColor,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Arabic verse
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  verse.arabicText,
                  style: AppTextStyles.amiriVerseLarge(arabicFontMultiplier),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  maxLines: 10,
                ),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              // Translation
              Text(
                verse.currentTranslation ?? verse.translation,
                style: AppTextStyles.loraBodyLarge(englishFontMultiplier),
                textAlign: TextAlign.center,
                maxLines: 15,
                overflow: TextOverflow.ellipsis,
              ),
              // Audio player (if available)
              if (verse.hasAudio) ...[
                const SizedBox(height: 16),
                AudioPlayerWidget(
                  audioUrl: verse.audioUrl!,
                  verseKey: verse.verseKey,
                ),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              verse.hasTafsir
                                  ? Icons.menu_book
                                  : Icons.menu_book_outlined,
                              size: 18,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                verse.hasTafsir
                                    ? 'View Tafsir (Ibn Kathir)'
                                    : 'Load Tafsir',
                                style: AppTextStyles.loraBodyMedium(englishFontMultiplier).copyWith(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleTafsirPress(BuildContext context) async {
    final verse = widget.verse;

    // Check if verse has tafsir for current translation
    final hasTafsirForCurrentTranslation = verse.tafsirByTranslation != null &&
        verse.tafsirByTranslation!.containsKey(verse.translationId);

    if (!hasTafsirForCurrentTranslation) {
      // Only try to load from API if we don't have tafsir locally
      setState(() => _isLoadingTafsir = true);
      try {
        await ref.read(jarNotifierProvider.notifier).loadTafsir();
      } catch (e) {
        // If loading fails (e.g., offline), check if we have any other tafsir
        // Silently handle error - will show tafsir if available locally
      }
      setState(() => _isLoadingTafsir = false);
    }

    // Show tafsir sheet (after loading or if already loaded)
    if (mounted) {
      _showTafsirSheet(context);
    }
  }

  void _showTafsirSheet(BuildContext context) {
    // Use the verse from widget directly (supports archive verses)
    final verse = widget.verse;

    // Check if verse has tafsir for any translation
    if (verse.tafsirByTranslation == null || verse.tafsirByTranslation!.isEmpty) {
      // No tafsir available at all
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tafsir not available. Please connect to internet and try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Get tafsir for current translation
    final tafsirText = verse.getTafsirForTranslation(verse.translationId);

    if (tafsirText == null || tafsirText.isEmpty) {
      // Tafsir not available for current translation, but available for others
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tafsir not available for ${verse.translationId} translation. Available for: ${verse.tafsirByTranslation!.keys.join(", ")}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    final cardColor = AppColors.softSand;
    final primaryColor = AppColors.sageGreen;
    final glassBorder = AppColors.glassBorder;
    final tafsirTextColor = AppColors.deepUmber;

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
                  tafsirText,
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
