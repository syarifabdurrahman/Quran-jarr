import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';
import 'package:quran_jarr/features/jar/presentation/widgets/spiritual_aura_card.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';

class ShareService {
  static final ShareService instance = ShareService._();
  ShareService._();

  final ScreenshotController screenshotController = ScreenshotController();

  /// Share a widget as an image
  Future<void> shareWidgetAsImage(Widget widget, {String? fileName}) async {
    try {
      final image = await screenshotController.captureFromWidget(
        widget,
        delay: const Duration(milliseconds: 100),
      );

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/${fileName ?? 'verse_share'}.png').create();
      await imagePath.writeAsBytes(image);

      await Share.shareXFiles([XFile(imagePath.path)], text: 'Shared from Quran Jarr');
    } catch (e) {
      debugPrint('Error sharing widget: $e');
    }
  }

  /// Save a widget as an image to gallery
  Future<bool> saveWidgetToGallery(Widget widget, {String? fileName}) async {
    try {
      final image = await screenshotController.captureFromWidget(
        widget,
        delay: const Duration(milliseconds: 100),
      );

      final result = await ImageGallerySaverPlus.saveImage(
        image,
        name: fileName ?? 'verse_${DateTime.now().millisecondsSinceEpoch}',
      );

      return result != null && result['isSuccess'] == true;
    } catch (e) {
      debugPrint('Error saving widget: $e');
      return false;
    }
  }

  /// Show share options (Text or Image)
  Future<void> showShareOptions(
    BuildContext context,
    Verse verse, {
    GlobalKey? cardKey,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.glassNight : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Verse',
              style: AppTextStyles.loraHeadingForTheme(context),
            ),
            const SizedBox(height: 32),
            _buildShareOption(
              context,
              icon: Icons.text_fields_rounded,
              title: 'Share as Text',
              subtitle: 'Send Arabic text and translation',
              onTap: () {
                Navigator.pop(context);
                final text = '${verse.arabicText}\n\n${verse.translation}\n\n— ${verse.surahReference}\nShared from Quran Jarr';
                Share.share(text);
              },
            ),
            const SizedBox(height: 16),
            _buildShareOption(
              context,
              icon: Icons.auto_awesome,
              title: 'Share Spiritual Aura',
              subtitle: 'Beautiful glassmorphic image',
              onTap: () async {
                Navigator.pop(context);
                
                // Show a small loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Generating Spiritual Aura...'),
                    duration: Duration(seconds: 2),
                  ),
                );

                await shareWidgetAsImage(
                  SpiritualAuraCard(verse: verse, isDark: isDark),
                  fileName: 'spiritual_aura_${verse.verseKey.replaceAll(':', '_')}',
                );
              },
            ),
            const SizedBox(height: 16),
            _buildShareOption(
              context,
              icon: Icons.download_rounded,
              title: 'Save to Gallery',
              subtitle: 'Keep the Aura card in your phone',
              onTap: () async {
                Navigator.pop(context);
                
                final success = await saveWidgetToGallery(
                  SpiritualAuraCard(verse: verse, isDark: isDark),
                  fileName: 'verse_${verse.verseKey.replaceAll(':', '_')}',
                );

                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved to Gallery! ✨')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.midnightPeriwinkle : AppColors.sageGreen;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.loraBodyLargeForTheme(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.loraCaptionForTheme(context),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: primaryColor.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
