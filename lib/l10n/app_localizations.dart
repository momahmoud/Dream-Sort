import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';

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
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
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

  /// Label for the daily challenge button
  ///
  /// In en, this message translates to:
  /// **'DAILY CHALLENGE'**
  String get dailyChallenge;

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

  /// No description provided for @quitGameDesc.
  ///
  /// In en, this message translates to:
  /// **'Your progress will be lost. Are you sure you want to leave?'**
  String get quitGameDesc;

  /// No description provided for @quitGameAction.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quitGameAction;

  /// No description provided for @keepPlaying.
  ///
  /// In en, this message translates to:
  /// **'Keep Playing'**
  String get keepPlaying;

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

  /// No description provided for @notEnoughCoins.
  ///
  /// In en, this message translates to:
  /// **'Not enough coins! Need {cost} coins.'**
  String notEnoughCoins(int cost);

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

  /// No description provided for @notifDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'🎁 Daily Bonus Ready!'**
  String get notifDailyTitle;

  /// No description provided for @notifDailyBody.
  ///
  /// In en, this message translates to:
  /// **'Your daily reward is waiting. Come collect it!'**
  String get notifDailyBody;

  /// No description provided for @rewardBase.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get rewardBase;

  /// No description provided for @rewardUndoBonus.
  ///
  /// In en, this message translates to:
  /// **'Undo Bonus'**
  String get rewardUndoBonus;

  /// No description provided for @rewardTimeBonus.
  ///
  /// In en, this message translates to:
  /// **'Time Bonus'**
  String get rewardTimeBonus;

  /// No description provided for @rewardComboBonus.
  ///
  /// In en, this message translates to:
  /// **'Combo Bonus'**
  String get rewardComboBonus;

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
  /// **'This will delete all your coins, items, and level progress. This cannot be undone.'**
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

  /// No description provided for @chooseDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Choose difficulty for local vs'**
  String get chooseDifficulty;

  /// No description provided for @enterNameAndLevel.
  ///
  /// In en, this message translates to:
  /// **'Enter your name and select level'**
  String get enterNameAndLevel;

  /// No description provided for @playerName.
  ///
  /// In en, this message translates to:
  /// **'Player Name'**
  String get playerName;

  /// No description provided for @enterRoomDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter room details to join'**
  String get enterRoomDetails;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @roomCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Room Code (e.g. ABCD)'**
  String get roomCodeHint;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @accessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// No description provided for @colorBlindMode.
  ///
  /// In en, this message translates to:
  /// **'Color-Blind Symbols'**
  String get colorBlindMode;

  /// No description provided for @perfect.
  ///
  /// In en, this message translates to:
  /// **'PERFECT!'**
  String get perfect;

  /// No description provided for @resetLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart Level?'**
  String get resetLevelTitle;

  /// No description provided for @resetLevelDesc.
  ///
  /// In en, this message translates to:
  /// **'Your progress will be lost and undos will reset.'**
  String get resetLevelDesc;

  /// No description provided for @resetLevelAction.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get resetLevelAction;

  /// No description provided for @outOfUndosTitle.
  ///
  /// In en, this message translates to:
  /// **'Out of Undos!'**
  String get outOfUndosTitle;

  /// No description provided for @outOfUndosDesc.
  ///
  /// In en, this message translates to:
  /// **'Buy {count} more undos to keep going.'**
  String outOfUndosDesc(int count);

  /// No description provided for @buyUndos.
  ///
  /// In en, this message translates to:
  /// **'Buy {count} Undos ({cost} coins)'**
  String buyUndos(int count, int cost);

  /// No description provided for @watchAdFreeUndos.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad — Free {count} Undos'**
  String watchAdFreeUndos(int count);

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get needHelp;

  /// No description provided for @addTubeDesc.
  ///
  /// In en, this message translates to:
  /// **'Add an extra empty tube to make\nsolving this puzzle easier!'**
  String get addTubeDesc;

  /// No description provided for @addTube.
  ///
  /// In en, this message translates to:
  /// **'Add Tube'**
  String get addTube;

  /// No description provided for @shuffleTitle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle?'**
  String get shuffleTitle;

  /// No description provided for @shuffleDesc.
  ///
  /// In en, this message translates to:
  /// **'Rearrange balls to find new moves!\n(Completed tubes stay safe)'**
  String get shuffleDesc;

  /// No description provided for @shuffleAction.
  ///
  /// In en, this message translates to:
  /// **'Shuffle ({cost})'**
  String shuffleAction(int cost);

  /// No description provided for @watchVideo.
  ///
  /// In en, this message translates to:
  /// **'Watch Video'**
  String get watchVideo;

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad'**
  String get watchAd;

  /// No description provided for @notEnoughCoinsWatchAd.
  ///
  /// In en, this message translates to:
  /// **'Not enough coins! Watch an ad instead.'**
  String get notEnoughCoinsWatchAd;

  /// No description provided for @watchAdPlus50Coins.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad +25 Coins'**
  String get watchAdPlus50Coins;

  /// No description provided for @earnFreeCoins.
  ///
  /// In en, this message translates to:
  /// **'Watch a short video to instantly earn\n+25 Free Coins!'**
  String get earnFreeCoins;

  /// No description provided for @noThanks.
  ///
  /// In en, this message translates to:
  /// **'No, thanks'**
  String get noThanks;

  /// No description provided for @needMoreCoins.
  ///
  /// In en, this message translates to:
  /// **'Need More Coins?'**
  String get needMoreCoins;

  /// No description provided for @needHint.
  ///
  /// In en, this message translates to:
  /// **'Need a Hint?'**
  String get needHint;

  /// No description provided for @hintDesc.
  ///
  /// In en, this message translates to:
  /// **'Stuck? Let the AI find the best move for you!\nCost: {cost} Coins.'**
  String hintDesc(int cost);

  /// No description provided for @getHint.
  ///
  /// In en, this message translates to:
  /// **'Get Hint ({cost})'**
  String getHint(int cost);

  /// No description provided for @undoText.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoText;

  /// No description provided for @earnedCoins.
  ///
  /// In en, this message translates to:
  /// **'You earned {amount} '**
  String earnedCoins(Object amount);

  /// No description provided for @dailyRewardTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Reward'**
  String get dailyRewardTitle;

  /// No description provided for @dailyStreak.
  ///
  /// In en, this message translates to:
  /// **'Day {streak} Streak'**
  String dailyStreak(int streak);

  /// No description provided for @claim.
  ///
  /// In en, this message translates to:
  /// **'CLAIM'**
  String get claim;

  /// No description provided for @comeBackTomorrowForCoins.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow for {amount} coins!'**
  String comeBackTomorrowForCoins(int amount);

  /// No description provided for @decorTypeTube.
  ///
  /// In en, this message translates to:
  /// **'Tubes'**
  String get decorTypeTube;

  /// No description provided for @decorTypeBall.
  ///
  /// In en, this message translates to:
  /// **'Balls'**
  String get decorTypeBall;

  /// No description provided for @decorTypeWall.
  ///
  /// In en, this message translates to:
  /// **'Walls'**
  String get decorTypeWall;

  /// No description provided for @decorTypeFloor.
  ///
  /// In en, this message translates to:
  /// **'Floors'**
  String get decorTypeFloor;

  /// No description provided for @decorTypePlant.
  ///
  /// In en, this message translates to:
  /// **'Plants'**
  String get decorTypePlant;

  /// No description provided for @decorTypeLamp.
  ///
  /// In en, this message translates to:
  /// **'Lamps'**
  String get decorTypeLamp;

  /// No description provided for @decorTypeRug.
  ///
  /// In en, this message translates to:
  /// **'Rugs'**
  String get decorTypeRug;

  /// No description provided for @decorTypePainting.
  ///
  /// In en, this message translates to:
  /// **'Arts'**
  String get decorTypePainting;

  /// No description provided for @item_tube_default.
  ///
  /// In en, this message translates to:
  /// **'Glass Vials'**
  String get item_tube_default;

  /// No description provided for @item_tube_bamboo.
  ///
  /// In en, this message translates to:
  /// **'Zen Bamboo'**
  String get item_tube_bamboo;

  /// No description provided for @item_tube_metal.
  ///
  /// In en, this message translates to:
  /// **'Cyber Alloy'**
  String get item_tube_metal;

  /// No description provided for @item_tube_gold_rim.
  ///
  /// In en, this message translates to:
  /// **'Royal Gold'**
  String get item_tube_gold_rim;

  /// No description provided for @item_tube_crystal.
  ///
  /// In en, this message translates to:
  /// **'Ice Crystal'**
  String get item_tube_crystal;

  /// No description provided for @item_tube_magma.
  ///
  /// In en, this message translates to:
  /// **'Magma Forge'**
  String get item_tube_magma;

  /// No description provided for @item_ball_default.
  ///
  /// In en, this message translates to:
  /// **'Smooth Spheres'**
  String get item_ball_default;

  /// No description provided for @item_ball_neon.
  ///
  /// In en, this message translates to:
  /// **'Neon Orbs'**
  String get item_ball_neon;

  /// No description provided for @item_ball_emoji.
  ///
  /// In en, this message translates to:
  /// **'Emoji Faces'**
  String get item_ball_emoji;

  /// No description provided for @item_ball_jewel.
  ///
  /// In en, this message translates to:
  /// **'Precious Jewels'**
  String get item_ball_jewel;

  /// No description provided for @item_ball_planets.
  ///
  /// In en, this message translates to:
  /// **'Galaxy Planets'**
  String get item_ball_planets;

  /// No description provided for @item_ball_sports.
  ///
  /// In en, this message translates to:
  /// **'Sports Pack'**
  String get item_ball_sports;

  /// No description provided for @item_wall_default.
  ///
  /// In en, this message translates to:
  /// **'Midnight Sky'**
  String get item_wall_default;

  /// No description provided for @item_wall_purple.
  ///
  /// In en, this message translates to:
  /// **'Nebula Purple'**
  String get item_wall_purple;

  /// No description provided for @item_wall_teal.
  ///
  /// In en, this message translates to:
  /// **'Deep Abyss'**
  String get item_wall_teal;

  /// No description provided for @item_wall_red.
  ///
  /// In en, this message translates to:
  /// **'Crimson Velvet'**
  String get item_wall_red;

  /// No description provided for @item_wall_grey.
  ///
  /// In en, this message translates to:
  /// **'Dark Slate'**
  String get item_wall_grey;

  /// No description provided for @item_wall_black.
  ///
  /// In en, this message translates to:
  /// **'Void Black'**
  String get item_wall_black;

  /// No description provided for @item_wall_sunset.
  ///
  /// In en, this message translates to:
  /// **'Warm Sunset'**
  String get item_wall_sunset;

  /// No description provided for @item_wall_matrix.
  ///
  /// In en, this message translates to:
  /// **'Binary Green'**
  String get item_wall_matrix;

  /// No description provided for @item_floor_default.
  ///
  /// In en, this message translates to:
  /// **'Polished Oak'**
  String get item_floor_default;

  /// No description provided for @item_floor_marble.
  ///
  /// In en, this message translates to:
  /// **'Ice Marble'**
  String get item_floor_marble;

  /// No description provided for @item_floor_stone.
  ///
  /// In en, this message translates to:
  /// **'Volcanic Rock'**
  String get item_floor_stone;

  /// No description provided for @item_floor_carpet.
  ///
  /// In en, this message translates to:
  /// **'Plush Velvet'**
  String get item_floor_carpet;

  /// No description provided for @item_floor_gold.
  ///
  /// In en, this message translates to:
  /// **'Gilded Floor'**
  String get item_floor_gold;

  /// No description provided for @item_floor_grass.
  ///
  /// In en, this message translates to:
  /// **'Overgrown'**
  String get item_floor_grass;

  /// No description provided for @item_plant_none.
  ///
  /// In en, this message translates to:
  /// **'No Decor'**
  String get item_plant_none;

  /// No description provided for @item_plant_fern.
  ///
  /// In en, this message translates to:
  /// **'Forest Fern'**
  String get item_plant_fern;

  /// No description provided for @item_plant_bamboo.
  ///
  /// In en, this message translates to:
  /// **'Zen Stalks'**
  String get item_plant_bamboo;

  /// No description provided for @item_plant_tree.
  ///
  /// In en, this message translates to:
  /// **'Ancient Bonsai'**
  String get item_plant_tree;

  /// No description provided for @item_plant_lotus.
  ///
  /// In en, this message translates to:
  /// **'Sacred Lotus'**
  String get item_plant_lotus;

  /// No description provided for @item_plant_cactus.
  ///
  /// In en, this message translates to:
  /// **'Desert Spike'**
  String get item_plant_cactus;

  /// No description provided for @item_lamp_none.
  ///
  /// In en, this message translates to:
  /// **'Natural Light'**
  String get item_lamp_none;

  /// No description provided for @item_lamp_classic.
  ///
  /// In en, this message translates to:
  /// **'Ambient Shade'**
  String get item_lamp_classic;

  /// No description provided for @item_lamp_modern.
  ///
  /// In en, this message translates to:
  /// **'Plasma Bulb'**
  String get item_lamp_modern;

  /// No description provided for @item_lamp_sun.
  ///
  /// In en, this message translates to:
  /// **'Solar Flare'**
  String get item_lamp_sun;

  /// No description provided for @item_lamp_torch.
  ///
  /// In en, this message translates to:
  /// **'Dungeon Fire'**
  String get item_lamp_torch;

  /// No description provided for @item_lamp_neon.
  ///
  /// In en, this message translates to:
  /// **'Neon Vibes'**
  String get item_lamp_neon;

  /// No description provided for @item_rug_none.
  ///
  /// In en, this message translates to:
  /// **'Bare Floor'**
  String get item_rug_none;

  /// No description provided for @item_rug_shag.
  ///
  /// In en, this message translates to:
  /// **'Comfy Shag'**
  String get item_rug_shag;

  /// No description provided for @item_rug_round.
  ///
  /// In en, this message translates to:
  /// **'Mystic Circle'**
  String get item_rug_round;

  /// No description provided for @item_rug_geometric.
  ///
  /// In en, this message translates to:
  /// **'Geometric Mat'**
  String get item_rug_geometric;

  /// No description provided for @item_rug_royal.
  ///
  /// In en, this message translates to:
  /// **'Royal Tapestry'**
  String get item_rug_royal;

  /// No description provided for @item_rug_persian.
  ///
  /// In en, this message translates to:
  /// **'Grand Persian'**
  String get item_rug_persian;

  /// No description provided for @item_paint_none.
  ///
  /// In en, this message translates to:
  /// **'Empty Wall'**
  String get item_paint_none;

  /// No description provided for @item_paint_abstract.
  ///
  /// In en, this message translates to:
  /// **'Modern Chaos'**
  String get item_paint_abstract;

  /// No description provided for @item_paint_surreal.
  ///
  /// In en, this message translates to:
  /// **'Surreal Dream'**
  String get item_paint_surreal;

  /// No description provided for @item_paint_portrait.
  ///
  /// In en, this message translates to:
  /// **'Noble Ancestor'**
  String get item_paint_portrait;

  /// No description provided for @item_paint_landscape.
  ///
  /// In en, this message translates to:
  /// **'Mountain Peak'**
  String get item_paint_landscape;

  /// No description provided for @item_paint_starry.
  ///
  /// In en, this message translates to:
  /// **'Deep Cosmos'**
  String get item_paint_starry;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @removeAds.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get removeAds;

  /// No description provided for @removeAdsPurchased.
  ///
  /// In en, this message translates to:
  /// **'Ads Removed ✓'**
  String get removeAdsPurchased;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @supportDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Support the Developer'**
  String get supportDeveloper;

  /// No description provided for @tipSmall.
  ///
  /// In en, this message translates to:
  /// **'Small Tip  \$0.99'**
  String get tipSmall;

  /// No description provided for @tipMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium Tip  \$2.99'**
  String get tipMedium;

  /// No description provided for @tipLarge.
  ///
  /// In en, this message translates to:
  /// **'Large Tip  \$4.99'**
  String get tipLarge;

  /// No description provided for @purchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchase successful! Thank you 🙏'**
  String get purchaseSuccess;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get purchaseFailed;

  /// No description provided for @purchasePending.
  ///
  /// In en, this message translates to:
  /// **'Purchase pending…'**
  String get purchasePending;
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
      <String>['ar', 'en', 'es', 'fr', 'hi'].contains(locale.languageCode);

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
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
