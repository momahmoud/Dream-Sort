import 'package:dream_sort/core/audio/audio_controller.dart';
import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:dream_sort/features/game/repo/game_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'dart:math';

// --- Events ---
abstract class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object> get props => [];
}

class LoadLevel extends GameEvent {
  final int? levelId;
  final int? seed;
  const LoadLevel({this.levelId, this.seed});
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

class RequestHelp extends GameEvent {}

class RequestShuffle extends GameEvent {}

class RequestHint extends GameEvent {}

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
  final List<List<Tube>> history; // Storage for Undo
  final int? selectedTubeIndex;
  final GameStatus status;
  final int levelId;
  final int starCount;
  final MoveDetails? lastMove;
  final int completedTubeCount; // Added for Multiplayer Tracking
  final bool isFrozen; // Added for Freeze Power-up
  final int remainingUndos;

  const GameState({
    required this.tubes,
    this.history = const [],
    this.selectedTubeIndex,
    this.status = GameStatus.playing,
    this.levelId = 1,
    required this.starCount,
    this.lastMove,
    this.completedTubeCount = 0,
    this.isFrozen = false,
    this.remainingUndos = 5,
  });

  bool get isLevelCompleted {
    return tubes.every((tube) => tube.isCompleted);
  }

  GameState copyWith({
    List<Tube>? tubes,
    List<List<Tube>>? history,
    int? selectedTubeIndex,
    bool clearSelection = false,
    GameStatus? status,
    int? levelId,
    int? starCount,
    MoveDetails? lastMove,
    int? completedTubeCount,
    bool? isFrozen,
    int? remainingUndos,
  }) {
    return GameState(
      tubes: tubes ?? this.tubes,
      history: history ?? this.history,
      selectedTubeIndex: clearSelection
          ? null
          : (selectedTubeIndex ?? this.selectedTubeIndex),
      status: status ?? this.status,
      levelId: levelId ?? this.levelId,
      starCount: starCount ?? this.starCount,
      lastMove: lastMove ?? this.lastMove,
      completedTubeCount: completedTubeCount ?? this.completedTubeCount,
      isFrozen: isFrozen ?? this.isFrozen,
      remainingUndos: remainingUndos ?? this.remainingUndos,
    );
  }

  @override
  List<Object?> get props => [
    tubes,
    history,
    selectedTubeIndex,
    status,
    levelId,
    starCount,
    lastMove,
    completedTubeCount,
    isFrozen,
  ];
}

// --- BLoC ---
class GameBloc extends Bloc<GameEvent, GameState> {
  final GameRepository _repo;
  final AudioController _audio;

  GameBloc({required GameRepository repo, required AudioController audio})
    : _repo = repo,
      _audio = audio,
      super(const GameState(tubes: [], starCount: 0)) {
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
  }

  void _onRequestHint(RequestHint event, Emitter<GameState> emit) {
    const hintCost = 25;
    if (state.starCount < hintCost) return; // Not enough coins

    // 1. Find all valid moves
    List<MoveDetails> validMoves = [];

    for (int sourceIndex = 0; sourceIndex < state.tubes.length; sourceIndex++) {
      final source = state.tubes[sourceIndex];
      if (source.isEmpty) continue;
      if (source.isCompleted) continue; // Don't touch completed tubes

      for (
        int targetIndex = 0;
        targetIndex < state.tubes.length;
        targetIndex++
      ) {
        if (sourceIndex == targetIndex) continue;

        final target = state.tubes[targetIndex];
        if (_isValidMove(source, target)) {
          // Create a candidate move
          // Need to calculate count to be accurate
          final itemToMove = source.topItem!;
          int consecutiveCount = 0;
          for (int k = source.items.length - 1; k >= 0; k--) {
            if (source.items[k].colorIndex == itemToMove.colorIndex &&
                !source.items[k].isHidden &&
                !source.items[k].isStone) {
              consecutiveCount++;
            } else {
              break;
            }
          }
          final targetSpace = target.capacity - target.items.length;
          final moveCount = min(consecutiveCount, targetSpace);

          validMoves.add(
            MoveDetails(
              sourceIndex: sourceIndex,
              targetIndex: targetIndex,
              colorIndex: itemToMove.colorIndex,
              moveId: -1,
              count: moveCount,
            ),
          );
        }
      }
    }

    if (validMoves.isEmpty) return;

    // 2. Score Moves (Greedy Heuristic)
    validMoves.sort((a, b) {
      int scoreA = _scoreMove(a, state.tubes);
      int scoreB = _scoreMove(b, state.tubes);
      return scoreB.compareTo(scoreA); // Descending
    });

    final bestMove = validMoves.first;

    // 3. Execute Best Move
    _executeMove(
      bestMove.sourceIndex,
      bestMove.targetIndex,
      emit,
      cost: hintCost,
    );
  }

