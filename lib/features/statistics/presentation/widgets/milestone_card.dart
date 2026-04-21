import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';

class MilestoneCard extends StatelessWidget {
  final int days;
  final String title;
  final String description;
  final bool isCompleted;
  final Color primaryColor;
  final Color cardColor;

  const MilestoneCard({
    super.key,
    required this.days,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.primaryColor,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassBorder = isDark ? Color(0x3394A3B8) : Colors.black.withValues(alpha: 0.05);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: isDark ? 10 : 0,
          sigmaY: isDark ? 10 : 0,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0x1A1E293B) : cardColor,
            borderRadius: BorderRadius.circular(16),
            border: isCompleted
                ? Border.all(color: Colors.green.withValues(alpha: 0.5), width: 2)
                : Border.all(color: glassBorder, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withValues(alpha: 0.1)
                      : primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCompleted
                      ? Colors.green
                      : primaryColor.withValues(alpha: 0.5),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.loraBodyMediumForTheme(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? Colors.green : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.loraBodySmallForTheme(context).copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$days',
                style: AppTextStyles.loraHeadingForTheme(context).copyWith(
                  color: isCompleted
                      ? Colors.green
                      : primaryColor.withValues(alpha: 0.4),
                  fontSize: 18,
                ),
              ),
            ],
          ),
    ),
    ),
    );
  }
}
