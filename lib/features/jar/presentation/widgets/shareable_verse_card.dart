import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';

/// Shareable Verse Card Widget
/// A beautiful card designed for sharing verses on social media
class ShareableVerseCard extends StatelessWidget {
  final Verse verse;

  const ShareableVerseCard({
    super.key,
    required this.verse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      height: 1920,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cream,
            AppColors.softSand.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            top: 100,
            left: 50,
            child: _buildPattern(0.1),
          ),
          Positioned(
            top: 500,
            right: -50,
            child: _buildPattern(0.08),
          ),
          Positioned(
            bottom: 200,
            left: -30,
            child: _buildPattern(0.06),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Bismillah
                Text(
                  'بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                  style: GoogleFonts.amiri(
                    fontSize: 36,
                    color: AppColors.sageGreen.withValues(alpha: 0.7),
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 60),

                // Decorative line
                Container(
                  width: 200,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.sageGreen,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Arabic verse
                Text(
                  verse.arabicText,
                  style: GoogleFonts.amiri(
                    fontSize: 68,
                    color: AppColors.deepUmber,
                    height: 2.2,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: ui.TextDirection.rtl,
                ),

                const SizedBox(height: 80),

                // Translation
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                  decoration: BoxDecoration(
                    color: AppColors.sageGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.sageGreen.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '"${verse.translation}"',
                    style: AppTextStyles.loraBodyLarge().copyWith(
                      color: AppColors.deepUmber,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                      fontSize: 42,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 80),

                // Surah reference
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        verse.arabicSurahName,
                        style: AppTextStyles.loraHeading().copyWith(
                          color: AppColors.terracotta,
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        width: 2,
                        height: 30,
                        color: AppColors.terracotta.withValues(alpha: 0.3),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        '${verse.surahNumber}:${verse.ayahNumber}',
                        style: AppTextStyles.loraHeading().copyWith(
                          color: AppColors.terracotta,
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // Footer with app name
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
                  decoration: BoxDecoration(
                    color: AppColors.sageGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.cream,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Quran Jarr',
                        style: AppTextStyles.loraBodyMedium().copyWith(
                          color: AppColors.cream,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPattern(double opacity) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.sageGreen.withValues(alpha: opacity),
      ),
    );
  }
}
