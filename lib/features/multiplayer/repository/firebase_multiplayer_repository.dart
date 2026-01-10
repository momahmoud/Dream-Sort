import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:dream_sort/features/multiplayer/models/multiplayer_room.dart';
import 'package:dream_sort/features/multiplayer/repository/multiplayer_repository.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

class FirebaseMultiplayerRepository implements MultiplayerRepository {
  final FirebaseDatabase _db;
  final String _selfId;

  // Current room subscription
  StreamSubscription<DatabaseEvent>? _roomSubscription;
  final _roomController = StreamController<MultiplayerRoom>.broadcast();

  String? _currentRoomId;
  MultiplayerRoom? _lastRoom;

  FirebaseMultiplayerRepository({FirebaseDatabase? db})
    : _db = db ?? FirebaseDatabase.instance,
      _selfId = const Uuid().v4();

  @override
  String? get currentRoomId => _currentRoomId;

  @override
  Stream<MultiplayerRoom> get roomStream => _roomController.stream;

  @override
  MultiplayerRoom? get lastKnownRoom => _lastRoom;

  @override
  Future<String> createRoom({
    required String playerName,
    required int levelId,
  }) async {
    debugPrint('Attempting to create room for $playerName');
    try {
      final code = _generateRoomCode();
      debugPrint('Generated Room Code: $code');

      final roomRef = _db.ref('rooms/$code');

      // Check if exists (improbable with 4 chars but good practice)
      // For simplicity, we assume overwrite or unique enough.

      final seed = Random().nextInt(1000000);

      final player = MultiplayerPlayer(
        id: _selfId,
        name: playerName,
        isReady:
            true, // Host is ready by default? Or explicit? Let's say explicit.
      );

      final room = MultiplayerRoom(
        id: code,
        code: code,
        status: MatchStatus.waiting,
        players: {_selfId: player},
        seed: seed,
        levelId: levelId,
      );

      debugPrint('Setting room data in Firebase...');
      await roomRef.set(room.toJson());
      debugPrint('Room created successfully in Firebase!');
      _lastRoom = room;
      _currentRoomId = code;
      _subscribeToRoom(code);

      return code;
    } catch (e, stack) {
      debugPrint('FAILED to create room: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  @override
  Future<void> joinRoom({
    required String roomCode,
    required String playerName,
  }) async {
    final code = roomCode.toUpperCase();
    final roomRef = _db.ref('rooms/$code');

    final snapshot = await roomRef.get();
    if (!snapshot.exists) {
      throw Exception('Room not found');
    }

    final roomData = jsonDecode(jsonEncode(snapshot.value));
    final room = MultiplayerRoom.fromJson(roomData);

    if (room.status != MatchStatus.waiting) {
      throw Exception('Match already started or finished');
    }

    if (room.players.length >= 2) {
      throw Exception('Room is full');
    }

    // Add self
    final player = MultiplayerPlayer(id: _selfId, name: playerName);

    await roomRef.child('players/$_selfId').set(player.toJson());

    _currentRoomId = code;
    _subscribeToRoom(code);
  }

  @override
  Future<void> updateBoard(List<Tube> tubes, int score) async {
    if (_currentRoomId == null) return;

    // We only update our own board
    // Optimization: Maybe don't send EVERY move if it's too much, but for Realtime DB it's okay.
    // We update 'players/{selfId}/board' and 'score'

    final updates = {
      'players/$_selfId/board': tubes.map((t) => t.toJson()).toList(),
      'players/$_selfId/score': score,
    };

    await _db.ref('rooms/$_currentRoomId').update(updates);
  }

  @override
  Future<void> setReady(bool isReady) async {
    if (_currentRoomId == null) return;
    final roomRef = _db.ref('rooms/$_currentRoomId');

    await roomRef.child('players/$_selfId/isReady').set(isReady);

    // Auto-start check
    // We only want ONE person to trigger the start to avoid race conditions (not critical here but good practice).
    // Let's have each client check. If ALL ready + 2 players -> set MatchStatus.playing.

    final snapshot = await roomRef.get();
    if (snapshot.exists) {
      final data = jsonDecode(jsonEncode(snapshot.value));
      final room = MultiplayerRoom.fromJson(data);

      if (room.status == MatchStatus.waiting && room.players.length == 2) {
        final allReady = room.players.values.every((p) => p.isReady);
        if (allReady) {
          await roomRef.update({'status': MatchStatus.playing.name});
        }
      }
    }
  }

  @override
  Future<void> leaveRoom() async {
    if (_currentRoomId != null) {
      // Remove self
      await _db.ref('rooms/$_currentRoomId/players/$_selfId').remove();
      _currentRoomId = null;
    }
    await _roomSubscription?.cancel();
    _roomSubscription = null;
  }

  void _subscribeToRoom(String roomId) {
    _roomSubscription?.cancel();
    _roomSubscription = _db.ref('rooms/$roomId').onValue.listen((event) {
      if (event.snapshot.value != null) {
        try {
          final data = jsonDecode(jsonEncode(event.snapshot.value));
          final room = MultiplayerRoom.fromJson(data);
          _lastRoom = room;
          _roomController.add(room);
        } catch (e) {
          debugPrint('Error parsing room update: $e');
        }
      }
    });
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(4, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }
}
