import 'package:dream_sort/core/audio/audio_controller.dart';
import 'package:dream_sort/features/game/bloc/game_bloc.dart';
import 'package:dream_sort/features/game/models/decor_models.dart';
import 'package:dream_sort/features/game/repo/game_repository.dart';
import 'package:dream_sort/features/game/widgets/confetti_overlay.dart';
import 'package:dream_sort/features/game/widgets/game_board.dart';
import 'package:dream_sort/features/game/widgets/room_view.dart';
import 'package:dream_sort/features/multiplayer/models/multiplayer_room.dart';
import 'package:dream_sort/features/multiplayer/repository/multiplayer_repository.dart';
import 'package:dream_sort/features/multiplayer/widgets/multiplayer_game_over_dialog.dart';
import 'package:dream_sort/features/game/widgets/game_floating_button.dart';
import 'package:dream_sort/features/multiplayer/widgets/remote_game_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OnlineMultiplayerGamePage extends StatefulWidget {
  final MultiplayerRepository repository;
  final MultiplayerRoom initialRoom;
  final String playerId;

  const OnlineMultiplayerGamePage({
    super.key,
    required this.repository,
    required this.initialRoom,
    required this.playerId,
  });

  @override
  State<OnlineMultiplayerGamePage> createState() =>
      _OnlineMultiplayerGamePageState();
}

class _OnlineMultiplayerGamePageState extends State<OnlineMultiplayerGamePage> {
  late GameBloc _gameBloc;
  String? _winner;
  int _completedTubes = 0;

  @override
  void initState() {
    super.initState();

    // Lock to landscape and hide system UI for fullscreen immersive experience
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final repo = context.read<GameRepository>();
    final audio = context.read<AudioController>();

    // Init Logic with the SHARED seed from the room
    _gameBloc = GameBloc(repo: repo, audio: audio)
      ..add(
        LoadLevel(
          levelId: widget.initialRoom.levelId,
          seed: widget.initialRoom.seed,
        ),
      );
  }

  @override
  void dispose() {
    // Restore orientation and system UI when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _gameBloc.close();
    super.dispose();
  }

  void _handleWin(String playerWrapper) {
    if (_winner != null) return;
    setState(() {
      _winner = playerWrapper;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MultiplayerGameOverDialog(
        winner: playerWrapper,
        onBackToMenu: () {
          widget.repository.leaveRoom();
          Navigator.pop(dialogContext); // Close dialog
          Navigator.pop(context); // Close game page
        },
        onRematch: () {
          Navigator.pop(dialogContext); // Close dialog
          _restartGame();
        },
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _winner = null;
      _completedTubes = 0;
    });

    // Request rematch - reload with same seed for now
    _gameBloc.add(
      LoadLevel(
        levelId: widget.initialRoom.levelId,
        seed: widget.initialRoom.seed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              // Background
              RoomView(equipped: equippedMap, showCenterVisual: false),
              Container(color: Colors.black.withValues(alpha: 0.3)),
              if (_winner != null) const ConfettiOverlay(),

              // Game Area - Horizontal Split Screen
              // Game Area - Horizontal Split Screen
              SafeArea(
                child: Row(
                  children: [
                    // OPPONENT (Left side, Rotated 180 degrees)
                    Expanded(
                      child: StreamBuilder<MultiplayerRoom>(
                        stream: widget.repository.roomStream,
                        initialData: widget.repository.lastKnownRoom,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white24,
                              ),
                            );
                          }

                          final room = snapshot.data!;

                          // Check if opponent won (Global check logic moved here as side effect or separate listener?
                          // Better to just render. Win check can happen here visually or via a separate listener if needed for Dialogs.)
                          // For flickering, we strictly want to render the board.

                          final opponentEntry = room.players.entries.firstWhere(
                            (e) => e.key != widget.playerId,
                            orElse: () => MapEntry(
                              '',
                              MultiplayerPlayer(id: 'dummy', name: 'Opponent'),
                            ),
                          );
                          final opponent = opponentEntry.value;

                          return RotatedBox(
                            quarterTurns: 2,
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
                                child: RemoteGameBoard(
                                  tubes: opponent.board,
                                  tubeSkinColor: null,
                                  isFrozen: false,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // MY BOARD (Right side)
                    Expanded(
                      child: BlocProvider.value(
                        value: _gameBloc,
                        child: BlocListener<GameBloc, GameState>(
                          listener: (context, state) {
                            // Sync to Firebase (Only transmit, don't read)
                            widget.repository.updateBoard(
                              state.tubes,
                              state.completedTubeCount,
                            );

                            if (state.status == GameStatus.won) {
                              _handleWin('YOU');
                            }

                            // Attack Logic check
                            if (state.completedTubeCount > _completedTubes) {
                              _completedTubes = state.completedTubeCount;
                            }
                          },
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
                                onWin: () {},
                                tubeSkinColor: tubeSkinColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Opponent Label (Left side - rotated)
              Positioned(
                left: 20,
                top: MediaQuery.of(context).size.height / 2 - 40,
                child: RotatedBox(
                  quarterTurns: 2,
                  child: _buildPlayerLabel(
                    player: 'OPP',
                    color: Colors.redAccent,
                  ),
                ),
              ),

              // My Label (Right side)
              Positioned(
                right: 20,
                bottom: MediaQuery.of(context).size.height / 2 - 40,
                child: _buildPlayerLabel(
                  player: 'YOU',
                  color: Colors.blueAccent,
                ),
              ),

              // Center VS indicator
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Text(
                      'VS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ),

              // Back button (top-left corner)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                child: _buildFloatingButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () {
                    widget.repository.leaveRoom();
                    Navigator.pop(context);
                  },
                ),
              ),

              // Room code (top-center)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Room: ${widget.initialRoom.code}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),

              // PLAYER CONTROLS (Bottom Right)
              Positioned(
                bottom: 20,
                right: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Undo Button
                    BlocProvider.value(
                      value: _gameBloc,
                      child: BlocBuilder<GameBloc, GameState>(
                        builder: (context, state) {
                          return GameFloatingButton(
                            icon: Icons.undo_rounded,
                            disabled: state.history.isEmpty,
                            onTap: () => _gameBloc.add(UndoMove()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Reset Button
                    GameFloatingButton(
                      icon: Icons.refresh_rounded,
                      onTap: () {
                        _gameBloc.add(ResetLevel());
                      },
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

  Widget _buildPlayerLabel({required String player, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        player,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          shadows: [Shadow(color: color, blurRadius: 10)],
        ),
      ),
    );
  }
}
