import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class MultiplayerGameOverDialog extends StatelessWidget {
  final String winner;
  final VoidCallback onRematch;
  final VoidCallback onBackToMenu;

  const MultiplayerGameOverDialog({
    super.key,
    required this.winner,
    required this.onRematch,
    required this.onBackToMenu,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: const Color(0xFF16213E),
      title: Text(l10n.gameOver, style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
          const SizedBox(height: 16),
          Text(
            l10n.wins(winner),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Text(l10n.time(time), style: const TextStyle(color: Colors.white70)),
        ],
      ),
      actions: [
        TextButton(onPressed: onBackToMenu, child: Text(l10n.backToMenu)),
        ElevatedButton(onPressed: onRematch, child: Text(l10n.rematch)),
      ],
    );
  }
}
