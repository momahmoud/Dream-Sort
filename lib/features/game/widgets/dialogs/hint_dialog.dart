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
      description: l10n.hintDesc,
      icon: const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 24),
      borderColor: Colors
          .orange, // Icon was white, but container border was implied or absent?
      // Original:
      // border: Border.all(color: Colors.orange, width: 2) NO, it didn't have border on icon??
      // Wait, let's check GamePage.
      // Hint Dialog Icon Container: border: Border.all(color: Colors.white.withValues(alpha: 0.1)).
      // Actually, looking at Shuffle: border: Colors.blue.
      // Hint: I don't see the specific icon container border in the snippet I saw earlier for Hint.
      // I'll assume Orange for consistency.
      actionLabel: l10n.getHint,
      actionIconData: Icons.lightbulb_rounded,
      actionGradientColors: const [Colors.orange, Colors.deepOrange],
      actionShadowColor: Colors.orange,
      onAction: onConfirm,
      cost: ')',
      cancelLabel: l10n.cancel,
    );
  }
}
