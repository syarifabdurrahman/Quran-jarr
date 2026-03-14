import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quran_jarr/core/config/ad_config.dart';

/// Ad Service
///
/// Manages AdMob ads for the Quran Jarr app.
/// This is a singleton service that handles interstitial ads with throttling
/// to prevent ads from showing too rapidly.
class AdService {
  AdService._();

  static final AdService instance = AdService._();

  // Interstitial ad
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  // Timestamp of last interstitial ad show
  DateTime? _lastAdShowTime;

  // Flag to track if ads are initialized
  bool _isInitialized = false;

  /// Get the appropriate App ID based on the current platform
  String _getAppId() {
    if (Platform.isAndroid) {
      return AdConfig.androidAppId;
    } else if (Platform.isIOS) {
      return AdConfig.iosAppId;
    }
    return '';
  }

  /// Get the appropriate Interstitial Ad Unit ID based on the current platform
  String _getInterstitialAdUnitId() {
    if (Platform.isAndroid) {
      return AdConfig.androidInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return AdConfig.iosInterstitialAdUnitId;
    }
    return '';
  }

  /// Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      // Load the first interstitial ad
      _loadInterstitialAd();
    } catch (e) {
      // Silently fail during initialization
      _isInitialized = false;
    }
  }

  /// Load an interstitial ad
  void _loadInterstitialAd() {
    if (!Platform.isAndroid && !Platform.isIOS) {
      // Ads are not supported on this platform
      return;
    }

    final adUnitId = _getInterstitialAdUnitId();

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          // Set full screen content callback
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              // Ad dismissed - preload next ad
              _isInterstitialAdReady = false;
              ad.dispose();
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              // Ad failed to show - preload next ad
              _isInterstitialAdReady = false;
              ad.dispose();
              _loadInterstitialAd();
            },
            onAdShowedFullScreenContent: (ad) {
              // Ad showed successfully - update last show time
              _lastAdShowTime = DateTime.now();
            },
          );
        },
        onAdFailedToLoad: (error) {
          // Failed to load ad - try loading again after a delay
          _isInterstitialAdReady = false;
          Future.delayed(const Duration(seconds: 30), () {
            _loadInterstitialAd();
          });
        },
      ),
    );
  }

  /// Check if enough time has passed since the last ad was shown
  bool get _canShowAd {
    if (_lastAdShowTime == null) {
      return true; // First ad
    }

    final timeSinceLastAd = DateTime.now().difference(_lastAdShowTime!);
    return timeSinceLastAd >= Duration(seconds: AdConfig.minIntervalBetweenAds);
  }

  /// Show an interstitial ad
  ///
  /// Returns true if the ad was shown, false otherwise.
  /// This method respects the minimum interval between ads to prevent
  /// ads from showing too rapidly.
  Future<bool> showInterstitialAd() async {
    if (!_isInitialized) {
      await initialize();
    }

    // Check if we can show an ad based on time throttling
    if (!_canShowAd) {
      // Not enough time has passed since last ad
      return false;
    }

    // Check if an ad is ready
    if (!_isInterstitialAdReady || _interstitialAd == null) {
      // No ad ready to show
      return false;
    }

    try {
      await _interstitialAd!.show();
      return true;
    } catch (e) {
      // Failed to show ad
      return false;
    }
  }

  /// Get the time until the next ad can be shown
  ///
  /// Returns null if an ad can be shown immediately
  Duration? getTimeUntilNextAd() {
    if (_lastAdShowTime == null) {
      return null; // Can show immediately
    }

    final timeSinceLastAd = DateTime.now().difference(_lastAdShowTime!);
    final minInterval = Duration(seconds: AdConfig.minIntervalBetweenAds);

    if (timeSinceLastAd >= minInterval) {
      return null; // Can show immediately
    }

    return minInterval - timeSinceLastAd;
  }

  /// Dispose of resources
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }
}
