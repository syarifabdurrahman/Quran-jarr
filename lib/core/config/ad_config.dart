/// AdMob Configuration
///
/// Contains AdMob app IDs and ad unit IDs for the Quran Jarr app.
///
/// IMPORTANT: Replace these with your actual AdMob IDs before releasing to production.
/// You can get these from your AdMob dashboard at https://apps.admob.com/
///
/// Test IDs provided below are for development/testing purposes only.

class AdConfig {
  // AdMob App IDs
  // Replace with your actual AdMob App ID from AdMob dashboard
  // Format: ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY
  static const String androidAppId = 'ca-app-pub-8500075420783419~2366432861';
  static const String iosAppId = 'ca-app-pub-8500075420783419~2366432861';

  // Interstitial Ad Unit IDs
  // Replace with your actual Interstitial Ad Unit ID from AdMob dashboard
  // Format: ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ
  static const String androidInterstitialAdUnitId = 'ca-app-pub-8500075420783419/6070232941';
  static const String iosInterstitialAdUnitId = 'ca-app-pub-8500075420783419/6070232941';

  /// Get the appropriate App ID based on the current platform
  static String get appId {
    // This will be resolved at runtime based on platform
    return '';
  }

  /// Get the appropriate Interstitial Ad Unit ID based on the current platform
  static String get interstitialAdUnitId {
    // This will be resolved at runtime based on platform
    return '';
  }

  /// Minimum time between interstitial ad shows (in seconds)
  /// This prevents ads from showing too rapidly
  static const int minIntervalBetweenAds = 60; // 1 minute minimum
}
