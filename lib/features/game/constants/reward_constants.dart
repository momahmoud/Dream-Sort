/// Central place for game economy and level win reward constants.
/// Keeps bloc logic and win overlay UI in sync.
class RewardConstants {
  RewardConstants._();

  // --- Level win: base ---
  static const int baseRewardNormal = 10;
  static const int baseRewardDaily = 40;

  // --- Level win: undo bonus (perfect = 0 undos, good = 1–2 undos) ---
  static const int undoBonusPerfectNormal = 10;
  static const int undoBonusPerfectDaily = 20;
  static const int undoBonusGoodNormal = 5;
  static const int undoBonusGoodDaily = 10;
  static const int undoGoodMaxUndos = 2;

  // --- Level win: time bonus ---
  static const int timeBonusFastSeconds = 45;
  static const int timeBonusFast = 15;
  static const int timeBonusGoodSeconds = 90;
  static const int timeBonusGood = 10;

  // --- Combo rewards (tubes completed in a row) ---
  static const int comboThreshold3 = 3;
  static const int comboRewardAt3 = 5;
  static const int comboThreshold5 = 5;
  static const int comboRewardAt5 = 10;
  static const int comboThreshold8 = 8;
  static const int comboRewardAt8 = 10;

  // --- Powerup costs ---
  static const int hintCost = 20;
  static const int shuffleCost = 25;
  static const int helpCost = 60;
  static const int undoPackCost = 15; // cost to buy a pack of extra undos
  static const int undoPackCount = 3; // undos granted per purchase

  // --- Rewarded ad ---
  static const int rewardedAdCoins = 25;

  // --- Win-after-shuffle / win-after-help bonus ---
  static const int winAfterPowerupBonus = 10;

  // --- Starting coins (default in repo) ---
  static const int startingCoins = 100;

  // --- Daily login ---
  static const int dailyRewardBase = 25;
  static const int dailyRewardStreakIncrement = 10;
  static const int dailyRewardMaxStreak = 7;
  static const int dailyRewardCap = 100;

  // --- Pressure mode (level gate) ---
  static const int pressureModeMinLevel = 40;
}
