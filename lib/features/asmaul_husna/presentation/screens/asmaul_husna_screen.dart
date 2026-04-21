import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/config/translations.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/core/providers/locale_provider.dart';
import 'package:quran_jarr/core/providers/preferences_provider.dart';
import 'package:quran_jarr/features/asmaul_husna/data/asmaul_husna_data.dart';

/// Asmaul Husna Screen
/// Displays 99 Names of Allah with card stack UI and swipe support
class AsmaulHusnaScreen extends ConsumerStatefulWidget {
  const AsmaulHusnaScreen({super.key});

  @override
  ConsumerState<AsmaulHusnaScreen> createState() => _AsmaulHusnaScreenState();
}

class _AsmaulHusnaScreenState extends ConsumerState<AsmaulHusnaScreen> {
  int _currentIndex = 0;
  double _dragStartX = 0;
  bool _isDragging = false;

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

  void _onDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
    _isDragging = true;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final velocity = details.velocity.pixelsPerSecond.dx;
    const threshold = 300.0;

    if (velocity < -threshold ||
        (velocity.abs() < threshold &&
            _dragStartX - details.globalPosition.dx > 50)) {
      _nextCard();
    } else if (velocity > threshold ||
        (velocity.abs() < threshold &&
            details.globalPosition.dx - _dragStartX > 50)) {
      _prevCard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? null : AppColors.cream;
    final primaryColor = isDark
        ? AppColors.midnightPeriwinkle
        : AppColors.sageGreen;
    final currentLocale = ref.watch(localeNotifierProvider);
    final isIndonesian = currentLocale.languageCode == 'id';

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: isDark 
                  ? AppColors.darkSurface.withValues(alpha: 0.1)
                  : AppColors.cream.withValues(alpha: 0.8),
              elevation: 0,
              title: Text('Names of Allah', style: AppTextStyles.loraHeadingForTheme(context)),
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () => setState(() => _currentIndex = 0),
                  icon: Icon(Icons.refresh_rounded, color: primaryColor),
                  tooltip: 'Reset',
                ),
                IconButton(
                  onPressed: () async {
                    final translation = isIndonesian
                        ? AvailableTranslations.allTranslations.firstWhere((t) => t.id == 'english')
                        : AvailableTranslations.allTranslations.firstWhere((t) => t.id == 'indonesian');
                    await ref.read(preferencesNotifierProvider.notifier).setTranslation(translation);
                  },
                  icon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      isIndonesian ? 'ID' : 'EN',
                      style: AppTextStyles.loraCaptionForTheme(context).copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: isDark
            ? const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 1.2,
                  colors: [
                    Color(0xFF1E293B), // Midnight Blue Lighter
                    Color(0xFF020617), // Midnight Blue Deep
                  ],
                  stops: [0.0, 1.0],
                ),
              )
            : null,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Navigation info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${asmaulHusnaList.length}',
                  style: AppTextStyles.loraBodySmallForTheme(context).copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Main content area with swipe support
              Expanded(
                child: GestureDetector(
                  onHorizontalDragStart: _onDragStart,
                  onHorizontalDragUpdate: _onDragUpdate,
                  onHorizontalDragEnd: _onDragEnd,
                  child: Stack(
                    children: [
                      // Card Stack - centered
                      Center(
                        child: _buildCardStack(isDark, primaryColor, isIndonesian),
                      ),

                      // Prev Button - positioned on left, always visible
                      Positioned(
                        left: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _NavButton(
                            icon: Icons.chevron_left_rounded,
                            onTap: _currentIndex > 0 ? _prevCard : null,
                            primaryColor: primaryColor,
                            isDark: isDark,
                          ),
                        ),
                      ),

                      // Next Button - positioned on right, always visible
                      Positioned(
                        right: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _NavButton(
                            icon: Icons.chevron_right_rounded,
                            onTap: _currentIndex < asmaulHusnaList.length - 1
                                ? _nextCard
                                : null,
                            primaryColor: primaryColor,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

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
                    'Swipe or use arrows to navigate',
                    style: AppTextStyles.loraBodySmallForTheme(context).copyWith(
                      color: primaryColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
      ),
      ),
    );
  }

  Widget _buildCardStack(bool isDark, Color primaryColor, bool isIndonesian) {
    List<int> visibleIndices = [];
    for (int i = 0; i < asmaulHusnaList.length; i++) {
      if ((i - _currentIndex).abs() <= 2) {
        visibleIndices.add(i);
      }
    }

    visibleIndices.sort((a, b) {
      int distA = (a - _currentIndex).abs();
      int distB = (b - _currentIndex).abs();
      return distB.compareTo(distA);
    });

    return SizedBox(
      width: 220,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: visibleIndices.map((index) {
          int diff = index - _currentIndex;
          bool isFront = diff == 0;

          double offsetDx = diff * 0.4;
          double offsetDy = diff.abs() * 0.08;
          double scale = 1.0 - (diff.abs() * 0.12);
          double turns = diff * 0.02;

          return AnimatedSlide(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            offset: Offset(offsetDx, offsetDy),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              scale: scale,
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                turns: turns,
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
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
      ),
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: isFront ? 10 : 0, sigmaY: isFront ? 10 : 0),
        child: Container(
          width: 170,
          height: 250,
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: isFront ? 0.85 : 0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark 
                    ? primaryColor.withValues(alpha: isFront ? 0.2 : 0.05)
                    : Colors.black.withValues(alpha: isFront ? 0.15 : 0.05),
                blurRadius: isFront ? 20 : 5,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: isFront
                  ? primaryColor.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.05),
              width: isFront ? 1.5 : 1,
            ),
          ),
          child: isFront
              ? _buildFrontCard(data, meaning, primaryColor, index, isDark)
              : _buildBackCard(data, isDark),
        ),
      ),
    );
  }

  Widget _buildFrontCard(
    Map<String, String> data,
    String meaning,
    Color primaryColor,
    int index,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Asmaul Husna (${index + 1}/99)',
            style: AppTextStyles.loraCaptionForTheme(context).copyWith(
              color: primaryColor.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              data['arabic']!,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Amiri',
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 6),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              data['latin']!,
              style: AppTextStyles.loraBodyMediumForTheme(context).copyWith(
                fontWeight: FontWeight.w600,
                color: primaryColor,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),

          Flexible(
            child: Text(
              meaning,
              textAlign: TextAlign.center,
              style: AppTextStyles.loraCaptionForTheme(context).copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                fontSize: 11,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(Map<String, String> data, bool isDark) {
    return Center(
      child: Opacity(
        opacity: 0.15,
        child: Text(
          data['arabic']!,
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            fontFamily: 'Amiri',
            color: isDark ? AppColors.darkTextMuted : Colors.grey,
          ),
        ),
      ),
    );
  }
}

/// Navigation Button Widget
class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color primaryColor;
  final bool isDark;

  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isEnabled
                ? (isDark ? AppColors.darkCard : Colors.white).withValues(
                    alpha: 0.9,
                  )
                : (isDark ? AppColors.darkCard : Colors.white).withValues(
                    alpha: 0.3,
                  ),
            shape: BoxShape.circle,
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: isEnabled
                ? primaryColor
                : primaryColor.withValues(alpha: 0.3),
            size: 28,
          ),
        ),
      ),
    );
  }
}