  int _scoreMove(MoveDetails move, List<Tube> tubes) {
    int score = 0;
    final source = tubes[move.sourceIndex];
    final target = tubes[move.targetIndex];

    // Bonus for moving to same color (stacking)
    if (!target.isEmpty && target.topItem!.colorIndex == move.colorIndex) {
      score += 10;
    }

    // Huge Bonus for completing a tube
    if (target.items.length + move.count == target.capacity) {
      // Check if resulting tube will be single-color (Completed)
      // Since it's a valid move, if target wasn't empty, it matched color.
      // If target WAS empty, we need to check if we are moving ALL items of that color?
      // Actually checking if target becomes 'isCompleted' logic:
      // We know we are adding `move.count` items of `colorIndex`.
      // If target was empty, it now has `count` items. If `count == capacity`, it's full.
      // But is it completed? Only if all items are same color (they are) and full.
      score += 20;
    }

    // Penalty for moving to Empty tube (unless source was messy)
    if (target.isEmpty) {
      // If source is already uniform color, don't break it up!
      // Simple check: is source homogeneous?
      bool sourceHomogeneous = true;
      if (source.items.isNotEmpty) {
        int firstColor = source.items.first.colorIndex;
        for (var item in source.items) {
          if (item.colorIndex != firstColor) sourceHomogeneous = false;
        }
      }

      if (sourceHomogeneous) {
        score -= 50; // Don't move from sorted stack to empty!
      } else {
        score -= 5; // Slight penalty for using empty space unnecessarily
      }
    }

    return score;
  }

