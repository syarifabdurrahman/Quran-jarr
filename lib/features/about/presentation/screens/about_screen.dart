import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/core/config/constants.dart';

/// About Screen
/// Displays app information and credits
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkCream : AppColors.cream;
    final primaryColor = isDark ? AppColors.darkSageGreen : AppColors.sageGreen;
    final cardColor = isDark ? AppColors.darkSoftSand : Colors.white;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('About', style: AppTextStyles.loraHeading()),
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // App Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu_book_outlined,
                  size: 50,
                  color: primaryColor,
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 24),

              // App Name
              Text(
                AppConstants.appName,
                style: AppTextStyles.loraTitle(),
                textAlign: TextAlign.center,
              ).animate().fade(delay: 100.ms),

              const SizedBox(height: 8),

              // App Version
              Text(
                'Version ${AppConstants.appVersion}',
                style: AppTextStyles.loraBodySmall().copyWith(
                  color: textSecondary,
                ),
              ).animate().fade(delay: 150.ms),

              const SizedBox(height: 8),

              // Tagline
              Text(
                'Daily verses from the Quran',
                style: AppTextStyles.loraBodyMedium().copyWith(
                  color: primaryColor,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ).animate().fade(delay: 200.ms),

              const SizedBox(height: 48),

              // Description Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? AppColors.darkGlassBorder
                          : AppColors.deepUmber.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Quran Jarr',
                      style: AppTextStyles.loraHeading().copyWith(
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Quran Jarr brings you meaningful verses from the Quran every day. Like reaching into a jar of wisdom, pull a verse to find inspiration, comfort, and guidance for your daily life.',
                      style: AppTextStyles.loraBodyMedium(),
                    ),
                  ],
                ),
              ).animate().fade(delay: 250.ms).slideY(begin: 0.2),

              const SizedBox(height: 32),

              // Developers Section
              Text(
                'Developers',
                style: AppTextStyles.loraBodySmall().copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ).animate().fade(delay: 300.ms),

              const SizedBox(height: 16),

              // Developer Cards
              _DeveloperCard(
                name: 'Favian Hugo',
                role: 'Developer',
                icon: Icons.code_outlined,
                primaryColor: primaryColor,
                cardColor: cardColor,
                textSecondary: textSecondary,
              ).animate().fade(delay: 350.ms).slideX(begin: -0.2),

              const SizedBox(height: 12),

              _DeveloperCard(
                name: 'Syarif Abdurrahman',
                role: 'Developer',
                icon: Icons.code_outlined,
                primaryColor: primaryColor,
                cardColor: cardColor,
                textSecondary: textSecondary,
              ).animate().fade(delay: 400.ms).slideX(begin: 0.2),

              const SizedBox(height: 48),

              // Footer
              Text(
                'Made with ❤️ for the Ummah',
                style: AppTextStyles.loraBodySmall().copyWith(
                  color: textSecondary,
                ),
              ).animate().fade(delay: 450.ms),

              const SizedBox(height: 8),

              Text(
                '© 2026 Quran Jarr',
                style: AppTextStyles.loraCaption().copyWith(
                  color: textSecondary,
                ),
              ).animate().fade(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}

/// Developer Card Widget
class _DeveloperCard extends StatelessWidget {
  final String name;
  final String role;
  final IconData icon;
  final Color primaryColor;
  final Color cardColor;
  final Color textSecondary;

  const _DeveloperCard({
    required this.name,
    required this.role,
    required this.icon,
    required this.primaryColor,
    required this.cardColor,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: primaryColor),
          ),

          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.loraBodyMedium().copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: AppTextStyles.loraBodySmall().copyWith(
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
