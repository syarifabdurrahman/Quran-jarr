import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran Jar'**
  String get appTitle;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get chooseYourLanguage;

  /// No description provided for @selectYourPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language for the app and Quran translation.'**
  String get selectYourPreferredLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bahasaIndonesia.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get bahasaIndonesia;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @myArchive.
  ///
  /// In en, this message translates to:
  /// **'My Archive'**
  String get myArchive;

  /// No description provided for @verseSelection.
  ///
  /// In en, this message translates to:
  /// **'Verse Selection Mode'**
  String get verseSelection;

  /// No description provided for @curatedSurahs.
  ///
  /// In en, this message translates to:
  /// **'Curated Surahs'**
  String get curatedSurahs;

  /// No description provided for @curatedSurahsDesc.
  ///
  /// In en, this message translates to:
  /// **'Selected surahs for hope, comfort & gratitude'**
  String get curatedSurahsDesc;

  /// No description provided for @randomVerses.
  ///
  /// In en, this message translates to:
  /// **'Random Verses'**
  String get randomVerses;

  /// No description provided for @randomVersesDesc.
  ///
  /// In en, this message translates to:
  /// **'Completely random from all 114 surahs'**
  String get randomVersesDesc;

  /// No description provided for @dailyNotification.
  ///
  /// In en, this message translates to:
  /// **'Daily Notification'**
  String get dailyNotification;

  /// No description provided for @notificationTime.
  ///
  /// In en, this message translates to:
  /// **'Notification Time'**
  String get notificationTime;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @arabicText.
  ///
  /// In en, this message translates to:
  /// **'Arabic Text'**
  String get arabicText;

  /// No description provided for @translationText.
  ///
  /// In en, this message translates to:
  /// **'Translation Text'**
  String get translationText;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @clearArchiveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove all saved verses from your archive?'**
  String get clearArchiveConfirm;

  /// No description provided for @clearArchive.
  ///
  /// In en, this message translates to:
  /// **'Clear Archive'**
  String get clearArchive;

  /// No description provided for @searchVerses.
  ///
  /// In en, this message translates to:
  /// **'Search verses...'**
  String get searchVerses;

  /// No description provided for @versesSaved.
  ///
  /// In en, this message translates to:
  /// **'verses saved'**
  String get versesSaved;

  /// No description provided for @verseSaved.
  ///
  /// In en, this message translates to:
  /// **'verse saved'**
  String get verseSaved;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternet;

  /// No description provided for @noInternetDesc.
  ///
  /// In en, this message translates to:
  /// **'Some features may not work offline'**
  String get noInternetDesc;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @verseRecitation.
  ///
  /// In en, this message translates to:
  /// **'Verse Recitation'**
  String get verseRecitation;

  /// No description provided for @viewTafsir.
  ///
  /// In en, this message translates to:
  /// **'View Tafsir (Ibn Kathir)'**
  String get viewTafsir;

  /// No description provided for @tafsirNotFound.
  ///
  /// In en, this message translates to:
  /// **'Tafsir not available for this verse'**
  String get tafsirNotFound;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Verse copied to clipboard!'**
  String get copiedToClipboard;

  /// No description provided for @downloadForOffline.
  ///
  /// In en, this message translates to:
  /// **'Download for offline'**
  String get downloadForOffline;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @developers.
  ///
  /// In en, this message translates to:
  /// **'Developers'**
  String get developers;

  /// No description provided for @favianHugo.
  ///
  /// In en, this message translates to:
  /// **'Favian Hugo'**
  String get favianHugo;

  /// No description provided for @syarifAbdurrahman.
  ///
  /// In en, this message translates to:
  /// **'Syarif Abdurrahman'**
  String get syarifAbdurrahman;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Quran Jar is a simple Quran verse app that brings you daily inspiration through curated verses and translations.'**
  String get aboutDescription;

  /// No description provided for @tapJar.
  ///
  /// In en, this message translates to:
  /// **'Tap the jar to get a verse'**
  String get tapJar;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// No description provided for @bookmarkRemoved.
  ///
  /// In en, this message translates to:
  /// **'Verse removed from archive'**
  String get bookmarkRemoved;

  /// No description provided for @bookmarkAdded.
  ///
  /// In en, this message translates to:
  /// **'Verse saved to archive'**
  String get bookmarkAdded;

  /// No description provided for @internetConnectionRequired.
  ///
  /// In en, this message translates to:
  /// **'Internet Connection Required'**
  String get internetConnectionRequired;

  /// No description provided for @internetConnectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Quran Jarr needs an internet connection to fetch verses, translations, and audio recitations.'**
  String get internetConnectionDesc;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// No description provided for @iUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I Understand'**
  String get iUnderstand;

  /// No description provided for @chooseYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Experience'**
  String get chooseYourExperience;

  /// No description provided for @selectYourExperienceDesc.
  ///
  /// In en, this message translates to:
  /// **'Select how you\'d like to receive verses from the Quran.'**
  String get selectYourExperienceDesc;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @dailyNotificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive a beautiful verse from the Quran every day to start your morning with peace and reflection.'**
  String get dailyNotificationDesc;

  /// No description provided for @jarTapsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Jar Taps Per Day'**
  String get jarTapsPerDay;

  /// No description provided for @jarTapsPerDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose how many jar taps you\'d like per day. Tap the number to increase, or use +/- buttons. You can change this later in settings.'**
  String get jarTapsPerDayDesc;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @alhamdulillahLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillah you reached limit today! Want more? You can change this in settings.'**
  String get alhamdulillahLimitReached;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
