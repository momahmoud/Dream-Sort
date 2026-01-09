import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'game_action_dialog.dart';

class ShuffleDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final int cost;

  const ShuffleDialog({super.key, required this.onConfirm, required this.cost});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GameActionDialog(
      title: l10n.shuffleTitle,
      description: l10n.shuffleDesc,
      icon: const Icon(Icons.shuffle_rounded, color: Colors.blue, size: 40),
      borderColor: Colors.blue,
      actionLabel: l10n.shuffleAction,
      actionIconData: Icons.shuffle_rounded,
      actionGradientColors: const [Color(0xFF2196F3), Color(0xFF1976D2)],
      actionShadowColor: Colors.blue,
      onAction: onConfirm,
      cost:
          ')', // The generic dialog adds the icon, but logic might vary lightly. For now, strict adherence.
      // Wait, in GamePage, it was `Text(l10n.shuffleAction) ... Text(')')`.
      // In AddTube it was cost then ')'.
      // My GameActionDialog logic: Text(actionLabel) ... Text(cost).
      // If I pass cost as "$cost)", it resolves.
      // Actually shuffle dialog had: "Shuffle (Icon) )" ? No "Shuffle (Coin) )"
      // Let's adjust to match visual: "Shuffle 20)" -> label="Shuffle", cost="20)"
      cancelLabel: l10n.cancel,
    );
  }
}
