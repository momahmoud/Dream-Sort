import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'game_action_dialog.dart';

class HintDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final int cost;

  const HintDialog({super.key, required this.onConfirm, required this.cost});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GameActionDialog(
      title: l10n.needHint,
      description: l10n.hintDesc(cost),
      icon: const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 24),
      borderColor: Colors.orange,
      actionLabel: l10n.getHint(cost),
      actionIconData: Icons.lightbulb_rounded,
      actionGradientColors: const [Colors.orange, Colors.deepOrange],
      actionShadowColor: Colors.orange,
      onAction: onConfirm,
      cost: cost.toString(),
      cancelLabel: l10n.cancel,
    );
  }
}
