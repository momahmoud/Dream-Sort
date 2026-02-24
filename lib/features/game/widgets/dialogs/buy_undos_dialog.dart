import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'game_action_dialog.dart';

class BuyUndosDialog extends StatelessWidget {
  final int cost;
  final int count;
  final VoidCallback onConfirm;
  final VoidCallback onWatchAd;

  const BuyUndosDialog({
    super.key,
    required this.cost,
    required this.count,
    required this.onConfirm,
    required this.onWatchAd,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GameActionDialog(
      title: l10n.outOfUndosTitle,
      description: l10n.outOfUndosDesc(count),
      icon: const Icon(Icons.undo_rounded, color: Colors.white, size: 36),
      borderColor: Colors.purpleAccent,
      actionLabel: l10n.buyUndos(count, cost),
      actionIconData: Icons.undo_rounded,
      actionGradientColors: const [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
      actionShadowColor: Colors.purple,
      onAction: onConfirm,
      cost: cost.toString(),
      secondaryActionLabel: l10n.watchAdFreeUndos(count),
      secondaryActionIconData: Icons.play_circle_outline_rounded,
      onSecondaryAction: onWatchAd,
      cancelLabel: l10n.cancel,
    );
  }
}
