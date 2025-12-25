import 'package:dream_sort/core/theme/app_theme.dart';
import 'package:dream_sort/features/game/view/decor_page.dart';
import 'package:dream_sort/features/game/view/game_page.dart';
import 'package:dream_sort/features/game/view/levels_page.dart';
import 'package:dream_sort/features/game/widgets/home_button.dart';
import 'package:dream_sort/features/multiplayer/view/multiplayer_menu_page.dart';
import 'package:dream_sort/features/settings/view/settings_page.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          // Background (Reused styling or better)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.blur_on, color: AppTheme.accent, size: 80),
                  const SizedBox(height: 16),
                  Text(
                    l10n.appTitle,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 8),
                  Text(
                    l10n.subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 16),
                  ),

                  const SizedBox(height: 60),

                  // SETTINGS BUTTON
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white54),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                  ),

                  // PLAY BUTTON
                  HomeButton(
                    label: l10n.play,
                    icon: Icons.play_arrow,
                    onTap: () {
                      // Go to GamePage with Max Level (Default)
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GamePage()),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // LEVELS BUTTON
                  HomeButton(
                    label: l10n.levels,
                    icon: Icons.grid_view,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LevelsPage()),
                      );
                    },
                    color: AppTheme.primary,
                  ),

                  const SizedBox(height: 20),

                  // DECORATOR BUTTON (Shortcut)
                  HomeButton(
                    label: l10n.room,
                    icon: Icons.palette,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DecorPage()),
                      );
                    },
                    color: Colors.purple.shade700,
                  ),

                  const SizedBox(height: 20),

                  // MULTIPLAYER BUTTON
                  HomeButton(
                    label: l10n.multiplayer,
                    icon: Icons.groups,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MultiplayerMenuPage(),
                        ),
                      );
                    },
                    color: Colors.teal.shade700,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
