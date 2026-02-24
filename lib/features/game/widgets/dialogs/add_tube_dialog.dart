import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'game_action_dialog.dart';

class AddTubeDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onWatchAd;
  final int cost;

  const AddTubeDialog({
    super.key,
    required this.onConfirm,
    required this.onWatchAd,
    required this.cost,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GameActionDialog(
      title: l10n.needHelp,
      description: l10n.addTubeDesc,
      icon: const Icon(Icons.science_rounded, color: Colors.green, size: 40),
      borderColor: Colors.green,
      actionLabel: l10n.addTube,
      actionIconData: Icons.add_circle_outline_rounded,
      actionGradientColors: const [Color(0xFF4CAF50), Color(0xFF2E7D32)],
      actionShadowColor: Colors.green,
      onAction: onConfirm,
      cost: '$cost)',
      cancelLabel: l10n.noThanks,
      onSecondaryAction: onWatchAd,
      secondaryActionLabel: l10n.watchAd,
      secondaryActionIconData: Icons.play_circle_outline_rounded,
    );
  }
}
