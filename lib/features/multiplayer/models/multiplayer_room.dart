import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:equatable/equatable.dart';

enum MatchStatus { waiting, playing, finished, aborted }

class MultiplayerPlayer extends Equatable {
  final String id;
  final String name;
  final List<Tube> board;
  final int score;
  final bool isReady;

  const MultiplayerPlayer({
    required this.id,
    required this.name,
    this.board = const [],
    this.score = 0,
    this.isReady = false,
  });

  MultiplayerPlayer copyWith({
    String? id,
    String? name,
    List<Tube>? board,
    int? score,
    bool? isReady,
  }) {
    return MultiplayerPlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      board: board ?? this.board,
      score: score ?? this.score,
      isReady: isReady ?? this.isReady,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'board': board.map((t) => t.toJson()).toList(),
      'score': score,
      'isReady': isReady,
    };
  }

  factory MultiplayerPlayer.fromJson(Map<String, dynamic> json) {
    return MultiplayerPlayer(
      id: json['id'] as String,
      name: json['name'] as String,
      board:
          (json['board'] as List<dynamic>?)
              ?.map((e) => Tube.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      score: json['score'] as int? ?? 0,
      isReady: json['isReady'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, name, board, score, isReady];
}

class MultiplayerRoom extends Equatable {
  final String id;
  final String code;
  final MatchStatus status;
  final Map<String, MultiplayerPlayer> players;
  final int seed; // For level generation
  final int levelId;

  const MultiplayerRoom({
    required this.id,
    required this.code,
    this.status = MatchStatus.waiting,
    this.players = const {},
    this.seed = 0,
    this.levelId = 1,
  });

  MultiplayerRoom copyWith({
    String? id,
    String? code,
    MatchStatus? status,
    Map<String, MultiplayerPlayer>? players,
    int? seed,
    int? levelId,
  }) {
    return MultiplayerRoom(
      id: id ?? this.id,
      code: code ?? this.code,
      status: status ?? this.status,
      players: players ?? this.players,
      seed: seed ?? this.seed,
      levelId: levelId ?? this.levelId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'status': status.name,
      'players': players.map((k, v) => MapEntry(k, v.toJson())),
      'seed': seed,
      'levelId': levelId,
    };
  }

  factory MultiplayerRoom.fromJson(Map<String, dynamic> json) {
    return MultiplayerRoom(
      id: json['id'] as String,
      code: json['code'] as String,
      status: MatchStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MatchStatus.waiting,
      ),
      players:
          (json['players'] as Map<dynamic, dynamic>?)?.map(
            (k, v) => MapEntry(
              k as String,
              MultiplayerPlayer.fromJson(Map<String, dynamic>.from(v)),
            ),
          ) ??
          {},
      seed: json['seed'] as int? ?? 0,
      levelId: json['levelId'] as int? ?? 1,
    );
  }

  @override
  List<Object?> get props => [id, code, status, players, seed, levelId];
}
