import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/core/config/constants.dart';
import 'package:quran_jarr/l10n/app_localizations.dart';
import 'package:quran_jarr/core/services/locale_service.dart';

/// About Screen
/// Displays app information and credits
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bgColor = AppColors.cream;
    final primaryColor = AppColors.sageGreen;
    final cardColor = Colors.white;
    final textSecondary = AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(l10n.aboutUs, style: AppTextStyles.loraHeading()),
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
                l10n.appTitle,
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
                      color: AppColors.deepUmber.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aboutUs,
                      style: AppTextStyles.loraHeading().copyWith(
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.aboutDescription,
                      style: AppTextStyles.loraBodyMedium(),
                    ),
                  ],
                ),
              ).animate().fade(delay: 250.ms).slideY(begin: 0.2),

              const SizedBox(height: 32),

              // Developers Section
              Text(
                l10n.developers,
                style: AppTextStyles.loraBodySmall().copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ).animate().fade(delay: 300.ms),

              const SizedBox(height: 16),

              // Developer Cards
              _DeveloperCard(
                name: l10n.favianHugo,
                role: l10n.developers,
                icon: Icons.code_outlined,
                primaryColor: primaryColor,
                cardColor: cardColor,
                textSecondary: textSecondary,
              ).animate().fade(delay: 350.ms).slideX(begin: -0.2),

              const SizedBox(height: 12),

              _DeveloperCard(
                name: l10n.syarifAbdurrahman,
                role: l10n.developers,
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
