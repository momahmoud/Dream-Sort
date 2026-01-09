import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../l10n/app_localizations.dart';
import 'game_action_dialog.dart';

class TopupDialog extends StatelessWidget {
  final VoidCallback onWatchVideo;

  const TopupDialog({super.key, required this.onWatchVideo});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GameActionDialog(
      title: l10n.needMoreCoins,
      description: l10n.earnFreeCoins,
      icon: SvgPicture.asset('assets/images/coin.svg', width: 48, height: 48),
      borderColor: Colors.amber,
      actionLabel: 'Watch Video',
      actionIconData: Icons.play_circle_filled_rounded,
      actionGradientColors: const [Color(0xFFFFC107), Color(0xFFFF9800)],
      actionShadowColor: Colors.amber,
      onAction: onWatchVideo,
      cancelLabel: l10n.noThanks,
    );
  }
}
