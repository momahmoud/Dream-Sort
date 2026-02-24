import 'package:dream_sort/core/audio/audio_controller.dart';
import 'package:dream_sort/features/game/constants/reward_constants.dart';
import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:dream_sort/features/game/repo/game_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'dart:math';

part 'game_move_mixin.dart';
part 'game_generator_mixin.dart';
part 'game_hint_mixin.dart';
part 'game_reward_mixin.dart';

// --- Events ---
abstract class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object> get props => [];
}

class LoadLevel extends GameEvent {
  final int? levelId;
  final int? seed;
  final bool isDailyChallenge;
  const LoadLevel({this.levelId, this.seed, this.isDailyChallenge = false});
}

class TubeTapped extends GameEvent {
  final int tubeIndex;
  const TubeTapped(this.tubeIndex);
}

class ResetLevel extends GameEvent {}

class NextLevel extends GameEvent {}

class UndoMove extends GameEvent {}

class AddPenalty extends GameEvent {}

class TriggerFreeze extends GameEvent {}

class AddCurrency extends GameEvent {
  final int amount;
  const AddCurrency(this.amount);
}

class RequestHelp extends GameEvent {
  final bool free;
  const RequestHelp({this.free = false});

  @override
  List<Object> get props => [free];
}

class RequestShuffle extends GameEvent {}

class RequestHint extends GameEvent {}

class PressureFreezeTube extends GameEvent {}

class ClearComboReward extends GameEvent {}

class BuyUndos extends GameEvent {
  final bool free;
  const BuyUndos({this.free = false});
  @override
  List<Object> get props => [free];
}

// --- State ---
enum GameStatus { initial, playing, won }

class MoveDetails extends Equatable {
  final int sourceIndex;
  final int targetIndex;
  final int colorIndex;
  final int moveId; // To detect distinct moves
  final int count;

  const MoveDetails({
    required this.sourceIndex,
    required this.targetIndex,
    required this.colorIndex,
    required this.moveId,
    this.count = 1,
  });

  @override
  List<Object?> get props => [
    sourceIndex,
    targetIndex,
    colorIndex,
    moveId,
    count,
  ];
}

class GameState extends Equatable {
  final List<Tube> tubes;
  final List<MoveDetails> moveHistory; // Undo: reverse last move
  final int? selectedTubeIndex;
  final GameStatus status;
  final int levelId;
  final int coinCount;
  final MoveDetails? lastMove;
  final int completedTubeCount; // Added for Multiplayer Tracking
  final bool isFrozen;
  final int? freezeToken; // Prevents unfreeze applying to wrong level after nav
  final int remainingUndos;
  final int undosUsed;
  final bool isDailyChallenge;
  final MoveDetails? hintMove;
  final DateTime? levelStartTime;
  final DateTime? levelEndTime;
  final int comboCount;
  final int? lastComboReward;
  final DateTime? lastActivityAt;
  final List<int> frozenTubeIndices;

  const GameState({
    required this.tubes,
    this.moveHistory = const [],
    this.selectedTubeIndex,
    this.status = GameStatus.playing,
    this.levelId = 1,
    required this.coinCount,
    this.lastMove,
    this.completedTubeCount = 0,
    this.isFrozen = false,
    this.freezeToken,
    this.remainingUndos = 5,
    this.undosUsed = 0,
    this.isDailyChallenge = false,
    this.hintMove,
    this.levelStartTime,
    this.levelEndTime,
    this.comboCount = 0,
    this.lastComboReward,
    this.lastActivityAt,
    this.frozenTubeIndices = const [],
  });

  bool get isLevelCompleted {
    return tubes.every((tube) => tube.isCompleted);
  }

