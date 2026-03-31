import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/features/about/presentation/screens/about_screen.dart';
import 'package:quran_jarr/features/archive/presentation/screens/archive_screen.dart';
import 'package:quran_jarr/features/jar/presentation/screens/jar_screen.dart';
import 'package:quran_jarr/features/settings/presentation/screens/settings_screen.dart';
import 'package:quran_jarr/features/statistics/presentation/screens/statistics_screen.dart';

/// Main Navigation Screen with Bottom Navigation Bar
/// Uses Style7 for a modern look
class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  List<PersistentTabConfig> _tabs(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.midnightPeriwinkle
        : AppColors.sageGreen;
    final inactiveColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textSecondary;

    return [
      PersistentTabConfig(
        screen: const JarScreen(),
        item: ItemConfig(
          icon: const Icon(Icons.home_rounded),
          title: 'Home',
          activeForegroundColor: primaryColor,
          inactiveForegroundColor: inactiveColor,
        ),
      ),
      PersistentTabConfig(
        screen: const StatisticsScreen(),
        item: ItemConfig(
          icon: const Icon(Icons.bar_chart_rounded),
          title: 'Stats',
          activeForegroundColor: primaryColor,
          inactiveForegroundColor: inactiveColor,
        ),
      ),
      PersistentTabConfig(
        screen: const ArchiveScreen(),
        item: ItemConfig(
          icon: const Icon(Icons.bookmark_rounded),
          title: 'Archive',
          activeForegroundColor: primaryColor,
          inactiveForegroundColor: inactiveColor,
        ),
      ),
      PersistentTabConfig(
        screen: const SettingsScreen(),
        item: ItemConfig(
          icon: const Icon(Icons.settings_rounded),
          title: 'Settings',
          activeForegroundColor: primaryColor,
          inactiveForegroundColor: inactiveColor,
        ),
      ),
      PersistentTabConfig(
        screen: const AboutScreen(),
        item: ItemConfig(
          icon: const Icon(Icons.info_outline_rounded),
          title: 'About',
          activeForegroundColor: primaryColor,
          inactiveForegroundColor: inactiveColor,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.midnightBlue : AppColors.cream;

    return PersistentTabView(
      tabs: _tabs(context),
      navBarBuilder: (navBarConfig) => Style7BottomNavBar(
        navBarConfig: navBarConfig,
        navBarDecoration: NavBarDecoration(color: bgColor),
      ),
    );
  }
}
