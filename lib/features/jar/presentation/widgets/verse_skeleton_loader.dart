import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';

/// Skeleton loader for verse card
/// Shows while verse is being fetched
class VerseSkeletonLoader extends StatelessWidget {
  const VerseSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.softSand;
    final shimmerBase = isDark ? AppColors.darkElevated : AppColors.cream;
    final shimmerHighlight = isDark ? AppColors.midnightSlate : Colors.white;

    return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header skeleton
              Row(
                children: [
                  _ShimmerBox(
                    width: 120,
                    height: 32,
                    baseColor: shimmerBase,
                    highlightColor: shimmerHighlight,
                  ),
                  const Spacer(),
                  _ShimmerBox(
                    width: 40,
                    height: 40,
                    baseColor: shimmerBase,
                    highlightColor: shimmerHighlight,
                    shape: BoxShape.circle,
                  ),
                  const SizedBox(width: 8),
                  _ShimmerBox(
                    width: 40,
                    height: 40,
                    baseColor: shimmerBase,
                    highlightColor: shimmerHighlight,
                    shape: BoxShape.circle,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Arabic text skeleton
              _ShimmerBox(
                width: double.infinity,
                height: 60,
                baseColor: shimmerBase,
                highlightColor: shimmerHighlight,
              ),
              const SizedBox(height: 16),
              // Divider
              Container(height: 1, color: shimmerBase),
              const SizedBox(height: 16),
              // Translation skeleton
              _ShimmerBox(
                width: double.infinity,
                height: 16,
                baseColor: shimmerBase,
                highlightColor: shimmerHighlight,
              ),
              const SizedBox(height: 8),
              _ShimmerBox(
                width: double.infinity,
                height: 16,
                baseColor: shimmerBase,
                highlightColor: shimmerHighlight,
              ),
              const SizedBox(height: 8),
              _ShimmerBox(
                width: 200,
                height: 16,
                baseColor: shimmerBase,
                highlightColor: shimmerHighlight,
              ),
              const SizedBox(height: 16),
              // Button skeleton
              _ShimmerBox(
                width: double.infinity,
                height: 48,
                baseColor: shimmerBase,
                highlightColor: shimmerHighlight,
                borderRadius: 12,
              ),
            ],
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: shimmerHighlight);
  }
}

/// Shimmer box widget for skeleton loading effect
class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final Color baseColor;
  final Color highlightColor;
  final BoxShape shape;
  final double borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.baseColor,
    required this.highlightColor,
    this.shape = BoxShape.rectangle,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius)
            : null,
      ),
    );
  }
}