  GameState copyWith({
    List<Tube>? tubes,
    List<MoveDetails>? moveHistory,
    int? selectedTubeIndex,
    bool clearSelection = false,
    GameStatus? status,
    int? levelId,
    int? coinCount,
    MoveDetails? lastMove,
    int? completedTubeCount,
    bool? isFrozen,
    int? freezeToken,
    int? remainingUndos,
    int? undosUsed,
    bool? isDailyChallenge,
    MoveDetails? hintMove,
    bool clearHint = false,
    DateTime? levelStartTime,
    DateTime? levelEndTime,
    int? comboCount,
    int? lastComboReward,
    bool clearLastComboReward = false,
    DateTime? lastActivityAt,
    List<int>? frozenTubeIndices,
  }) {
    return GameState(
      tubes: tubes ?? this.tubes,
      moveHistory: moveHistory ?? this.moveHistory,
      selectedTubeIndex: clearSelection
          ? null
          : (selectedTubeIndex ?? this.selectedTubeIndex),
      status: status ?? this.status,
      levelId: levelId ?? this.levelId,
      coinCount: coinCount ?? this.coinCount,
      lastMove: lastMove ?? this.lastMove,
      completedTubeCount: completedTubeCount ?? this.completedTubeCount,
      isFrozen: isFrozen ?? this.isFrozen,
      freezeToken: freezeToken ?? this.freezeToken,
      remainingUndos: remainingUndos ?? this.remainingUndos,
      undosUsed: undosUsed ?? this.undosUsed,
      isDailyChallenge: isDailyChallenge ?? this.isDailyChallenge,
      hintMove: clearHint ? null : (hintMove ?? this.hintMove),
      levelStartTime: levelStartTime ?? this.levelStartTime,
      levelEndTime: levelEndTime ?? this.levelEndTime,
      comboCount: comboCount ?? this.comboCount,
      lastComboReward: clearLastComboReward ? null : (lastComboReward ?? this.lastComboReward),
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      frozenTubeIndices: frozenTubeIndices ?? this.frozenTubeIndices,
    );
  }

  @override
  List<Object?> get props => [
    tubes,
    moveHistory,
    selectedTubeIndex,
    status,
    levelId,
    coinCount,
    lastMove,
    completedTubeCount,
    isFrozen,
    freezeToken,
    isDailyChallenge,
    hintMove,
    levelStartTime,
    levelEndTime,
    comboCount,
    lastComboReward,
    lastActivityAt,
    frozenTubeIndices,
  ];
}

// --- BLoC ---
abstract class GameBlocBase extends Bloc<GameEvent, GameState> {
  GameBlocBase(super.initialState);
  GameRepository get repo;
  AudioController get audio;

  bool isValidMove(Tube source, Tube target) {
    if (source.isEmpty) return false;
    if (source.topItem!.isStone) return false;
    if (source.topItem!.isLocked) return false;
    if (target.isFull) return false;
    if (target.isEmpty) return true;
    return source.topItem!.colorIndex == target.topItem!.colorIndex;
  }
}

class GameBloc extends GameBlocBase
    with GameMoveMixin, GameGeneratorMixin, GameHintMixin, GameRewardMixin {
  final GameRepository _repo;
  final AudioController _audio;

  GameBloc({required GameRepository repo, required AudioController audio})
      : _repo = repo,
        _audio = audio,
        super(const GameState(tubes: [], coinCount: 0)) {
    on<LoadLevel>(_onLoadLevel);
    on<TubeTapped>(_onTubeTapped);
    on<UndoMove>(_onUndoMove);
    on<ResetLevel>(_onResetLevel);
    on<NextLevel>(_onNextLevel);
    on<AddPenalty>(_onAddPenalty);
    on<TriggerFreeze>(_onTriggerFreeze);
    on<AddCurrency>(_onAddCurrency);
    on<RequestHelp>(_onRequestHelp);
    on<RequestShuffle>(_onRequestShuffle);
    on<RequestHint>(_onRequestHint);
    on<PressureFreezeTube>(_onPressureFreezeTube);
    on<ClearComboReward>(_onClearComboReward);
    on<BuyUndos>(_onBuyUndos);
  }

  void _onClearComboReward(ClearComboReward event, Emitter<GameState> emit) {
    if (state.lastComboReward == null) return;
    emit(state.copyWith(clearLastComboReward: true));
  }

  @override
  GameRepository get repo => _repo;

  @override
  AudioController get audio => _audio;
}
