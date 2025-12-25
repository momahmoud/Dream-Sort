import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class MultiplayerControls extends StatelessWidget {
  final VoidCallback onFreezeP1; // Called by P2 (Top)
  final VoidCallback onFreezeP2; // Called by P1 (Bottom)
  final String time;

  const MultiplayerControls({
    super.key,
    required this.onFreezeP1,
    required this.onFreezeP2,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 60,
      color: Colors.black87,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Top Player Ability (Left side, Rotated for them)
          // They press this to Freeze Bottom Player
          RotatedBox(
            quarterTurns: 2,
            child: IconButton(
              icon: const Icon(Icons.ac_unit, color: Colors.cyanAccent),
              tooltip: l10n.freezeOpponent,
              onPressed: onFreezeP1,
            ),
          ),

          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              time,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Bottom Player Ability (Right side)
          // They press this to Freeze Top Player
          IconButton(
            icon: const Icon(Icons.ac_unit, color: Colors.cyanAccent),
            tooltip: l10n.freezeOpponent,
            onPressed: onFreezeP2,
          ),
        ],
      ),
    );
  }
}
