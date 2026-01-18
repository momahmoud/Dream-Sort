import 'dart:math';

import 'package:dream_sort/core/audio/audio_controller.dart';
import 'package:dream_sort/features/game/bloc/game_bloc.dart';
import 'package:dream_sort/features/game/models/decor_models.dart';
import 'package:dream_sort/features/game/repo/game_repository.dart';
import 'package:dream_sort/features/game/widgets/confetti_overlay.dart';
import 'package:dream_sort/features/game/widgets/game_board.dart';
import 'package:dream_sort/features/game/widgets/room_view.dart';
import 'package:dream_sort/features/multiplayer/widgets/multiplayer_game_over_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:dream_sort/features/game/widgets/game_floating_button.dart';
import '../../../l10n/app_localizations.dart';

class MultiplayerGamePage extends StatefulWidget {
  final int levelId;

  const MultiplayerGamePage({super.key, required this.levelId});

  @override
  State<MultiplayerGamePage> createState() => _MultiplayerGamePageState();
}

class _MultiplayerGamePageState extends State<MultiplayerGamePage> {
  late int _sharedSeed;
  String? _winner;

  late GameBloc _blocP1;
  late GameBloc _blocP2;

  int _p1CompletedTubes = 0;
  int _p2CompletedTubes = 0;

  @override
  void initState() {
    super.initState();

    // Lock to landscape and hide system UI for fullscreen immersive experience
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _sharedSeed = Random().nextInt(100000);

    // Initialize Blocs
    final repo = context.read<GameRepository>();
    final audio = context.read<AudioController>();

    _blocP1 = GameBloc(repo: repo, audio: audio)
      ..add(LoadLevel(levelId: widget.levelId, seed: _sharedSeed));

    _blocP2 = GameBloc(repo: repo, audio: audio)
      ..add(LoadLevel(levelId: widget.levelId, seed: _sharedSeed));
  }

  @override
  void dispose() {
    // Restore orientation and system UI when leaving
    // Allow all orientations for smooth transition back
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _blocP1.close();
    _blocP2.close();
    super.dispose();
  }

