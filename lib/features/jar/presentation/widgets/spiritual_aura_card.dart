import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';

/// A premium, celestial-themed card designed for social media sharing
/// Optimized for various verse lengths using dynamic scaling and FittedBox.
class SpiritualAuraCard extends StatelessWidget {
  final Verse verse;
  final bool isDark;

  const SpiritualAuraCard({
    super.key,
    required this.verse,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    // Standard social media post size (1080x1350 for Instagram portrait)
    return Container(
      width: 1080,
      height: 1350,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0F172A), // Deep Night
                  const Color(0xFF1E293B),
                  const Color(0xFF0F172A),
                ]
              : [
                  const Color(0xFFF8FAFC), // Light Sky
                  const Color(0xFFE2E8F0),
                  const Color(0xFFF8FAFC),
                ],
        ),
      ),
      child: Stack(
        children: [
          // Background "Stars" or "Glow"
          ..._buildCelestialBackground(),

          // Main Content Area
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    constraints: const BoxConstraints(
                      maxHeight: 1050, // Ensures content doesn't hit the branding
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                        width: 2,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        width: 840, // Base width for layout calculation
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Surah Name & Verse Key
                            Text(
                              verse.surahReference.toUpperCase(),
                              style: GoogleFonts.lora(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 4,
                                color: isDark ? AppColors.midnightGold : AppColors.terracotta,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Arabic Text
                            Text(
                              verse.arabicText,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.amiri(
                                fontSize: verse.arabicText.length > 200 ? 48 : 58,
                                fontWeight: FontWeight.bold,
                                height: 1.6,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Divider
                            Container(
                              width: 80,
                              height: 1.5,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 40),

                            // Translation
                            Text(
                              verse.translation,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lora(
                                fontSize: verse.translation.length > 300 ? 24 : 28,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                                color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Branding at the bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'QURAN JARR',
                  style: GoogleFonts.lora(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A Daily Spiritual Companion',
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCelestialBackground() {
    return [
      // Large soft glows
      Positioned(
        top: -200,
        right: -200,
        child: _buildGlow(isDark ? AppColors.midnightPeriwinkle : AppColors.sageGreen, 600),
      ),
      Positioned(
        bottom: -200,
        left: -200,
        child: _buildGlow(isDark ? AppColors.midnightGold : AppColors.terracotta, 600),
      ),
      
      // Random "stars"
      ...List.generate(50, (index) {
        final double top = (index * 1350 / 50) + (index % 7 * 20);
        final double left = (index * 1080 / 50) + (index % 5 * 30);
        return Positioned(
          top: top % 1350,
          left: left % 1080,
          child: Container(
            width: 2 + (index % 3).toDouble(),
            height: 2 + (index % 3).toDouble(),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    ];
  }

  Widget _buildGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