  // Refactor: extract move execution logic to avoid duplication with _onTubeTapped
  void _executeMove(
    int sourceIndex,
    int targetIndex,
    Emitter<GameState> emit, {
    int cost = 0,
  }) {
    // ... (Logic from _onTubeTapped, adapted)
    // To avoid massive refactor of _onTubeTapped right now, I will effectively duplicate the core Logic
    // or hopefully call a shared helper if I had one.
    // For safety in this tool call, I will copy the critical logic since I can't easily extract method in one step without context.

    final sourceTube = state.tubes[sourceIndex];
    final targetTube = state.tubes[targetIndex];

    // Recalculate move specifics (safe)
    final itemToMove = sourceTube.topItem!;
    int consecutiveCount = 0;
    for (int i = sourceTube.items.length - 1; i >= 0; i--) {
      if (sourceTube.items[i].colorIndex == itemToMove.colorIndex &&
          !sourceTube.items[i].isHidden &&
          !sourceTube.items[i].isStone) {
        consecutiveCount++;
      } else {
        break;
      }
    }
    final targetSpace = targetTube.capacity - targetTube.items.length;
    final moveCount = min(consecutiveCount, targetSpace);

    var tempSource = sourceTube;
    var tempTarget = targetTube;

    for (int i = 0; i < moveCount; i++) {
      final movingItem = tempSource.topItem!;
      tempSource = tempSource.removeItem();
      tempTarget = tempTarget.addItem(movingItem)!;
    }

    final currentHistory = List<List<Tube>>.from(state.history);
    currentHistory.add(state.tubes);

    final newTubes = List<Tube>.from(state.tubes);
    newTubes[sourceIndex] = tempSource;
    newTubes[targetIndex] = tempTarget;

    // Reveal Logic
    if (!tempSource.isEmpty) {
      final topItem = tempSource.topItem!;
      if (topItem.isHidden) {
        final revealedItem = SortingItem(
          colorIndex: topItem.colorIndex,
          isHidden: false,
        );
        final currentItems = List<SortingItem>.from(tempSource.items);
        currentItems[currentItems.length - 1] = revealedItem;
        newTubes[sourceIndex] = Tube(
          items: currentItems,
          capacity: tempSource.capacity,
        );
      }
    }

    // Spend Cost
    if (cost > 0) {
      _repo.spendStars(cost);
    }
    final newStars = state.starCount - cost;

    final move = MoveDetails(
      sourceIndex: sourceIndex,
      targetIndex: targetIndex,
      colorIndex: itemToMove.colorIndex,
      moveId: Random().nextInt(1000000),
      count: moveCount,
    );

    _audio.playMove();
    HapticFeedback.mediumImpact();

    final isWon = newTubes.every((t) => t.isCompleted);
    final completed = newTubes.where((t) => t.isCompleted).length;

    if (isWon) {
      _audio.playWin();
      final maxLevel = _repo.getMaxLevel();
      if (state.levelId >= maxLevel) _repo.unlockLevel(state.levelId + 1);
      _repo.addStars(25);

      emit(
        state.copyWith(
          tubes:
              newTubes, // Just simplistic win emit, real one reveals all balls
          status: GameStatus.won,
          starCount: newStars + 25,
          clearSelection: true,
          completedTubeCount: completed,
          lastMove: move,
        ),
      );
    } else {
      emit(
        state.copyWith(
          tubes: newTubes,
          history: currentHistory,
          clearSelection: true,
          lastMove: move,
          starCount: newStars,
          completedTubeCount: completed,
        ),
      );
    }
  }

  void _onAddCurrency(AddCurrency event, Emitter<GameState> emit) {
    _repo.addStars(event.amount);
    emit(state.copyWith(starCount: state.starCount + event.amount));
  }

