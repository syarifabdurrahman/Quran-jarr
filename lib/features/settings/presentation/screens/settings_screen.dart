import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/providers/preferences_provider.dart';
import 'package:quran_jarr/core/services/notification_service.dart';
import 'package:quran_jarr/core/services/preferences_service.dart';
import 'package:quran_jarr/core/services/sound_effects_service.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/core/utils/responsive_utils.dart';

/// Settings Screen
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<bool?> _showExactAlarmDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.midnightPeriwinkle
        : AppColors.sageGreen;
    final bgColor = isDark ? AppColors.darkCard : AppColors.cream;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.deepUmber;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getBorderRadius(context),
          ),
        ),
        title: Row(
          children: [
            Icon(
              Icons.alarm,
              color: primaryColor,
              size: ResponsiveUtils.getIconSize(context),
            ),
            SizedBox(width: ResponsiveUtils.getSpacing(context) * 0.75),
            Expanded(
              child: Text(
                'Enable Alarms & Reminders',
                style: AppTextStyles.loraHeading().copyWith(color: textColor),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For daily notifications to work reliably, you need to enable "Alarms & reminders" permission.',
              style: AppTextStyles.loraBodyMedium().copyWith(color: textColor),
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context) * 0.75),
            Text(
              'This is required on Android 12+ for exact timing of notifications.',
              style: AppTextStyles.loraBodySmall().copyWith(
                color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: primaryColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              await NotificationService.instance.openNotificationSettings();
              if (context.mounted) Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: Text(
              'Settings',
              style: TextStyle(
                color: isDark ? AppColors.darkSurface : AppColors.cream,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.midnightPeriwinkle
        : AppColors.sageGreen;
    final bgColor = isDark ? AppColors.midnightBlue : AppColors.cream;

    final isNotificationEnabled = ref.watch(dailyNotificationEnabledProvider);
    final notificationTime = ref.watch(notificationTimeProvider);
    final versesPerDay = ref.watch(versesPerDayProvider);
    final soundEffectsEnabled = SoundEffectsService.instance.isEnabled;
    final arabicFontSize = ref.watch(arabicFontSizeProvider);
    final englishFontSize = ref.watch(englishFontSizeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final reducedMotion = ref.watch(reducedMotionProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.loraHeading()),
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Section
            _SectionHeader(title: 'Appearance', color: primaryColor),
            const SizedBox(height: 12),
            _ThemeSelector(
              currentThemeMode: themeMode,
              onThemeChanged: (mode) {
                ref
                    .read(preferencesNotifierProvider.notifier)
                    .setThemeMode(mode);
              },
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 8),
            _SettingsToggle(
              icon: Icons.animation,
              title: 'Reduced Motion',
              value: reducedMotion,
              onChanged: (value) {
                ref
                    .read(preferencesNotifierProvider.notifier)
                    .setReducedMotion(value);
              },
              primaryColor: primaryColor,
            ),

            const SizedBox(height: 24),

            // Notifications Section
            _SectionHeader(title: 'Notifications', color: primaryColor),
            const SizedBox(height: 12),
            _SettingsToggle(
              icon: Icons.notifications_outlined,
              title: 'Daily Notification',
              value: isNotificationEnabled,
              onChanged: (enabled) async {
                if (enabled) {
                  await NotificationService.instance.requestPermission();
                  await NotificationService.instance.scheduleDailyNotification(
                    notificationTime,
                  );
                } else {
                  await NotificationService.instance.cancelAll();
                }
                await PreferencesService.instance.setDailyNotificationEnabled(
                  enabled,
                );
              },
              primaryColor: primaryColor,
            ),
            if (isNotificationEnabled) ...[
              const SizedBox(height: 8),
              _NotificationTimePicker(
                time: notificationTime,
                onTimeChanged: (time) async {
                  await ref
                      .read(preferencesNotifierProvider.notifier)
                      .setNotificationTime(time);
                },
                primaryColor: primaryColor,
              ),
            ],

            const SizedBox(height: 24),

            // Jar Settings Section
            _SectionHeader(title: 'Jar Settings', color: primaryColor),
            const SizedBox(height: 12),
            _VersesPerDaySelector(
              versesPerDay: versesPerDay,
              onValueChanged: (value) async {
                await ref
                    .read(preferencesNotifierProvider.notifier)
                    .setVersesPerDay(value);
              },
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 8),
            _SettingsToggle(
              icon: Icons.volume_up_outlined,
              title: 'Sound Effects',
              value: soundEffectsEnabled,
              onChanged: (value) {
                SoundEffectsService.instance.setEnabled(value);
                setState(() {});
              },
              primaryColor: primaryColor,
            ),

            const SizedBox(height: 24),

            // Font Size Section
            _SectionHeader(title: 'Font Size', color: primaryColor),
            const SizedBox(height: 12),
            _FontSizeSlider(
              icon: Icons.text_fields,
              title: 'Arabic Text',
              value: arabicFontSize,
              min: 0.8,
              max: 1.5,
              onChanged: (value) {
                ref
                    .read(preferencesNotifierProvider.notifier)
                    .setArabicFontSize(value);
              },
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 8),
            _FontSizeSlider(
              icon: Icons.translate,
              title: 'Translation Text',
              value: englishFontSize,
              min: 0.8,
              max: 1.5,
              onChanged: (value) {
                ref
                    .read(preferencesNotifierProvider.notifier)
                    .setEnglishFontSize(value);
              },
              primaryColor: primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// Section Header Widget
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.loraBodySmall().copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Settings Toggle Widget
class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color primaryColor;

  const _SettingsToggle({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.loraBodyMedium(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: primaryColor.withValues(alpha: 0.5),
            activeThumbColor: primaryColor,
          ),
        ],
      ),
    );
  }
}

/// Notification Time Picker Widget
class _NotificationTimePicker extends StatelessWidget {
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final Color primaryColor;

  const _NotificationTimePicker({
    required this.time,
    required this.onTimeChanged,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) {
          onTimeChanged(picked);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 18, color: primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Notification Time',
                style: AppTextStyles.loraBodyMedium(),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                time.format(context),
                style: AppTextStyles.loraBodyMedium().copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Font Size Slider Widget
class _FontSizeSlider extends StatelessWidget {
  final IconData icon;
  final String title;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final Color primaryColor;

  const _FontSizeSlider({
    required this.icon,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.loraBodyMedium()),
                Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: 7,
                  activeColor: primaryColor,
                  inactiveColor: primaryColor.withValues(alpha: 0.3),
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(value * 100).round()}%',
              style: AppTextStyles.loraBodySmall().copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Verses Per Day Selector Widget
class _VersesPerDaySelector extends StatelessWidget {
  final int versesPerDay;
  final ValueChanged<int> onValueChanged;
  final Color primaryColor;

  const _VersesPerDaySelector({
    required this.versesPerDay,
    required this.onValueChanged,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnlimited = versesPerDay >= 9999;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.touch_app_outlined, size: 18, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Jar Taps Per Day',
              style: AppTextStyles.loraBodyMedium(),
              maxLines: 1,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TapButton(
                icon: Icons.remove,
                onTap: () {
                  if (versesPerDay > 1) {
                    onValueChanged(versesPerDay - 1);
                  }
                },
                primaryColor: primaryColor,
                isSmall: true,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  onValueChanged(isUnlimited ? 3 : 9999);
                },
                child: Container(
                  width: 50,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      isUnlimited ? '∞' : versesPerDay.toString(),
                      style: AppTextStyles.loraHeading().copyWith(
                        color: AppColors.cream,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _TapButton(
                icon: Icons.add,
                onTap: () {
                  if (!isUnlimited) {
                    onValueChanged(versesPerDay + 1);
                  }
                },
                primaryColor: primaryColor,
                isSmall: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small Tap Button
class _TapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color primaryColor;
  final bool isSmall;

  const _TapButton({
    required this.icon,
    required this.onTap,
    required this.primaryColor,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isSmall ? 32 : 40,
        height: isSmall ? 32 : 40,
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(isSmall ? 8 : 10),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(icon, size: isSmall ? 16 : 20, color: primaryColor),
      ),
    );
  }
}

/// Theme Selector Widget
class _ThemeSelector extends StatelessWidget {
  final int currentThemeMode;
  final ValueChanged<int> onThemeChanged;
  final Color primaryColor;

  const _ThemeSelector({
    required this.currentThemeMode,
    required this.onThemeChanged,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        _ThemeOption(
          icon: Icons.brightness_auto,
          label: 'System',
          isSelected: currentThemeMode == 0,
          onTap: () => onThemeChanged(0),
          primaryColor: primaryColor,
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _ThemeOption(
          icon: Icons.light_mode,
          label: 'Light',
          isSelected: currentThemeMode == 1,
          onTap: () => onThemeChanged(1),
          primaryColor: primaryColor,
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _ThemeOption(
          icon: Icons.dark_mode,
          label: 'Dark',
          isSelected: currentThemeMode == 2,
          onTap: () => onThemeChanged(2),
          primaryColor: primaryColor,
          isDark: isDark,
        ),
      ],
    );
  }
}

/// Individual Theme Option Button
class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;
  final bool isDark;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withValues(alpha: 0.15)
                : (isDark ? AppColors.darkElevated : AppColors.softSand),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : primaryColor.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? primaryColor
                    : primaryColor.withValues(alpha: 0.7),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.loraCaption().copyWith(
                  color: isSelected ? primaryColor : null,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
