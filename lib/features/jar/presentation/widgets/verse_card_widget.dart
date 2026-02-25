import 'package:flutter/material.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';

/// Verse Card Widget
/// Displays a Quranic verse with Arabic text and translation
class VerseCardWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.softSand,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.glassBorder.withOpacity(0.1),
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
                  color: AppColors.sageGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  verse.surahReference,
                  style: AppTextStyles.surahName,
                ),
              ),
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onSaveToggle != null)
                    IconButton(
                      onPressed: onSaveToggle,
                      icon: Icon(
                        verse.isSaved
                            ? Icons.bookmark
                            : Icons.bookmark_border_outlined,
                        color: verse.isSaved
                            ? AppColors.terracotta
                            : AppColors.sageGreen,
                      ),
                    ),
                  if (onShare != null)
                    IconButton(
                      onPressed: onShare,
                      icon: const Icon(
                        Icons.share_outlined,
                        color: AppColors.sageGreen,
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
            style: AppTextStyles.amiriVerseLarge,
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
                  AppColors.glassBorder.withOpacity(0),
                  AppColors.glassBorder,
                  AppColors.glassBorder.withOpacity(0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Translation
          Text(
            verse.translation,
            style: AppTextStyles.loraBodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
