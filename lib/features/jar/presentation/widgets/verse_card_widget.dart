import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/providers/connectivity_provider.dart';
import 'package:quran_jarr/core/providers/preferences_provider.dart';
import 'package:quran_jarr/core/services/share_service.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/features/audio/presentation/widgets/audio_player_widget.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';
import 'package:quran_jarr/features/jar/presentation/providers/jar_provider.dart';
import 'package:quran_jarr/features/jar/presentation/widgets/spiritual_aura_card.dart';
import 'package:quran_jarr/features/journal/presentation/widgets/journal_entry_page.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoLoadTafsir());
  }

  void _autoLoadTafsir() {
    final verse = widget.verse;
    if (verse.tafsirByTranslation != null &&
        verse.tafsirByTranslation!.containsKey(verse.translationId)) {
      return;
    }
    final isConnected = ref.read(connectivityProvider);
    if (isConnected) {
      ref.read(jarNotifierProvider.notifier).loadTafsir();
    }
  }

  @override
  Widget build(BuildContext context) {
    final verse = widget.verse;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.softSand;
    final primaryColor = isDark
        ? AppColors.midnightPeriwinkle
        : AppColors.sageGreen;
    final terracottaColor = isDark
        ? AppColors.midnightGold
        : AppColors.terracotta;
    final glassBorder = isDark
        ? AppColors.midnightSlate
        : AppColors.glassBorder;

    // Font size multipliers
    final arabicFontMultiplier = ref.watch(arabicFontSizeProvider);
    final englishFontMultiplier = ref.watch(englishFontSizeProvider);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 12,
              sigmaY: 12,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.glassNight
                    : cardColor.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? AppColors.glassNightBorder
                      : glassBorder.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: AppColors.deepUmber.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            verse.surahReference,
                            style: AppTextStyles.surahNameForTheme(context, arabicFontMultiplier,),
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
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                            ),
                          IconButton(
                            onPressed: () => _handleJournalTap(context),
                            tooltip: 'Journal',
                            icon: Icon(
                              Icons.auto_stories_outlined,
                              color: primaryColor,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                          if (widget.onShare != null)
                            IconButton(
                              onPressed: widget.onShare,
                              tooltip: 'Share Text',
                              icon: Icon(
                                Icons.share_outlined,
                                color: primaryColor,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                            ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'aura') {
                                _handleAuraShare(context);
                              } else if (value == 'tafsir') {
                                _handleTafsirPress(context);
                              }
                            },
                            icon: Icon(
                              Icons.more_horiz_rounded,
                              color: primaryColor,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'aura',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      size: 20,
                                      color: isDark ? AppColors.midnightGold : AppColors.terracotta,
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Spiritual Aura'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'tafsir',
                                child: Row(
                                  children: [
                                    Icon(
                                      verse.hasTafsir
                                          ? Icons.menu_book
                                          : Icons.menu_book_outlined,
                                      size: 20,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      verse.hasTafsir
                                          ? 'View Tafsir'
                                          : 'Load Tafsir',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Arabic verse
                  Text(
                    verse.arabicText,
                    style: AppTextStyles.amiriVerseLargeForTheme(
                      context,
                      arabicFontMultiplier,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
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
                    style: AppTextStyles.loraBodyLargeForTheme(
                      context,
                      englishFontMultiplier,
                    ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleJournalTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => JournalEntryPage(verse: widget.verse),
      ),
    );
  }

  Future<void> _handleAuraShare(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final verse = widget.verse;
    
    // Show a loading indicator while capturing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating Spiritual Aura...'),
        duration: Duration(seconds: 2),
      ),
    );

    final auraCard = SpiritualAuraCard(
      verse: verse,
      isDark: isDark,
    );

    await ShareService.instance.shareWidgetAsImage(
      auraCard,
      fileName: 'spiritual_aura_${verse.verseKey.replaceAll(':', '_')}',
    );
  }

  Future<void> _handleTafsirPress(BuildContext context) async {
    final verse = widget.verse;

    // Check if verse has tafsir for current translation
    final hasTafsirForCurrentTranslation =
        verse.tafsirByTranslation != null &&
        verse.tafsirByTranslation!.containsKey(verse.translationId);

    if (!hasTafsirForCurrentTranslation) {
      // Only try to load from API if we don't have tafsir locally
      
      // Verify connection before trying to load tafsir
      await ref.read(connectivityProvider.notifier).verifyConnection();
      final isConnected = ref.read(connectivityProvider);
      
      if (isConnected) {
        try {
          await ref.read(jarNotifierProvider.notifier).loadTafsir();
        } catch (e) {
          // If loading fails, silently handle - will show message if no tafsir available
        }
      }
    }

    // Show tafsir sheet (after loading or if already loaded)
    if (context.mounted) {
      _showTafsirSheet(context);
    }
  }

  void _showTafsirSheet(BuildContext context) {
    final verse = widget.verse;

    if (verse.tafsirByTranslation == null ||
        verse.tafsirByTranslation!.isEmpty) {
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

    final tafsirText = verse.getTafsirForTranslation(verse.translationId);

    if (tafsirText == null || tafsirText.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tafsir not available for ${verse.translationId} translation. Available for: ${verse.tafsirByTranslation!.keys.join(", ")}',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.softSand;
    final primaryColor = isDark
        ? AppColors.midnightPeriwinkle
        : AppColors.sageGreen;
    final glassBorder = isDark
        ? AppColors.midnightSlate
        : AppColors.glassBorder;
    final tafsirTextColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.deepUmber;

    final englishFontMultiplier = ref.read(englishFontSizeProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: glassBorder.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.menu_book, color: primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tafsir Ibn Kathir',
                          style: AppTextStyles.loraTitleForTheme(context, englishFontMultiplier),
                        ),
                        Text(
                          verse.surahReference,
                          style: AppTextStyles.loraCaptionForTheme(context).copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: primaryColor),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: glassBorder.withValues(alpha: 0.3),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Text(
                  tafsirText,
                  style: AppTextStyles.loraBodyMediumForTheme(context, englishFontMultiplier).copyWith(
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
