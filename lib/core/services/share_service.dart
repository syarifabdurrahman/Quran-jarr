import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';
import 'package:quran_jarr/features/jar/domain/entities/verse.dart';

/// Share Service
/// Handles creating and sharing verse cards as images
class ShareService {
  ShareService._();

  static final ShareService _instance = ShareService._();
  static ShareService get instance => _instance;

  final ScreenshotController _screenshotController = ScreenshotController();

  ScreenshotController get screenshotController => _screenshotController;

  /// Show share bottom sheet with options
  Future<void> showShareOptions(
    BuildContext context,
    Verse verse, {
    GlobalKey? cardKey,
  }) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ShareOptionsSheet(
        verse: verse,
        cardKey: cardKey,
      ),
    );
  }

  /// Share verse as image to WhatsApp
  Future<void> shareToWhatsApp(Verse verse, GlobalKey cardKey) async {
    final image = await _captureCard(cardKey);
    if (image != null) {
      await Share.shareXFiles(
        [XFile(image.path, mimeType: 'image/png')],
        subject: '${verse.arabicSurahName} (${verse.surahNumber}:${verse.ayahNumber})',
      );
    }
  }

  /// Share verse as image to Facebook
  Future<void> shareToFacebook(Verse verse, GlobalKey cardKey) async {
    final image = await _captureCard(cardKey);
    if (image != null) {
      await Share.shareXFiles(
        [XFile(image.path, mimeType: 'image/png')],
        subject: 'Quran Verse - ${verse.arabicSurahName}',
      );
    }
  }

  /// Share verse as image with text
  Future<void> shareAsImage(Verse verse, GlobalKey cardKey) async {
    final image = await _captureCard(cardKey);
    if (image != null) {
      await Share.shareXFiles(
        [XFile(image.path, mimeType: 'image/png')],
        subject: '${verse.arabicSurahName} (${verse.surahNumber}:${verse.ayahNumber})',
        text: '${verse.translation}\n\n${verse.surahName} (${verse.surahNumber}:${verse.ayahNumber})',
      );
    }
  }

  /// Share verse as text only
  Future<void> shareAsText(Verse verse) async {
    final shareText = '''
${verse.arabicText}

"${verse.translation}"

${verse.arabicSurahName} (${verse.surahNumber}:${verse.ayahNumber})

— Shared via Quran Jarr''';

    await Share.share(shareText.trim(), subject: 'Quran Verse');
  }

  /// Copy verse text to clipboard
  Future<void> copyToClipboard(
    Verse verse,
    BuildContext context,
  ) async {
    final shareText = '''
${verse.arabicText}

"${verse.translation}"

${verse.arabicSurahName} (${verse.surahNumber}:${verse.ayahNumber})''';

    await Clipboard.setData(ClipboardData(text: shareText.trim()));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Verse copied to clipboard!',
            style: AppTextStyles.loraBodySmall().copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.sageGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Capture the verse card as an image
  Future<File?> _captureCard(GlobalKey cardKey) async {
    try {
      RenderRepaintBoundary boundary =
          cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return null;

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/verse_$timestamp.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      return file;
    } catch (e) {
      print('Error capturing card: $e');
      return null;
    }
  }
}

/// Share Options Bottom Sheet
class _ShareOptionsSheet extends StatelessWidget {
  final Verse verse;
  final GlobalKey? cardKey;

  const _ShareOptionsSheet({
    required this.verse,
    this.cardKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.softSand,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
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
                    'Share Verse',
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
            const Divider(height: 1),
            // Share options
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // WhatsApp
                  if (cardKey != null)
                    _ShareOption(
                      icon: 'assets/icon-whatsapp.png',
                      iconData: Icons.message,
                      title: 'WhatsApp',
                      color: const Color(0xFF25D366),
                      onTap: () {
                        Navigator.pop(context);
                        ShareService.instance.shareToWhatsApp(verse, cardKey!);
                      },
                    ),
                  // Facebook
                  if (cardKey != null)
                    _ShareOption(
                      icon: 'assets/icon-facebook.png',
                      iconData: Icons.facebook,
                      title: 'Facebook',
                      color: const Color(0xFF1877F2),
                      onTap: () {
                        Navigator.pop(context);
                        ShareService.instance.shareToFacebook(verse, cardKey!);
                      },
                    ),
                  // Instagram
                  if (cardKey != null)
                    _ShareOption(
                      icon: 'assets/icon-instagram.png',
                      iconData: Icons.camera_alt,
                      title: 'Instagram Stories',
                      color: const Color(0xFFE4405F),
                      onTap: () {
                        Navigator.pop(context);
                        ShareService.instance.shareAsImage(verse, cardKey!);
                      },
                    ),
                  // More (general share)
                  if (cardKey != null)
                    _ShareOption(
                      icon: 'assets/icon-more.png',
                      iconData: Icons.share,
                      title: 'Share as Image',
                      color: AppColors.sageGreen,
                      onTap: () {
                        Navigator.pop(context);
                        ShareService.instance.shareAsImage(verse, cardKey!);
                      },
                    ),
                  // Share as text
                  _ShareOption(
                    icon: 'assets/icon-text.png',
                    iconData: Icons.text_snippet_outlined,
                    title: 'Share as Text',
                    color: AppColors.deepUmber,
                    onTap: () {
                      Navigator.pop(context);
                      ShareService.instance.shareAsText(verse);
                    },
                  ),
                  // Copy to clipboard
                  _ShareOption(
                    icon: 'assets/icon-copy.png',
                    iconData: Icons.copy,
                    title: 'Copy to Clipboard',
                    color: AppColors.terracotta,
                    onTap: () {
                      Navigator.pop(context);
                      ShareService.instance.copyToClipboard(verse, context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Share Option Widget
class _ShareOption extends StatelessWidget {
  final String? icon;
  final IconData? iconData;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
    this.icon,
    this.iconData,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: icon != null
                  ? Image.asset(icon!, width: 24, height: 24)
                  : Icon(
                      iconData,
                      color: color,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 16),
            // Title
            Text(
              title,
              style: AppTextStyles.loraBodyLarge().copyWith(
                color: AppColors.deepUmber,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.deepUmber.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
