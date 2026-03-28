import 'package:dream_sort/features/game/bloc/game_bloc.dart';
import 'package:dream_sort/features/game/constants/reward_constants.dart';
import 'package:dream_sort/features/game/widgets/dialogs/add_tube_dialog.dart';
import 'package:dream_sort/features/game/widgets/dialogs/shuffle_dialog.dart';
import 'package:dream_sort/features/game/widgets/game_floating_button.dart';
import 'package:dream_sort/core/services/ads_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dream_sort/l10n/app_localizations.dart';

class GameBottomControls extends StatelessWidget {
  const GameBottomControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 1),
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          final addCost = RewardConstants.helpCost;
          final canAffordAdd = state.coinCount >= addCost;
          final canAffordShuffle =
              state.coinCount >= RewardConstants.shuffleCost;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2. Center Buttons (Add Tube & Shuffle)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Add Tube
                  Column(
                    children: [
                      GameFloatingButton(
                        icon: Icons.queue_rounded,
                        disabled:
                            false, // Always enabled so they can watch an ad
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AddTubeDialog(
                              cost: addCost,
                              onConfirm: () {
                                if (canAffordAdd) {
                                  Navigator.pop(ctx);
                                  context.read<GameBloc>().add(RequestHelp());
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.notEnoughCoinsWatchAd,
                                      ),
                                    ),
                                  );
                                }
                              },
                              onWatchAd: () {
                                Navigator.pop(ctx);
                                AdsService.showRewarded(
                                  onUserEarnedReward: (amount) {
                                    // Ad watched successfully
                                    context.read<GameBloc>().add(
                                      RequestHelp(free: true),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$addCost',
                            style: TextStyle(
                              color: canAffordAdd
                                  ? const Color(0xFFFFC107)
                                  : Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  offset: const Offset(1, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          SvgPicture.asset(
                            'assets/images/coin.svg',
                            width: 16,
                            height: 16,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Shuffle
                  Column(
                    children: [
                      GameFloatingButton(
                        icon: Icons.shuffle_rounded,
                        disabled: !canAffordShuffle,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => ShuffleDialog(
                              cost: RewardConstants.shuffleCost,
                              onConfirm: () {
                                Navigator.pop(ctx);
                                context.read<GameBloc>().add(RequestShuffle());
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${RewardConstants.shuffleCost}',
                            style: TextStyle(
                              color: canAffordShuffle
                                  ? const Color(0xFFFFC107)
                                  : Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  offset: const Offset(1, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          SvgPicture.asset(
                            'assets/images/coin.svg',
                            width: 16,
                            height: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              // Hint — no confirmation dialog, fires immediately
              Column(
                children: [
                  GameFloatingButton(
                    icon: Icons.lightbulb_rounded,
                    disabled: state.coinCount < RewardConstants.hintCost,
                    onTap: () {
                      context.read<GameBloc>().add(RequestHint());
                    },
                  ),
                  const SizedBox(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${RewardConstants.hintCost}',
                        style: TextStyle(
                          color: state.coinCount >= RewardConstants.hintCost
                              ? const Color(0xFFFFC107)
                              : Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.8),
                              offset: const Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      SvgPicture.asset(
                        'assets/images/coin.svg',
                        width: 16,
                        height: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