  void _onRequestShuffle(RequestShuffle event, Emitter<GameState> emit) {
    const shuffleCost = 20;
    if (state.starCount >= shuffleCost) {
      final newStars = state.starCount - shuffleCost;

      // 1. Identify valid tubes to shuffle (not completed)
      final allTubes = List<Tube>.from(state.tubes);
      final List<SortingItem> itemsToShuffle = [];
      final List<int> indicesToFill = [];

      for (int i = 0; i < allTubes.length; i++) {
        if (!allTubes[i].isCompleted) {
          // Reveal all items on shuffle for fairness
          itemsToShuffle.addAll(
            allTubes[i].items.map(
              (item) =>
                  SortingItem(colorIndex: item.colorIndex, isHidden: false),
            ),
          );
          indicesToFill.add(i);
        }
      }

      // 2. Shuffle items
      itemsToShuffle.shuffle();

      // 3. Distribute back
      // We need to respect the distribution capacity.
      // Easiest is to fill tubes one by one up to capacity?
      // Or distribute pseudo-randomly?
      // Filling one-by-one might stack all same colors if shuffle was bad.
      // But itemsToShuffle IS shuffled. So sequential fill is fine.

      int currentItemIndex = 0;
      for (final tubeIndex in indicesToFill) {
        final capacity = allTubes[tubeIndex].capacity;
        final newItems = <SortingItem>[];

        // Fill this tube
        while (newItems.length < capacity &&
            currentItemIndex < itemsToShuffle.length) {
          newItems.add(itemsToShuffle[currentItemIndex]);
          currentItemIndex++;
        }

        allTubes[tubeIndex] = Tube(items: newItems, capacity: capacity);
      }

      // 4. Save & Emit
      _repo.spendStars(shuffleCost);
      _audio.playMove(); // Use move sound or specific shuffle sound

      // Check Win Condition
      final isWon = allTubes.every((t) => t.isCompleted);
      final completed = allTubes.where((t) => t.isCompleted).length;

      if (isWon) {
        // Reveal all balls for victory screen
        final wonTubes = allTubes.map((tube) {
          final revealedItems = tube.items.map((item) {
            return SortingItem(colorIndex: item.colorIndex, isHidden: false);
          }).toList();
          return Tube(items: revealedItems, capacity: tube.capacity);
        }).toList();

        _audio.playWin(); // Play Win Sound
        final maxLevel = _repo.getMaxLevel();
        if (state.levelId >= maxLevel) {
          _repo.unlockLevel(state.levelId + 1);
        }

        // Add Stars
        _repo.addStars(25);
        final starCountAfterWin = newStars + 25;

        emit(
          state.copyWith(
            tubes: wonTubes,
            status: GameStatus.won, // Trigger Win
            starCount: starCountAfterWin,
            clearSelection: true,
            completedTubeCount: completed,
            remainingUndos: state.remainingUndos, // Keep undo count? Or reset?
          ),
        );
      } else {
        emit(
          state.copyWith(
            starCount: newStars,
            tubes: allTubes,
            clearSelection: true,
            completedTubeCount: completed,
          ),
        );
      }
    }
  }

  void _onRequestHelp(RequestHelp event, Emitter<GameState> emit) {
    const helpCost = 50;
    if (state.starCount >= helpCost) {
      final newStars = state.starCount - helpCost;

      // Create a new empty tube
      final newTube = Tube(items: []);

      final newTubes = List<Tube>.from(state.tubes)..add(newTube);

      // Save new star count
      _repo.spendStars(helpCost);

      // Check Win Condition (Unlikely but possible if bugged state)
      final isWon = newTubes.every((t) => t.isCompleted);
      final completed = newTubes.where((t) => t.isCompleted).length;

      if (isWon) {
        _audio.playWin();
        final maxLevel = _repo.getMaxLevel();
        if (state.levelId >= maxLevel) {
          _repo.unlockLevel(state.levelId + 1);
        }
        _repo.addStars(25);

        emit(
          state.copyWith(
            tubes: newTubes,
            status: GameStatus.won,
            starCount: newStars + 25,
            clearSelection: true,
            completedTubeCount: completed,
          ),
        );
      } else {
        emit(
          state.copyWith(
            starCount: newStars,
            tubes: newTubes,
            clearSelection: true,
            completedTubeCount: completed,
          ),
        );
      }
    }
  }

  void _onLoadLevel(LoadLevel event, Emitter<GameState> emit) {
    final levelToLoad = event.levelId ?? _repo.getMaxLevel();
    final tubes = _generateLevel(levelToLoad, seed: event.seed);
    final stars = _repo.getStars();
    final completed = tubes.where((t) => t.isCompleted).length;

    // Undo Count Scaling
    int initialUndos = 5;
    if (levelToLoad >= 20) {
      initialUndos = 20;
    } else if (levelToLoad >= 15) {
      initialUndos = 15;
    } else if (levelToLoad >= 10) {
      initialUndos = 12;
    } else if (levelToLoad >= 6) {
      initialUndos = 8;
    }

    emit(
      GameState(
        tubes: tubes,
        levelId: levelToLoad,
        status: GameStatus.playing,
        starCount: stars,
        completedTubeCount: completed,
        isFrozen: false,
        remainingUndos: initialUndos,
      ),
    );
  }

  void _onResetLevel(ResetLevel event, Emitter<GameState> emit) {
    add(LoadLevel(levelId: state.levelId));
  }

