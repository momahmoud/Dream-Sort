import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Dream Sort'**
  String get appTitle;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get play;

  /// No description provided for @levels.
  ///
  /// In en, this message translates to:
  /// **'LEVELS'**
  String get levels;

  /// No description provided for @room.
  ///
  /// In en, this message translates to:
  /// **'ROOM'**
  String get room;

  /// No description provided for @multiplayer.
  ///
  /// In en, this message translates to:
  /// **'MULTIPLAYER'**
  String get multiplayer;

  /// No description provided for @muteSound.
  ///
  /// In en, this message translates to:
  /// **'Mute Sound'**
  String get muteSound;

  /// No description provided for @unmuteSound.
  ///
  /// In en, this message translates to:
  /// **'Unmute Sound'**
  String get unmuteSound;

  /// No description provided for @decorShop.
  ///
  /// In en, this message translates to:
  /// **'Decor Shop'**
  String get decorShop;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get howToPlay;

  /// No description provided for @quitGame.
  ///
  /// In en, this message translates to:
  /// **'Quit Game'**
  String get quitGame;

  /// No description provided for @selectLevel.
  ///
  /// In en, this message translates to:
  /// **'Select Level'**
  String get selectLevel;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @renovateRoom.
  ///
  /// In en, this message translates to:
  /// **'Renovate Room'**
  String get renovateRoom;

  /// No description provided for @notEnoughStars.
  ///
  /// In en, this message translates to:
  /// **'Not enough stars! Need {cost} stars.'**
  String notEnoughStars(int cost);

  /// No description provided for @owned.
  ///
  /// In en, this message translates to:
  /// **'OWNED'**
  String get owned;

  /// No description provided for @equipped.
  ///
  /// In en, this message translates to:
  /// **'EQUIPPED'**
  String get equipped;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'GAME OVER'**
  String get gameOver;

  /// No description provided for @wins.
  ///
  /// In en, this message translates to:
  /// **'{player} WINS!'**
  String wins(String player);

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String time(String time);

  /// No description provided for @backToMenu.
  ///
  /// In en, this message translates to:
  /// **'Back to Menu'**
  String get backToMenu;

  /// No description provided for @rematch.
  ///
  /// In en, this message translates to:
  /// **'Rematch'**
  String get rematch;

  /// No description provided for @vsBattle.
  ///
  /// In en, this message translates to:
  /// **'1 vs 1 Battle'**
  String get vsBattle;

  /// No description provided for @sentPenalty.
  ///
  /// In en, this message translates to:
  /// **'{player} sent a penalty!'**
  String sentPenalty(String player);

  /// No description provided for @frozeOpponent.
  ///
  /// In en, this message translates to:
  /// **'{attacker} Froze {victim}!'**
  String frozeOpponent(String attacker, String victim);

  /// No description provided for @freezeOpponent.
  ///
  /// In en, this message translates to:
  /// **'Freeze Opponent'**
  String get freezeOpponent;

  /// No description provided for @levelComplete.
  ///
  /// In en, this message translates to:
  /// **'Level Complete in {time}'**
  String levelComplete(String time);

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next Level'**
  String get nextLevel;

  /// No description provided for @dreamSorted.
  ///
  /// In en, this message translates to:
  /// **'DREAM SORTED!'**
  String get dreamSorted;

  /// No description provided for @levelTitle.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelTitle(int level);

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @tapToPick.
  ///
  /// In en, this message translates to:
  /// **'Tap a tube to pick up the top ball.'**
  String get tapToPick;

  /// No description provided for @tapToDrop.
  ///
  /// In en, this message translates to:
  /// **'Tap another tube to drop it.'**
  String get tapToDrop;

  /// No description provided for @sameColorStack.
  ///
  /// In en, this message translates to:
  /// **'You can only stack balls of the SAME color.'**
  String get sameColorStack;

  /// No description provided for @sortToWin.
  ///
  /// In en, this message translates to:
  /// **'Sort all same-colored balls into one tube to win!'**
  String get sortToWin;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'A Relaxing Puzzle Game'**
  String get subtitle;

  /// No description provided for @multiplayerMode.
  ///
  /// In en, this message translates to:
  /// **'Multiplayer Mode'**
  String get multiplayerMode;

  /// No description provided for @challengeFriends.
  ///
  /// In en, this message translates to:
  /// **'Challenge your friends!'**
  String get challengeFriends;

  /// No description provided for @createRoom.
  ///
  /// In en, this message translates to:
  /// **'Create Room'**
  String get createRoom;

  /// No description provided for @joinRoom.
  ///
  /// In en, this message translates to:
  /// **'Join Room'**
  String get joinRoom;

  /// No description provided for @localVs.
  ///
  /// In en, this message translates to:
  /// **'Local VS (Split Screen)'**
  String get localVs;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Multiplayer backend coming soon!'**
  String get comingSoon;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @sfx.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get sfx;

  /// No description provided for @resetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get resetProgress;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset All Progress?'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will delete all your stars, items, and level progress. This cannot be undone.'**
  String get resetConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @progressReset.
  ///
  /// In en, this message translates to:
  /// **'Progress has been reset.'**
  String get progressReset;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
