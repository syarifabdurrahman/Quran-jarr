import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_jarr/core/config/translations.dart';
import 'package:quran_jarr/core/providers/preferences_provider.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/features/jar/presentation/providers/jar_provider.dart';

/// Translation Picker Widget
/// Shows a bottom sheet with available translations
class TranslationPickerWidget extends ConsumerWidget {
  /// Optional callback to execute after translation changes
  /// Receives the new translation ID
  final Future<void> Function(String translationId)? onTranslationChanged;

  const TranslationPickerWidget({
    super.key,
    this.onTranslationChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTranslation = ref.watch(selectedTranslationProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.softSand,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.glassBorder.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Select Translation',
                  style: AppTextStyles.loraTitle(),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.sageGreen,
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.glassBorder.withOpacity(0.3),
            ),
          ),
          // Translations list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: AvailableTranslations.allTranslations.length,
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder.withOpacity(0.2),
                ),
              ),
            ),
            itemBuilder: (context, index) {
              final translation = AvailableTranslations.allTranslations[index];
              final isSelected = translation.id == currentTranslation.id;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                title: Text(
                  translation.name,
                  style: AppTextStyles.loraBodyLarge().copyWith(
                    color: isSelected
                        ? AppColors.sageGreen
                        : AppColors.deepUmber,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  translation.author,
                  style: AppTextStyles.loraBodySmall().copyWith(
                    color: AppColors.deepUmber.withOpacity(0.6),
                  ),
                ),
                trailing: isSelected
                    ? Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.sageGreen.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: AppColors.sageGreen,
                          size: 20,
                        ),
                      )
                    : null,
                onTap: () async {
                  await ref
                      .read(preferencesNotifierProvider.notifier)
                      .setTranslation(translation);
                  // Close the picker
                  if (context.mounted) {
                    Navigator.pop(context);
                    // Call the custom callback if provided, otherwise default to jar reload
                    final callback = onTranslationChanged;
                    if (callback != null) {
                      await callback(translation.id);
                    } else {
                      await ref.read(jarNotifierProvider.notifier).reloadVerseWithTranslation(translation.id);
                    }
                  }
                },
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Show translation picker bottom sheet
/// [onTranslationChanged] is an optional callback to execute after translation changes
Future<void> showTranslationPicker(
  BuildContext context, {
  Future<void> Function(String translationId)? onTranslationChanged,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => TranslationPickerWidget(
      onTranslationChanged: onTranslationChanged,
    ),
  );
}