  void _onNextLevel(NextLevel event, Emitter<GameState> emit) {
    final nextLevel = state.levelId + 1;
    _repo.unlockLevel(nextLevel);
    add(LoadLevel(levelId: nextLevel));
  }

  void _onTriggerFreeze(TriggerFreeze event, Emitter<GameState> emit) async {
    emit(state.copyWith(isFrozen: true, clearSelection: true));

    // Auto unfreeze after 3 seconds
    // Note: In a real app we might want to use a stream subscription or timer to be cancellable
    await Future.delayed(const Duration(seconds: 3));
    // Check if the bloc is still active and state is still frozen (simple check)
    if (!emit.isDone) {
      // Create a fresh event to unfreeze or just emit?
      // Emitting directly in async handler after delay is risky if state changed significantly,
      // but for this simple boolean toggling it's usually okay if we check !emit.isDone
      emit(state.copyWith(isFrozen: false));
    }
  }

  void _onAddPenalty(AddPenalty event, Emitter<GameState> emit) {
    // FIX: Previously added random balls which broke the color counts (e.g. 6 green balls).
    // NEW PENALTY: Remove an empty tube to constrict the workspace.

    // 1. Find an empty tube
    final emptyTubeIndex = state.tubes.indexWhere((t) => t.isEmpty);

    if (emptyTubeIndex != -1) {
      // Remove it
      final newTubes = List<Tube>.from(state.tubes)..removeAt(emptyTubeIndex);

      emit(state.copyWith(tubes: newTubes, clearSelection: true));
      _audio.playPop(); // Sound effect
    } else {
      // 2. Fallback: If no empty tubes, Hide some balls (Memory Challenge)
      // Hide the top ball of every non-completed tube?
      final newTubes = state.tubes.map((tube) {
        if (!tube.isCompleted && !tube.isEmpty) {
          final newItems = List<SortingItem>.from(tube.items);
          // Hide the top item
          final topIndex = newItems.length - 1;
          newItems[topIndex] = SortingItem(
            colorIndex: newItems[topIndex].colorIndex,
            isHidden: true,
          );
          return Tube(items: newItems, capacity: tube.capacity);
        }
        return tube;
      }).toList();

      emit(state.copyWith(tubes: newTubes, clearSelection: true));
      _audio.playPop();
    }
  }

  void _onUndoMove(UndoMove event, Emitter<GameState> emit) {
    if (state.isFrozen) return; // Cannot undo while frozen
    if (state.history.isEmpty) return;
    if (state.remainingUndos <= 0) return; // Undo Limit

    final previousTubes = state.history.last;
    final newHistory = List<List<Tube>>.from(state.history)..removeLast();

    HapticFeedback.mediumImpact(); // Feedback

    final completed = previousTubes.where((t) => t.isCompleted).length;

    emit(
      state.copyWith(
        tubes: previousTubes,
        history: newHistory,
        clearSelection: true,
        status: GameStatus.playing, // Reset win status if we undo
        completedTubeCount: completed,
        remainingUndos: state.remainingUndos - 1,
      ),
    );
  }

