import 'package:dream_sort/features/game/bloc/game_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/app_localizations.dart';

class WinOverlayWidget extends StatelessWidget {
  final VoidCallback onRestartTimer;

  const WinOverlayWidget({super.key, required this.onRestartTimer});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE94560), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE94560).withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 60),
            const SizedBox(height: 16),
            Text(
              l10n.dreamSorted,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            /* Text(
              l10n.levelComplete(_formatTime(elapsed)),
              style: const TextStyle(color: Colors.white70),
            ), */
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<GameBloc>().add(NextLevel());
                onRestartTimer();
              },
              child: Text(l10n.nextLevel),
            ),
          ],
        ),
      ),
    );
  }
}
