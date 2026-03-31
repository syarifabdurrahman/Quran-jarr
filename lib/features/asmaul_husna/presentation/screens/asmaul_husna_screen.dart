import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/core/providers/locale_provider.dart';
import 'package:quran_jarr/features/asmaul_husna/data/asmaul_husna_data.dart';

/// Asmaul Husna Screen
/// Displays 99 Names of Allah with beautiful card stack UI
class AsmaulHusnaScreen extends ConsumerStatefulWidget {
  const AsmaulHusnaScreen({super.key});

  @override
  ConsumerState<AsmaulHusnaScreen> createState() => _AsmaulHusnaScreenState();
}

class _AsmaulHusnaScreenState extends ConsumerState<AsmaulHusnaScreen> {
  int _currentIndex = 0;

  void _nextCard() {
    if (_currentIndex < asmaulHusnaList.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.midnightBlue : AppColors.cream;
    final primaryColor = isDark
        ? AppColors.midnightPeriwinkle
        : AppColors.sageGreen;
    final currentLocale = ref.watch(localeNotifierProvider);
    final isIndonesian = currentLocale.languageCode == 'id';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text('Asmaul Husna', style: AppTextStyles.loraHeading()),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Navigation info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${_currentIndex + 1} / ${asmaulHusnaList.length}',
              style: AppTextStyles.loraBodySmall().copyWith(
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Row for Prev, Card Stack, Next
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Prev Button
              IconButton(
                onPressed: _currentIndex > 0 ? _prevCard : null,
                icon: const Icon(Icons.arrow_back_ios_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                  foregroundColor: primaryColor,
                  elevation: 2,
                  padding: const EdgeInsets.all(16),
                ),
              ),

              // Card Stack Area
              SizedBox(
                height: 350,
                width: 220,
                child: _buildCardStack(isDark, primaryColor, isIndonesian),
              ),

              // Next Button
              IconButton(
                onPressed: _currentIndex < asmaulHusnaList.length - 1
                    ? _nextCard
                    : null,
                icon: const Icon(Icons.arrow_forward_ios_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                  foregroundColor: primaryColor,
                  elevation: 2,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Swipe hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.swipe_rounded,
                color: primaryColor.withValues(alpha: 0.5),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tap a card to bring it forward',
                style: AppTextStyles.loraBodySmall().copyWith(
                  color: primaryColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardStack(bool isDark, Color primaryColor, bool isIndonesian) {
    // Render only nearby cards for performance
    List<int> visibleIndices = [];
    for (int i = 0; i < asmaulHusnaList.length; i++) {
      if ((i - _currentIndex).abs() <= 2) {
        visibleIndices.add(i);
      }
    }

    // Sort for proper z-index (back to front)
    visibleIndices.sort((a, b) {
      int distA = (a - _currentIndex).abs();
      int distB = (b - _currentIndex).abs();
      return distB.compareTo(distA);
    });

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: visibleIndices.map((index) {
        int diff = index - _currentIndex;
        bool isFront = diff == 0;

        // Animation values
        double offsetDx = diff * 0.45;
        double offsetDy = diff.abs() * 0.1;
        double scale = 1.0 - (diff.abs() * 0.15);
        double turns = diff * 0.03;

        return AnimatedSlide(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          offset: Offset(offsetDx, offsetDy),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            scale: scale,
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              turns: turns,
              child: GestureDetector(
                onTap: () {
                  setState(() => _currentIndex = index);
                },
                child: _buildCard(
                  index,
                  isFront,
                  isDark,
                  primaryColor,
                  isIndonesian,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCard(
    int index,
    bool isFront,
    bool isDark,
    Color primaryColor,
    bool isIndonesian,
  ) {
    final data = asmaulHusnaList[index];
    final meaning = isIndonesian ? data['meaning']! : data['meaningEn']!;

    final cardColor = isFront
        ? (isDark ? AppColors.darkCard : Colors.white)
        : (isDark ? AppColors.darkElevated : const Color(0xFFE5E0D8));

    return Container(
      width: 200,
      height: 300,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isFront ? 0.15 : 0.05),
            blurRadius: isFront ? 15 : 5,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isFront
              ? primaryColor.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: isFront
          ? _buildFrontCard(data, meaning, primaryColor, index)
          : _buildBackCard(data, isDark),
    );
  }

  Widget _buildFrontCard(
    Map<String, String> data,
    String meaning,
    Color primaryColor,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header
          Text(
            'Asmaul Husna (${index + 1}/99)',
            style: AppTextStyles.loraCaption().copyWith(
              color: primaryColor.withValues(alpha: 0.7),
            ),
          ),
          const Spacer(),

          // Arabic text
          Text(
            data['arabic']!,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              fontFamily: 'Amiri',
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 16),

          // Latin name
          Text(
            data['latin']!,
            style: AppTextStyles.loraBodyLarge().copyWith(
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),

          // Meaning
          Text(
            meaning,
            textAlign: TextAlign.center,
            style: AppTextStyles.loraBodySmall().copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildBackCard(Map<String, String> data, bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: 0.15,
          child: Text(
            data['arabic']!,
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              fontFamily: 'Amiri',
              color: isDark ? AppColors.darkTextMuted : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