  void _onTubeTapped(TubeTapped event, Emitter<GameState> emit) {
    if (state.status == GameStatus.won) return;

    // Freeze Check
    if (state.isFrozen) {
      HapticFeedback.heavyImpact();
      return;
    }

    final tappedIndex = event.tubeIndex;
    final sourceIndex = state.selectedTubeIndex;

    // 1. No tube selected yet
    if (sourceIndex == null) {
      if (!state.tubes[tappedIndex].isEmpty) {
        // Prevent selecting if top item is hidden
        if (state.tubes[tappedIndex].topItem!.isHidden) {
          // Maybe play error sound?
          return;
        }

        // Prevent selecting if top item is Stone
        if (state.tubes[tappedIndex].topItem!.isStone) {
          HapticFeedback.heavyImpact();
          _audio.playError();
          return;
        }

        HapticFeedback.selectionClick();
        _audio.playSelect(); // NEW
        emit(state.copyWith(selectedTubeIndex: tappedIndex));
      }
      return;
    }

    // 2. Tapped the same tube -> deselect
    if (sourceIndex == tappedIndex) {
      HapticFeedback.selectionClick();
      _audio.playDeselect(); // NEW
      emit(state.copyWith(clearSelection: true));
      return;
    }

    // 3. Try to move from Source to Target (Tapped)
    final sourceTube = state.tubes[sourceIndex];
    final targetTube = state.tubes[tappedIndex];

    if (_isValidMove(sourceTube, targetTube)) {
      _audio.playMove(); // Play Move Sound
      HapticFeedback.mediumImpact(); // Move Vibration

      // MULTI-MOVE LOGIC
      final itemToMove = sourceTube.topItem!;

      // Count consecutive items of same color in Source
      int consecutiveCount = 0;
      for (int i = sourceTube.items.length - 1; i >= 0; i--) {
        if (sourceTube.items[i].colorIndex == itemToMove.colorIndex &&
            !sourceTube.items[i].isHidden &&
            !sourceTube.items[i].isStone) {
          consecutiveCount++;
        } else {
          break;
        }
      }

      // Check target capacity
      final targetSpace = targetTube.capacity - targetTube.items.length;

      // Determine actual move count
      final moveCount = min(consecutiveCount, targetSpace);

      // Perform Moves on local state vars to build final result
      var tempSource = sourceTube;
      var tempTarget = targetTube;

      for (int i = 0; i < moveCount; i++) {
        // Remove top from source
        // We know the item color, just pop it.
        final movingItem = tempSource.topItem!;
        tempSource = tempSource.removeItem();
        tempTarget = tempTarget.addItem(movingItem)!;
      }

      // SAVE HISTORY
      final currentHistory = List<List<Tube>>.from(state.history);
      currentHistory.add(state.tubes); // Add 'old' tubes state

      final newTubes = List<Tube>.from(state.tubes);
      newTubes[sourceIndex] = tempSource;
      newTubes[tappedIndex] = tempTarget;

      // REVEAL LOGIC:
      // If the new source tube has items, and the new top item is HIDDEN, reveal it.
      if (!tempSource.isEmpty) {
        final topItem = tempSource.topItem!;
        if (topItem.isHidden) {
          final revealedItem = SortingItem(
            colorIndex: topItem.colorIndex,
            isHidden: false,
          );

          // Replace top item
          final currentItems = List<SortingItem>.from(tempSource.items);
          currentItems[currentItems.length - 1] = revealedItem;

          newTubes[sourceIndex] = Tube(
            items: currentItems,
            capacity: tempSource.capacity,
          );
        }
      }

      // Record Move
      final move = MoveDetails(
        sourceIndex: sourceIndex,
        targetIndex: tappedIndex,
        colorIndex: itemToMove.colorIndex,
        moveId: Random().nextInt(1000000),
        count: moveCount, // PASS COUNT
      );

      final isWon = newTubes.every((t) => t.isCompleted);
      final completed = newTubes.where((t) => t.isCompleted).length;

      if (isWon) {
        // Reveal all balls for victory screen
        final wonTubes = newTubes.map((tube) {
          final revealedItems = tube.items.map((item) {
            return SortingItem(colorIndex: item.colorIndex, isHidden: false);
          }).toList();
          return Tube(items: revealedItems, capacity: tube.capacity);
        }).toList();

        _audio.playWin(); // Play Win Sound
        final maxLevel = _repo.getMaxLevel();
        if (state.levelId >= maxLevel) {
          _repo.unlockLevel(state.levelId + 1);
        }

        // Add Stars
        _repo.addStars(25);
        final newStars = state.starCount + 25;

        emit(
          GameState(
            tubes: wonTubes,
            history: const [], // Clear history on win? Or keep?
            status: GameStatus.won,
            levelId: state.levelId,
            starCount: newStars,
            lastMove: move,
            completedTubeCount: completed,
            isFrozen: false,
          ),
        );
      } else {
        emit(
          state.copyWith(
            tubes: newTubes,
            history: currentHistory,
            clearSelection: true,
            lastMove: move,
            completedTubeCount: completed,
          ),
        );
      }
    } else {
      // Invalid move.
      // User might want to change selection to this new tube if it has items
      if (!targetTube.isEmpty) {
        // Change selection
        HapticFeedback.selectionClick();
        _audio.playSelect();
        emit(state.copyWith(selectedTubeIndex: tappedIndex));
      } else {
        // Just invalid drop on empty? (Shouldn't happen as empty accepts all, unless constrained)
        // Or specific constraints.
        // If it's truly invalid:
        HapticFeedback.heavyImpact(); // NEW: Strong feedback for error
        _audio.playError(); // NEW
        emit(
          state.copyWith(clearSelection: true),
        ); // Or keep selection? Let's Deselect to be safe or keep?
        // Usually keeping selection is better UX, but visual feedback is needed.
        // For now, deselecting is clear "No".
      }
    }
  }

