import 'package:dream_sort/features/game/bloc/game_bloc.dart';
import 'package:dream_sort/features/game/widgets/dialogs/add_tube_dialog.dart';
import 'package:dream_sort/features/game/widgets/dialogs/hint_dialog.dart';
import 'package:dream_sort/features/game/widgets/dialogs/shuffle_dialog.dart';
import 'package:dream_sort/features/game/widgets/game_floating_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GameBottomControls extends StatelessWidget {
  const GameBottomControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 55,
      left: 16,
      right: 16,
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          const int addCost = 50;
          final canAffordAdd = state.coinCount >= addCost;
          final canAffordShuffle = state.coinCount >= 20;

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
                        disabled: !canAffordAdd,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AddTubeDialog(
                              cost: addCost,
                              onConfirm: () {
                                Navigator.pop(ctx);
                                context.read<GameBloc>().add(RequestHelp());
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
                              cost: 20,
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
                            '20',
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
              // Hint
              Column(
                children: [
                  GameFloatingButton(
                    icon: Icons.lightbulb_rounded,
                    disabled: state.coinCount < 25,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => HintDialog(
                          cost: 25,
                          onConfirm: () {
                            Navigator.pop(ctx);
                            context.read<GameBloc>().add(RequestHint());
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
                        '25',
                        style: TextStyle(
                          color: state.coinCount >= 25
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
