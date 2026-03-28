// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dream Sort';

  @override
  String get play => 'PLAY';

  @override
  String get levels => 'LEVELS';

  @override
  String get room => 'ROOM';

  @override
  String get multiplayer => 'MULTIPLAYER';

  @override
  String get dailyChallenge => 'DAILY CHALLENGE';

  @override
  String get muteSound => 'Mute Sound';

  @override
  String get unmuteSound => 'Unmute Sound';

  @override
  String get decorShop => 'Decor Shop';

  @override
  String get howToPlay => 'How to Play';

  @override
  String get quitGame => 'Quit Game';

  @override
  String get quitGameDesc =>
      'Your progress will be lost. Are you sure you want to leave?';

  @override
  String get quitGameAction => 'Quit';

  @override
  String get keepPlaying => 'Keep Playing';

  @override
  String get selectLevel => 'Select Level';

  @override
  String get level => 'Level';

  @override
  String get renovateRoom => 'Renovate Room';

  @override
  String notEnoughCoins(int cost) {
    return 'Not enough coins! Need $cost coins.';
  }

  @override
  String get owned => 'OWNED';

  @override
  String get equipped => 'EQUIPPED';

  @override
  String get gameOver => 'GAME OVER';

  @override
  String wins(String player) {
    return '$player WINS!';
  }

  @override
  String time(String time) {
    return 'Time: $time';
  }

  @override
  String get backToMenu => 'Back to Menu';

  @override
  String get rematch => 'Rematch';

  @override
  String get vsBattle => '1 vs 1 Battle';

  @override
  String sentPenalty(String player) {
    return '$player sent a penalty!';
  }

  @override
  String frozeOpponent(String attacker, String victim) {
    return '$attacker Froze $victim!';
  }

  @override
  String get freezeOpponent => 'Freeze Opponent';

  @override
  String levelComplete(String time) {
    return 'Level Complete in $time';
  }

  @override
  String get nextLevel => 'Next Level';

  @override
  String get dreamSorted => 'DREAM SORTED!';

  @override
  String get notifDailyTitle => '🎁 Daily Bonus Ready!';

  @override
  String get notifDailyBody => 'Your daily reward is waiting. Come collect it!';

  @override
  String get rewardBase => 'Base';

  @override
  String get rewardUndoBonus => 'Undo Bonus';

  @override
  String get rewardTimeBonus => 'Time Bonus';

  @override
  String get rewardComboBonus => 'Combo Bonus';

  @override
  String levelTitle(int level) {
    return 'Level $level';
  }

  @override
  String get menu => 'Menu';

  @override
  String get tapToPick => 'Tap a tube to pick up the top ball.';

  @override
  String get tapToDrop => 'Tap another tube to drop it.';

  @override
  String get sameColorStack => 'You can only stack balls of the SAME color.';

  @override
  String get sortToWin => 'Sort all same-colored balls into one tube to win!';

  @override
  String get gotIt => 'Got it!';

  @override
  String get subtitle => 'A Relaxing Puzzle Game';

  @override
  String get multiplayerMode => 'Multiplayer Mode';

  @override
  String get challengeFriends => 'Challenge your friends!';

  @override
  String get createRoom => 'Create Room';

  @override
  String get joinRoom => 'Join Room';

  @override
  String get localVs => 'Local VS (Split Screen)';

  @override
  String get comingSoon => 'Multiplayer backend coming soon!';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get sound => 'Sound';

  @override
  String get music => 'Music';

  @override
  String get sfx => 'Sound Effects';

  @override
  String get resetProgress => 'Reset Progress';

  @override
  String get about => 'About';

  @override
  String get credits => 'Credits';

  @override
  String get resetConfirmTitle => 'Reset All Progress?';

  @override
  String get resetConfirmMessage =>
      'This will delete all your coins, items, and level progress. This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get progressReset => 'Progress has been reset.';

  @override
  String get chooseDifficulty => 'Choose difficulty for local vs';

  @override
  String get enterNameAndLevel => 'Enter your name and select level';

  @override
  String get playerName => 'Player Name';

  @override
  String get enterRoomDetails => 'Enter room details to join';

  @override
  String get yourName => 'Your Name';

  @override
  String get roomCodeHint => 'Room Code (e.g. ABCD)';

  @override
  String get create => 'Create';

  @override
  String get join => 'Join';

  @override
  String get accessibility => 'Accessibility';

  @override
  String get colorBlindMode => 'Color-Blind Symbols';

  @override
  String get perfect => 'PERFECT!';

  @override
  String get resetLevelTitle => 'Restart Level?';

  @override
  String get resetLevelDesc =>
      'Your progress will be lost and undos will reset.';

  @override
  String get resetLevelAction => 'Restart';

  @override
  String get outOfUndosTitle => 'Out of Undos!';

  @override
  String outOfUndosDesc(int count) {
    return 'Buy $count more undos to keep going.';
  }

  @override
  String buyUndos(int count, int cost) {
    return 'Buy $count Undos ($cost coins)';
  }

  @override
  String watchAdFreeUndos(int count) {
    return 'Watch Ad — Free $count Undos';
  }

  @override
  String get needHelp => 'Need Help?';

  @override
  String get addTubeDesc =>
      'Add an extra empty tube to make\nsolving this puzzle easier!';

  @override
  String get addTube => 'Add Tube';

  @override
  String get shuffleTitle => 'Shuffle?';

  @override
  String get shuffleDesc =>
      'Rearrange balls to find new moves!\n(Completed tubes stay safe)';

  @override
  String shuffleAction(int cost) {
    return 'Shuffle ($cost)';
  }

  @override
  String get watchVideo => 'Watch Video';

  @override
  String get watchAd => 'Watch Ad';

  @override
  String get notEnoughCoinsWatchAd => 'Not enough coins! Watch an ad instead.';

  @override
  String get watchAdPlus50Coins => 'Watch Ad +25 Coins';

  @override
  String get earnFreeCoins =>
      'Watch a short video to instantly earn\n+25 Free Coins!';

  @override
  String get noThanks => 'No, thanks';

  @override
  String get needMoreCoins => 'Need More Coins?';

  @override
  String get needHint => 'Need a Hint?';

  @override
  String hintDesc(int cost) {
    return 'Stuck? Let the AI find the best move for you!\nCost: $cost Coins.';
  }

  @override
  String getHint(int cost) {
    return 'Get Hint ($cost)';
  }

  @override
  String get undoText => 'Undo';

  @override
  String earnedCoins(Object amount) {
    return 'You earned $amount ';
  }

  @override
  String get dailyRewardTitle => 'Daily Reward';

  @override
  String dailyStreak(int streak) {
    return 'Day $streak Streak';
  }

  @override
  String get claim => 'CLAIM';

  @override
  String comeBackTomorrowForCoins(int amount) {
    return 'Come back tomorrow for $amount coins!';
  }

  @override
  String get decorTypeTube => 'Tubes';

  @override
  String get decorTypeBall => 'Balls';

  @override
  String get decorTypeWall => 'Walls';

  @override
  String get decorTypeFloor => 'Floors';

  @override
  String get decorTypePlant => 'Plants';

  @override
  String get decorTypeLamp => 'Lamps';

  @override
  String get decorTypeRug => 'Rugs';

  @override
  String get decorTypePainting => 'Arts';

  @override
  String get item_tube_default => 'Glass Vials';

  @override
  String get item_tube_bamboo => 'Zen Bamboo';

  @override
  String get item_tube_metal => 'Cyber Alloy';

  @override
  String get item_tube_gold_rim => 'Royal Gold';

  @override
  String get item_tube_crystal => 'Ice Crystal';

  @override
  String get item_tube_magma => 'Magma Forge';

  @override
  String get item_ball_default => 'Smooth Spheres';

  @override
  String get item_ball_neon => 'Neon Orbs';

  @override
  String get item_ball_emoji => 'Emoji Faces';

  @override
  String get item_ball_jewel => 'Precious Jewels';

  @override
  String get item_ball_planets => 'Galaxy Planets';

  @override
  String get item_ball_sports => 'Sports Pack';

  @override
  String get item_wall_default => 'Midnight Sky';

  @override
  String get item_wall_purple => 'Nebula Purple';

  @override
  String get item_wall_teal => 'Deep Abyss';

  @override
  String get item_wall_red => 'Crimson Velvet';

  @override
  String get item_wall_grey => 'Dark Slate';

  @override
  String get item_wall_black => 'Void Black';

  @override
  String get item_wall_sunset => 'Warm Sunset';

  @override
  String get item_wall_matrix => 'Binary Green';

  @override
  String get item_floor_default => 'Polished Oak';

  @override
  String get item_floor_marble => 'Ice Marble';

  @override
  String get item_floor_stone => 'Volcanic Rock';

  @override
  String get item_floor_carpet => 'Plush Velvet';

  @override
  String get item_floor_gold => 'Gilded Floor';

  @override
  String get item_floor_grass => 'Overgrown';

  @override
  String get item_plant_none => 'No Decor';

  @override
  String get item_plant_fern => 'Forest Fern';

  @override
  String get item_plant_bamboo => 'Zen Stalks';

  @override
  String get item_plant_tree => 'Ancient Bonsai';

  @override
  String get item_plant_lotus => 'Sacred Lotus';

  @override
  String get item_plant_cactus => 'Desert Spike';

  @override
  String get item_lamp_none => 'Natural Light';

  @override
  String get item_lamp_classic => 'Ambient Shade';

  @override
  String get item_lamp_modern => 'Plasma Bulb';

  @override
  String get item_lamp_sun => 'Solar Flare';

  @override
  String get item_lamp_torch => 'Dungeon Fire';

  @override
  String get item_lamp_neon => 'Neon Vibes';

  @override
  String get item_rug_none => 'Bare Floor';

  @override
  String get item_rug_shag => 'Comfy Shag';

  @override
  String get item_rug_round => 'Mystic Circle';

  @override
  String get item_rug_geometric => 'Geometric Mat';

  @override
  String get item_rug_royal => 'Royal Tapestry';

  @override
  String get item_rug_persian => 'Grand Persian';

  @override
  String get item_paint_none => 'Empty Wall';

  @override
  String get item_paint_abstract => 'Modern Chaos';

  @override
  String get item_paint_surreal => 'Surreal Dream';

  @override
  String get item_paint_portrait => 'Noble Ancestor';

  @override
  String get item_paint_landscape => 'Mountain Peak';

  @override
  String get item_paint_starry => 'Deep Cosmos';

  @override
  String get shareApp => 'Share App';

  @override
  String get removeAds => 'Remove Ads';

  @override
  String get removeAdsPurchased => 'Ads Removed ✓';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get supportDeveloper => 'Support the Developer';

  @override
  String get tipSmall => 'Small Tip  \$0.99';

  @override
  String get tipMedium => 'Medium Tip  \$2.99';

  @override
  String get tipLarge => 'Large Tip  \$4.99';

  @override
  String get purchaseSuccess => 'Purchase successful! Thank you 🙏';

  @override
  String get purchaseFailed => 'Purchase failed. Please try again.';

  @override
  String get purchasePending => 'Purchase pending…';
}