  bool _isValidMove(Tube source, Tube target) {
    if (source.isEmpty) return false;
    if (target.isFull) return false;

    // If target is empty, any item can go there (usually)
    if (target.isEmpty) return true;

    // Must match colors
    return source.topItem!.colorIndex == target.topItem!.colorIndex;
  }

  // Solvable Level Generator
  List<Tube> _generateLevel(int level, {int? seed}) {
    // 1. Determine constraints based on level
    // Increased cap to allow for many more tubes / distinct levels
    final int effectiveMaxColors = 24;

    // Linear scaling: Add a color every ~2 levels, but keep raising the ceiling.
    // Lvl 1: 3 colors. Lvl 50: ~15 colors?
    // Let's go faster: Add 1 color every 1.5 levels approx?
    // Old: (level + 1).clamp(...). This was 1-to-1 scaling!
    // But it was capped at 13.
    // Let's let it grow naturally up to 24.
    final int numColors = (level <= 1)
        ? 3
        : (level + 2).clamp(3, effectiveMaxColors);

    // Dynamic Empty Tubes:
    // levels 1-9: 2 empty
    // levels 10-24: 3 empty
    // levels 25+: 4 empty (needed for Fog management)
    int numEmptyTubes = 2;
    if (level >= 10) numEmptyTubes = 3;
    if (level >= 25) numEmptyTubes = 4;

    final int numTubes = numColors + numEmptyTubes;
    // 2. Determine Per-Tube Capacities
    // We stick to STANDARD capacity (4) for visual consistency.
    // Difficulty is handled by Stones (Blockers) and Fog.
    final random = seed != null ? Random(seed) : Random();
    List<int> tubeCapacities = List.filled(numTubes, 4);

    // 3. Start with a SOLVED state
    List<List<SortingItem>> itemsInTubes = [];
    for (int i = 0; i < numTubes; i++) itemsInTubes.add([]);

    // Fill tubes with colors
    for (int i = 0; i < numColors; i++) {
      itemsInTubes[i] = List.generate(4, (_) => SortingItem(colorIndex: i));
    }

    // 4. BLOCKERS (Stones) for Level 15+
    // Strategy: Place stones deep in the "Empty" tubes to constrict them?
    // Or put a stone at the bottom of a random color tube?
    // Let's put 1 or 2 stones total.
    if (level >= 15) {
      int stonesToPlace = (level >= 20) ? 2 : 1;
      int stonesPlaced = 0;
      int safetyLimit = 0;

      while (stonesPlaced < stonesToPlace && safetyLimit < 100) {
        safetyLimit++;
        // Pick a random tube from the "Empty" region usually?
        // Or any tube that has space?
        // Careful: If we put a stone in a Color tube, we replace a color item? NO. We add it?
        // We can't reduce the number of color items (4). We must ADD.
        // So we can only put stones in tubes that have capacity > 4 (if any) or EMPTY tubes.
        // Placing a stone in an empty tube effectively reduces the number of empty slots.

        // Let's target the "Empty/Buffer" tubes (indices >= numColors).
        int targetIndex = numColors + random.nextInt(numEmptyTubes);

        if (itemsInTubes[targetIndex].isEmpty) {
          itemsInTubes[targetIndex].add(
            const SortingItem(colorIndex: -1, isStone: true),
          );
          stonesPlaced++;
        }
      }
    }

    // 4. Shuffle moves (Reverse Engineering)
    // Note: random was already initialized above if needed, but we used it for caps.
    // Reset seed? No, same stream is fine.

    // Significant shuffle increase for higher levels
    int targetMoves = 50 + (level * 25);
    int successfulMoves = 0;
    int attempts = 0;
    const maxAttempts = 50000;

    int? lastSource;
    int? lastTarget;

    while (successfulMoves < targetMoves && attempts < maxAttempts) {
      attempts++;
      int source = random.nextInt(numTubes);
      int target = random.nextInt(numTubes);

      if (source == target) continue;
      if (source == lastTarget && target == lastSource) continue;

      if (itemsInTubes[source].isNotEmpty &&
          itemsInTubes[target].length < tubeCapacities[target]) {
        // CRITICAL FIX: Never move Stones during shuffle.
        // If we move a stone, we create a state where the user (who cannot move stones)
        // is expected to move it back, which is impossible.
        if (itemsInTubes[source].last.isStone) continue;

        // Check specific capacity
        final item = itemsInTubes[source].removeLast();
        itemsInTubes[target].add(item);
        successfulMoves++;
        lastSource = source;
        lastTarget = target;
      }
    }

    // 5. APPLY HIDDEN BALLS / FOG (Level 7+)
    // Difficulty Scaling:
    // Level 7-9: Bottom ball hidden
    // Level 10-14: Bottom 2 balls hidden
    // Level 15-24: Bottom 3 balls hidden (Only top visible!)
    // Level 25+: FOG MODE (All items hidden except top)
    if (level >= 7) {
      int itemsToHide = 1;
      if (level >= 10) itemsToHide = 2;
      if (level >= 15) itemsToHide = 3;

      // For level 25+, we treat "itemsToHide" as "All - 1" effectively.
      // But sticking to the index logic works if we just say "Hide everything < length-1"
      bool isFogMode = (level >= 25);

      for (int t = 0; t < itemsInTubes.length; t++) {
        final tubeItems = itemsInTubes[t];
        if (tubeItems.isEmpty) continue;

        // Hide item indices
        for (int i = 0; i < tubeItems.length; i++) {
          bool shouldHide = false;

          if (isFogMode) {
            // Fog Mode: Hide EVERYTHING except the very top item
            if (i < tubeItems.length - 1) {
              shouldHide = true;
            }
          } else {
            // Standard difficulty scaling
            if (i < itemsToHide && i < tubeItems.length - 1) {
              shouldHide = true;
            }
          }

          if (shouldHide && !tubeItems[i].isStone) {
            // Never hide stones (important for UX)
            final newItem = SortingItem(
              colorIndex: tubeItems[i].colorIndex,
              isHidden: true,
              isStone: tubeItems[i].isStone,
            );
            tubeItems[i] = newItem;
          }
        }
      }
    }

    // Map using the specific capacity for each tube
    List<Tube> finalTubes = [];
    for (int i = 0; i < numTubes; i++) {
      finalTubes.add(Tube(items: itemsInTubes[i], capacity: tubeCapacities[i]));
    }

    return finalTubes;
  }
}
