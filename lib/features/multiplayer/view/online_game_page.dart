import 'package:dream_sort/features/multiplayer/models/multiplayer_room.dart';
import 'package:dream_sort/features/multiplayer/repository/multiplayer_repository.dart';
import 'package:dream_sort/features/multiplayer/view/online_multiplayer_game_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnlineGamePage extends StatefulWidget {
  final MultiplayerRepository repository;
  final String playerId; // My ID

  const OnlineGamePage({
    super.key,
    required this.repository,
    required this.playerId,
  });

  @override
  State<OnlineGamePage> createState() => _OnlineGamePageState();
}

class _OnlineGamePageState extends State<OnlineGamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiplayer Lobby'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.repository.leaveRoom();
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<MultiplayerRoom>(
        stream: widget.repository.roomStream,
        initialData: widget.repository.lastKnownRoom,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final room = snapshot.data!;

          if (room.status == MatchStatus.waiting) {
            return _buildLobby(room);
          } else if (room.status == MatchStatus.playing) {
            return OnlineMultiplayerGamePage(
              repository: widget.repository,
              initialRoom: room,
              playerId: widget.playerId,
            );
          }

          return const Center(child: Text('Game Over'));
        },
      ),
    );
  }

  Widget _buildLobby(MultiplayerRoom room) {
    final players = room.players.values.toList();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Room Code', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: room.code));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Code copied!')));
            },
            child: Text(
              room.code,
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Players (${players.length}/2)',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...players.map(
            (p) => ListTile(
              leading: const Icon(Icons.person),
              title: Text(p.name),
              subtitle: Text(p.id == widget.playerId ? 'You' : 'Opponent'),
              trailing: p.isReady
                  ? const Icon(Icons.check, color: Colors.green)
                  : const SizedBox(),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: (players.length < 2)
                ? null
                : () {
                    widget.repository.setReady(true);
                  },
            child: Text(
              players.length < 2 ? 'Waiting for Player...' : 'Ready!',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
