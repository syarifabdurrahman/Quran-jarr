import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';

/// Shareable Verse Card Widget
/// A beautiful card designed for sharing verses on social media.
/// Optimized for various verse lengths using dynamic scaling and FittedBox.
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
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 100),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Bismillah
                  Text(
                    'بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                    style: GoogleFonts.amiri(
                      fontSize: 32,
                      color: AppColors.sageGreen.withValues(alpha: 0.7),
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Decorative line
                  Container(
                    width: 180,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.sageGreen.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Scrollable/Scalable Verse Content
                  Container(
                    constraints: const BoxConstraints(maxHeight: 1200),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        width: 920, // Base width for layout calculation
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Arabic verse
                            Text(
                              verse.arabicText,
                              style: GoogleFonts.amiri(
                                fontSize: verse.arabicText.length > 200 ? 56 : 68,
                                color: AppColors.deepUmber,
                                height: 1.8,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                              textDirection: ui.TextDirection.rtl,
                            ),

                            const SizedBox(height: 60),

                            // Translation
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                              decoration: BoxDecoration(
                                color: AppColors.sageGreen.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: AppColors.sageGreen.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                '"${verse.translation}"',
                                style: GoogleFonts.lora(
                                  color: AppColors.deepUmber,
                                  height: 1.5,
                                  fontStyle: FontStyle.italic,
                                  fontSize: verse.translation.length > 300 ? 32 : 38,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Surah reference
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: AppColors.terracotta.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          verse.arabicSurahName,
                          style: GoogleFonts.lora(
                            color: AppColors.terracotta,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Container(
                          width: 1.5,
                          height: 25,
                          color: AppColors.terracotta.withValues(alpha: 0.2),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          '${verse.surahNumber}:${verse.ayahNumber}',
                          style: GoogleFonts.lora(
                            color: AppColors.terracotta,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),

                  // Footer with app name
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.sageGreen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.cream,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Quran Jarr',
                          style: GoogleFonts.lora(
                            color: AppColors.cream,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            fontSize: 24,
                          ),
                        ),
                      ],
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
