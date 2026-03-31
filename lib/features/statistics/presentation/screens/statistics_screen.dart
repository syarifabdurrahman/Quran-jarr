import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/providers/streak_provider.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';

/// Statistics Screen
/// Shows detailed stats about reading progress
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakState = ref.watch(streakProvider);
    final streakNotifier = ref.watch(streakProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.midnightBlue : AppColors.cream;
    final primaryColor = isDark
        ? AppColors.midnightPeriwinkle
        : AppColors.sageGreen;
    final cardColor = isDark ? AppColors.darkCard : AppColors.softSand;
    final accentColor = isDark ? AppColors.midnightGold : AppColors.terracotta;

    final currentStreak = streakState.currentStreak;
    final longestStreak = streakState.longestStreak;
    final totalVerses = streakState.totalVersesRead;
    final versesToday = streakState.versesReadToday;
    final motivationalMessage = streakNotifier.motivationalMessage;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Statistics', style: AppTextStyles.loraHeading()),
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Motivational Message Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withValues(alpha: 0.2),
                    accentColor.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.auto_awesome, color: accentColor, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    motivationalMessage,
                    style: AppTextStyles.loraBodyLarge().copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats Grid
            Text(
              'Your Progress',
              style: AppTextStyles.loraHeading().copyWith(
                color: primaryColor,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),

            // Stats Cards Row 1
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: Colors.orange,
                    label: 'Current Streak',
                    value: '$currentStreak',
                    unit: 'days',
                    cardColor: cardColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.emoji_events_rounded,
                    iconColor: Colors.amber,
                    label: 'Longest Streak',
                    value: '$longestStreak',
                    unit: 'days',
                    cardColor: cardColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Stats Cards Row 2
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.menu_book_rounded,
                    iconColor: primaryColor,
                    label: 'Total Verses',
                    value: '$totalVerses',
                    unit: 'read',
                    cardColor: cardColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.today_rounded,
                    iconColor: Colors.green,
                    label: 'Today',
                    value: '$versesToday',
                    unit: 'verses',
                    cardColor: cardColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Milestones Section
            Text(
              'Milestones',
              style: AppTextStyles.loraHeading().copyWith(
                color: primaryColor,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),

            _MilestoneCard(
              days: 7,
              title: '7-Day Streak',
              description: 'Complete a full week of daily reading',
              isCompleted: currentStreak >= 7,
              primaryColor: primaryColor,
              cardColor: cardColor,
            ),
            const SizedBox(height: 12),
            _MilestoneCard(
              days: 30,
              title: '30-Day Streak',
              description: 'A month of consistent spiritual growth',
              isCompleted: currentStreak >= 30,
              primaryColor: primaryColor,
              cardColor: cardColor,
            ),
            const SizedBox(height: 12),
            _MilestoneCard(
              days: 100,
              title: '100-Day Streak',
              description: 'A true dedication to daily reflection',
              isCompleted: currentStreak >= 100,
              primaryColor: primaryColor,
              cardColor: cardColor,
            ),
            const SizedBox(height: 12),
            _MilestoneCard(
              days: 365,
              title: '1-Year Streak',
              description: 'MashaAllah! A year of daily Quran',
              isCompleted: currentStreak >= 365,
              primaryColor: primaryColor,
              cardColor: cardColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;
  final Color cardColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.loraTitle().copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.loraBodySmall().copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Milestone Card Widget
class _MilestoneCard extends StatelessWidget {
  final int days;
  final String title;
  final String description;
  final bool isCompleted;
  final Color primaryColor;
  final Color cardColor;

  const _MilestoneCard({
    required this.days,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.primaryColor,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isCompleted
            ? Border.all(color: Colors.green.withValues(alpha: 0.5), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                  style: AppTextStyles.loraBodyMedium().copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.green : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.loraBodySmall().copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$days',
            style: AppTextStyles.loraHeading().copyWith(
              color: isCompleted
                  ? Colors.green
                  : primaryColor.withValues(alpha: 0.4),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