  void _handleWin(String player) {
    if (_winner != null) return; // Already won
    setState(() {
      _winner = player;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MultiplayerGameOverDialog(
        winner: player,
        onBackToMenu: () {
          Navigator.pop(context); // Close dialog
          Navigator.pop(context); // Close game page
        },
        onRematch: () {
          Navigator.pop(context); // Close dialog
          _restartGame();
        },
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _winner = null;
      _sharedSeed = Random().nextInt(100000);
      _p1CompletedTubes = 0;
      _p2CompletedTubes = 0;
    });

    // Reset Blocs
    _blocP1.add(LoadLevel(levelId: widget.levelId, seed: _sharedSeed));
    _blocP2.add(LoadLevel(levelId: widget.levelId, seed: _sharedSeed));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: Hive.box(
          'game_data',
        ).listenable(keys: ['equipped_items']),
        builder: (context, box, child) {
          final equippedMap = Map<String, String>.from(
            box.get('equipped_items', defaultValue: {}) as Map,
          );

          Color? tubeSkinColor;
          final tubeId = equippedMap['tube'];
          if (tubeId != null) {
            try {
              final item = DecorationData.items.firstWhere(
                (i) => i.id == tubeId,
              );
              tubeSkinColor = Color(int.parse(item.assetPath));
            } catch (_) {}
          }

          return Stack(
            children: [
              // Shared Background
              RepaintBoundary(
                child: RoomView(equipped: equippedMap, showCenterVisual: false),
              ),

              // Dark overlay to make tubes pop
              Container(color: Colors.black.withValues(alpha: 0.3)),

              // Confetti (if won)
              if (_winner != null) const ConfettiOverlay(),

              // Main game layout - Horizontal side-by-side
              SafeArea(
                child: Row(
                  children: [
                    // PLAYER 1 (Left side, Rotated 180 degrees so they can play from the other side)
                    Expanded(
                      child: RotatedBox(
                        quarterTurns: 2,
                        child: BlocProvider.value(
                          value: _blocP1,
                          child: BlocListener<GameBloc, GameState>(
                            listener: (context, state) {
                              if (state.status == GameStatus.won) {
                                _handleWin('PLAYER 1');
                              }
                              // Attack Logic
                              if (state.completedTubeCount >
                                  _p1CompletedTubes) {
                                _p1CompletedTubes = state.completedTubeCount;
                                // Attack P2!
                                _blocP2.add(AddPenalty());
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.sentPenalty('PLAYER 1')),
                                    duration: const Duration(milliseconds: 500),
                                    backgroundColor: Colors.blueAccent,
                                  ),
                                );
                              }
                            },
                            child: RepaintBoundary(
                              child: Center(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: Colors.white24,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: GameBoard(
                                      onWin: () {}, // Handled by listener
                                      tubeSkinColor: tubeSkinColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // PLAYER 2 (Right side)
                    Expanded(
                      child: BlocProvider.value(
                        value: _blocP2,
                        child: BlocListener<GameBloc, GameState>(
                          listener: (context, state) {
                            if (state.status == GameStatus.won) {
                              _handleWin('PLAYER 2');
                            }
                            // Attack Logic
                            if (state.completedTubeCount > _p2CompletedTubes) {
                              _p2CompletedTubes = state.completedTubeCount;
                              // Attack P1!
                              _blocP1.add(AddPenalty());
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.sentPenalty('PLAYER 2')),
                                  duration: const Duration(milliseconds: 500),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                          child: RepaintBoundary(
                            child: Center(
                              child: Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: Colors.white24,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: GameBoard(
                                    onWin: () {}, // Handled by listener
                                    tubeSkinColor: tubeSkinColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Player 1 Label (Left side - rotated for their view)
              Positioned(
                left: 20,
                top: MediaQuery.of(context).size.height / 2 - 140,
                child: RotatedBox(
                  quarterTurns: 2,
                  child: _buildPlayerLabel(
                    player: 'P1',
                    color: Colors.blueAccent,
                    score: _p1CompletedTubes,
                  ),
                ),
              ),

              // Player 2 Label (Right side)
              Positioned(
                right: 20,
                bottom: MediaQuery.of(context).size.height / 2 - 140,
                child: _buildPlayerLabel(
                  player: 'P2',
                  color: Colors.redAccent,
                  score: _p2CompletedTubes,
                ),
              ),

              // Floating Center Controls
              // Positioned.fill(child: Center(child: _buildCenterControls(l10n))),

              // Back button (top-left corner)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                child: _buildFloatingButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
              ),

              // Restart button (top-right corner) -> NO, removing this global restart button since we now have per-player reset
              // Positioned(
              //   top: MediaQuery.of(context).padding.top + 8,
              //   right: 8,
              //   child: _buildFloatingButton(
              //     icon: Icons.refresh,
              //     onTap: _restartGame,
              //   ),
              // ),

              // P1 CONTROLS (Bottom Left - Rotated)
              Positioned(
                top: MediaQuery.of(context).padding.top + 30,
                right: 40,
                child: RotatedBox(
                  quarterTurns: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      // Undo
                      BlocProvider.value(
                        value: _blocP1,
                        child: BlocBuilder<GameBloc, GameState>(
                          builder: (context, state) {
                            return GameFloatingButton(
                              icon: Icons.undo_rounded,
                              disabled: state.history.isEmpty,
                              onTap: () => _blocP1.add(UndoMove()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Reset
                      GameFloatingButton(
                        icon: Icons.refresh_rounded,
                        onTap: () => _blocP1.add(ResetLevel()),
                      ),
                    ],
                  ),
                ),
              ),

              // P2 CONTROLS (Top Right - Normal)
              Positioned(
                bottom: MediaQuery.of(context).padding.top + 30,
                left: 30,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Undo
                    BlocProvider.value(
                      value: _blocP2,
                      child: BlocBuilder<GameBloc, GameState>(
                        builder: (context, state) {
                          return GameFloatingButton(
                            icon: Icons.undo_rounded,
                            disabled: state.history.isEmpty,
                            onTap: () => _blocP2.add(UndoMove()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Reset
                    GameFloatingButton(
                      icon: Icons.refresh_rounded,
                      onTap: () => _blocP2.add(ResetLevel()),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildPlayerLabel({
    required String player,
    required Color color,
    required int score,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            player,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              shadows: [Shadow(color: color, blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                const SizedBox(width: 4),
                Text(
                  '$score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
