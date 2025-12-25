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
  String get selectLevel => 'Select Level';

  @override
  String get level => 'Level';

  @override
  String get renovateRoom => 'Renovate Room';

  @override
  String notEnoughStars(int cost) {
    return 'Not enough stars! Need $cost stars.';
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
      'This will delete all your stars, items, and level progress. This cannot be undone.';

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
}
