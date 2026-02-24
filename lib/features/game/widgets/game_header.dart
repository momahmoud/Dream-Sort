import 'package:dream_sort/core/services/ads_service.dart';
import 'package:dream_sort/features/game/bloc/game_bloc.dart';
import 'package:dream_sort/features/game/constants/reward_constants.dart';
import 'package:dream_sort/features/game/widgets/dialogs/buy_undos_dialog.dart';
import 'package:dream_sort/features/game/widgets/dialogs/game_action_dialog.dart';
import 'package:dream_sort/features/game/widgets/dialogs/topup_dialog.dart';
import 'package:dream_sort/features/game/widgets/game_menu_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../l10n/app_localizations.dart';

class GameHeader extends StatelessWidget implements PreferredSizeWidget {
  const GameHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _showBuyUndosDialog(BuildContext context, GameBloc bloc) {
    showDialog(
      context: context,
      builder: (_) => BuyUndosDialog(
        cost: RewardConstants.undoPackCost,
        count: RewardConstants.undoPackCount,
        onConfirm: () {
          Navigator.of(context).pop();
          bloc.add(const BuyUndos());
        },
        onWatchAd: () {
          Navigator.of(context).pop();
          AdsService.showRewarded(
            onUserEarnedReward: (_) => bloc.add(const BuyUndos(free: true)),
          );
        },
      ),
    );
  }

  void _showMenuBottomSheet(BuildContext context, GameBloc bloc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          BlocProvider.value(value: bloc, child: const GameMenuSheet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final gameBloc = context.read<GameBloc>();

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 1.0],
          ),
        ),
      ),
      title: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          return Text(
            'L.V ${state.levelId}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          );
        },
      ),
      actions: [
        const SizedBox(width: 8),
        // Undo
        BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            final noHistory = state.moveHistory.isEmpty;
            final depleted = state.remainingUndos <= 0;
            final isDisabled = noHistory;
            final bloc = context.read<GameBloc>();
            return GestureDetector(
              onTap: isDisabled
                  ? null
                  : depleted
                  ? () => _showBuyUndosDialog(context, bloc)
                  : () => bloc.add(UndoMove()),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isDisabled ? 0.3 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: depleted && !isDisabled
                        ? Colors.purple.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: depleted && !isDisabled
                          ? Colors.purpleAccent.withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        depleted && !isDisabled
                            ? Icons.undo_rounded
                            : Icons.undo_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        depleted && !isDisabled
                            ? '+'
                            : '${state.remainingUndos}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 8),
        BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            final bloc = context.read<GameBloc>();
            return GestureDetector(
              onTap: () {
                if (state.moveHistory.isEmpty) {
                  bloc.add(ResetLevel());
                  return;
                }
                final l10n = AppLocalizations.of(context)!;
                showDialog(
                  context: context,
                  builder: (_) => GameActionDialog(
                    title: l10n.resetLevelTitle,
                    description: l10n.resetLevelDesc,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                    borderColor: Colors.orange,
                    actionLabel: l10n.resetLevelAction,
                    actionIconData: Icons.refresh_rounded,
                    actionGradientColors: const [
                      Color(0xFFFF6B35),
                      Color(0xFFE64A19),
                    ],
                    actionShadowColor: Colors.deepOrange,
                    onAction: () {
                      Navigator.of(context).pop();
                      bloc.add(ResetLevel());
                    },
                    cancelLabel: l10n.cancel,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),

        // Star Badge
        BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            return Center(
              child: GestureDetector(
                onTap: () {
                  if (!AdsService.isEnabled) return;
                  showDialog(
                    context: context,
                    builder: (ctx) => TopupDialog(
                      onWatchVideo: () {
                        Navigator.pop(ctx);
                        AdsService.showRewarded(
                          onUserEarnedReward: (amount) {
                            final reward = RewardConstants.rewardedAdCoins;
                            if (context.mounted) {
                              context.read<GameBloc>().add(AddCurrency(reward));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Text(l10n.earnedCoins(reward)),
                                      SvgPicture.asset(
                                        'assets/images/coin.svg',
                                        width: 16,
                                        height: 16,
                                      ),
                                      const Text('!'),
                                    ],
                                  ),
                                  backgroundColor: Colors.amber,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 3,
                    bottom: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/images/coin.svg',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${state.coinCount}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (AdsService.isEnabled) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Menu Button
        IconButton(
          icon: const Icon(Icons.grid_view_rounded),
          tooltip: l10n.menu,
          color: Colors.white,
          onPressed: () => _showMenuBottomSheet(context, gameBloc),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
