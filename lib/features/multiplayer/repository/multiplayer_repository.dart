import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:dream_sort/features/multiplayer/models/multiplayer_room.dart';

abstract class MultiplayerRepository {
  /// Current Room ID (or null if not in room)
  String? get currentRoomId;

  /// Generate a room and return the code
  Future<String> createRoom({required String playerName, required int levelId});

  /// Join an existing room
  Future<void> joinRoom({required String roomCode, required String playerName});

  /// Stream of room state changes
  /// Stream of room state changes
  Stream<MultiplayerRoom> get roomStream;

  /// Last known room state (for initial data)
  MultiplayerRoom? get lastKnownRoom;

  /// Update local player's board
  Future<void> updateBoard(List<Tube> tubes, int score);

  /// Mark player as ready
  Future<void> setReady(bool isReady);

  /// Leave or Close room
  Future<void> leaveRoom();
}
