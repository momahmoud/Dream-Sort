import 'dart:ui';
import 'package:dream_sort/features/game/constants/reward_constants.dart';
import 'package:dream_sort/features/game/repo/game_repository.dart';
import 'package:dream_sort/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DailyRewardDialog extends StatelessWidget {
  final int streak;
  final int reward;
  final Future<void> Function() onClaim;

  const DailyRewardDialog({
    super.key,
    required this.streak,
    required this.reward,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1e3799).withValues(alpha: 0.8),
                  const Color(0xFF0c2461).withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with Glow
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.amber,
                      size: 90,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.dailyRewardTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.dailyStreak(streak),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/images/coin.svg',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '+$reward',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () async {
                    await onClaim();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFC107), Color(0xFFFF9800)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      l10n.claim,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> checkAndShow(
    BuildContext context,
    GameRepository repo,
  ) async {
    final now = DateTime.now();
    final lastLogin = repo.getLastLogin();

    int streak;
    int reward;
    bool shouldShow = false;

    // Simple logic: reward once per calendar day
    if (lastLogin != null) {
      final lastDate = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
      final nowDate = DateTime(now.year, now.month, now.day);

      if (nowDate.isAtSameMomentAs(lastDate)) {
        final streak = repo.getLoginStreak();
        final tomorrowReward = _calculateReward(streak + 1);
        if (context.mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.comeBackTomorrowForCoins(tomorrowReward),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return; // Already claimed today
      }

      streak = repo.getLoginStreak();
      if (nowDate.difference(lastDate).inDays == 1) {
        streak++;
      } else {
        streak = 1;
      }
      reward = _calculateReward(streak);
      shouldShow = true;
    } else {
      streak = 1;
      reward = RewardConstants.dailyRewardBase;
      shouldShow = true;
    }

    if (shouldShow && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => DailyRewardDialog(
          streak: streak,
          reward: reward,
          onClaim: () async {
            await repo.addCoins(reward);
            await repo.updateLoginData(streak, now);
          },
        ),
      );
    }
  }

  static int _calculateReward(int streak) {
    if (streak <= 1) return RewardConstants.dailyRewardBase;
    if (streak >= RewardConstants.dailyRewardMaxStreak) {
      return RewardConstants.dailyRewardCap;
    }
    return RewardConstants.dailyRewardBase +
        (streak - 1) * RewardConstants.dailyRewardStreakIncrement;
  }
}
