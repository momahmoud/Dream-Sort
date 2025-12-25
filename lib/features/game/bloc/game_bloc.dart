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

// --- State ---
enum GameStatus { initial, playing, won }

class MoveDetails extends Equatable {
  final int sourceIndex;
  final int targetIndex;
  final int colorIndex;
  final int moveId; // To detect distinct moves

  const MoveDetails({
    required this.sourceIndex,
    required this.targetIndex,
    required this.colorIndex,
    required this.moveId,
  });

  @override
  List<Object?> get props => [sourceIndex, targetIndex, colorIndex, moveId];
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
        _repo.addStars(10);
        final starCountAfterWin = newStars + 10;

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
        _repo.addStars(10);

        emit(
          state.copyWith(
            tubes: newTubes,
            status: GameStatus.won,
            starCount: newStars + 10,
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
        // Prevent selecting if top item is hidden (Should ideally not happen if we reveal on remove,
        // but generator might have hidden the very top item? Our generator constraint prevents this,
        // but for safety...)
        if (state.tubes[tappedIndex].topItem!.isHidden) {
          // Maybe play error sound?
          return;
        }

        HapticFeedback.lightImpact(); // Select Vibration
        emit(state.copyWith(selectedTubeIndex: tappedIndex));
      }
      return;
    }

    // 2. Tapped the same tube -> deselect
    if (sourceIndex == tappedIndex) {
      HapticFeedback.lightImpact(); // Deselect
      emit(state.copyWith(clearSelection: true));
      return;
    }

    // 3. Try to move from Source to Target (Tapped)
    final sourceTube = state.tubes[sourceIndex];
    final targetTube = state.tubes[tappedIndex];

    if (_isValidMove(sourceTube, targetTube)) {
      _audio.playMove(); // Play Move Sound
      HapticFeedback.mediumImpact(); // Move Vibration

      final itemToMove = sourceTube.topItem!;

      final newSourceTube = sourceTube.removeItem();
      final newTargetTube = targetTube.addItem(itemToMove)!;

      // SAVE HISTORY
      final currentHistory = List<List<Tube>>.from(state.history);
      currentHistory.add(state.tubes); // Add 'old' tubes state

      final newTubes = List<Tube>.from(state.tubes);
      newTubes[sourceIndex] = newSourceTube;
      newTubes[tappedIndex] = newTargetTube;

      // REVEAL LOGIC:
      // If the new source tube has items, and the new top item is HIDDEN, reveal it.
      if (!newSourceTube.isEmpty) {
        final topItem = newSourceTube.topItem!;
        if (topItem.isHidden) {
          final revealedItem = SortingItem(
            colorIndex: topItem.colorIndex,
            isHidden: false,
          );

          // Replace top item
          final currentItems = List<SortingItem>.from(newSourceTube.items);
          currentItems[currentItems.length - 1] = revealedItem;

          newTubes[sourceIndex] = Tube(
            items: currentItems,
            capacity: newSourceTube.capacity,
          );
        }
      }

      // Record Move
      final move = MoveDetails(
        sourceIndex: sourceIndex,
        targetIndex: tappedIndex,
        colorIndex: itemToMove.colorIndex,
        moveId: Random().nextInt(1000000),
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
        _repo.addStars(10);
        final newStars = state.starCount + 10;

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
      HapticFeedback.selectionClick();
      if (!targetTube.isEmpty) {
        emit(state.copyWith(selectedTubeIndex: tappedIndex));
      } else {
        emit(state.copyWith(clearSelection: true));
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
    // Cap strictly at 13 colors to ensure max 15 tubes (13 colors + 2 spaces)
    final int effectiveMaxColors = 13;

    final int numColors = (level <= 1)
        ? 2
        : (level + 1).clamp(2, effectiveMaxColors);

    final int numEmptyTubes = 2; // Standard difficulty
    final int numTubes = numColors + numEmptyTubes;
    final int tubeCapacity = 4;

    // 2. Start with a SOLVED state
    List<List<SortingItem>> itemsInTubes = [];
    for (int i = 0; i < numColors; i++) {
      itemsInTubes.add(
        List.generate(tubeCapacity, (_) => SortingItem(colorIndex: i)),
      );
    }
    // Add empty tubes
    for (int i = 0; i < numEmptyTubes; i++) {
      itemsInTubes.add([]);
    }

    // 3. Shuffle moves (Reverse Engineering)
    final random = seed != null ? Random(seed) : Random();

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
          itemsInTubes[target].length < tubeCapacity) {
        final item = itemsInTubes[source].removeLast();
        itemsInTubes[target].add(item);
        successfulMoves++;
        lastSource = source;
        lastTarget = target;
      }
    }

    // 4. APPLY HIDDEN BALLS (Level 7+)
    // Difficulty Scaling:
    // Level 7-9: Bottom ball hidden
    // Level 10-14: Bottom 2 balls hidden
    // Level 15+: Bottom 3 balls hidden (Only top visible!)
    if (level >= 7) {
      int itemsToHide = 1;
      if (level >= 10) itemsToHide = 2;
      if (level >= 15) itemsToHide = 3;

      for (int t = 0; t < itemsInTubes.length; t++) {
        final tubeItems = itemsInTubes[t];
        if (tubeItems.isEmpty) continue;

        // Hide item indices [0 .. itemsToHide-1]
        // But only up to length-1 (Always keep top item visible initially?)
        // Actually, in Solitaire, only the top is available.
        // It's fair if deep items are hidden.
        // Let's hide items at indices < itemsToHide.
        for (int i = 0; i < tubeItems.length; i++) {
          if (i < itemsToHide && i < tubeItems.length - 1) {
            // Never hide the TOP item at start?
            // Actually, standard mechanics usually reveal only the top.
            // But let's check: if we hide everything except the top, it's fine.
            // Let's enforce: Always keep at least the very top item visible for fairness?
            // Or rely on the fact that you can only pick the top anyway.
            // Let's hide up to `itemsToHide` from the BOTTOM (index 0 upwards).

            final newItem = SortingItem(
              colorIndex: tubeItems[i].colorIndex,
              isHidden: true,
            );
            tubeItems[i] = newItem;
          }
        }
      }
    }

    return itemsInTubes
        .map((items) => Tube(items: items, capacity: tubeCapacity))
        .toList();
  }
}
