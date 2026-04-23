import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quran_jarr/core/providers/connectivity_provider.dart';
import 'package:quran_jarr/core/services/ad_service.dart';
import 'package:quran_jarr/core/theme/app_colors.dart';
import 'package:quran_jarr/core/theme/app_text_styles.dart';

class NativeAdWidget extends ConsumerStatefulWidget {
  const NativeAdWidget({super.key});

  @override
  ConsumerState<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends ConsumerState<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;
  bool _adLoadAttempted = false;

  @override
  void initState() {
    super.initState();
    // Register callback to reload ad when connection is restored
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(connectivityProvider.notifier).onConnectionRestored(_loadAd);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  void _loadAd() {
    // Skip if already loaded or currently loading
    if (_nativeAdIsLoaded || _adLoadAttempted) return;
    _adLoadAttempted = true;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Choose colors based on theme to make the ad feel "Premium" and integrated
    final backgroundColor = isDark ? AppColors.darkCard : AppColors.cream;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.deepUmber;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final accentColor = isDark ? AppColors.midnightGold : AppColors.terracotta;

    _nativeAd = NativeAd(
      adUnitId: AdService.instance.getNativeAdUnitId(),
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _nativeAdIsLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: backgroundColor,
        cornerRadius: 12.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: accentColor,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: primaryTextColor,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: secondaryTextColor,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: secondaryTextColor,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_nativeAdIsLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.mutedGold.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
            child: Row(
              children: [
                Icon(
                  Icons.stars_rounded,
                  size: 12,
                  color: AppColors.mutedGold.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  'SPONSORED',
                  style: AppTextStyles.loraBodySmallForTheme(context).copyWith(
                    fontSize: 8,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mutedGold.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 70,
              maxHeight: 80,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AdWidget(ad: _nativeAd!),
            ),
          ),
        ],
      ),
    );
  }
}
