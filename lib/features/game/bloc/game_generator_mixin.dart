part of 'game_bloc.dart';

mixin GameGeneratorMixin on GameBlocBase {
  void _onLoadLevel(LoadLevel event, Emitter<GameState> emit) {
    final levelToLoad = event.levelId ?? repo.getMaxLevel();
    final tubes = generateLevel(levelToLoad, seed: event.seed);
    final stars = repo.getCoins();
    final completed = tubes.where((t) => t.isCompleted).length;

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
        coinCount: stars,
        completedTubeCount: completed,
        isFrozen: false,
        remainingUndos: initialUndos,
        isDailyChallenge: event.isDailyChallenge,
        levelStartTime: DateTime.now(),
        lastActivityAt: DateTime.now(),
        lastComboReward: null,
      ),
    );
  }

  void _onResetLevel(ResetLevel event, Emitter<GameState> emit) {
    add(LoadLevel(levelId: state.levelId));
  }

  void _onNextLevel(NextLevel event, Emitter<GameState> emit) {
    final nextLevel = state.levelId + 1;
    repo.unlockLevel(nextLevel);
    add(LoadLevel(levelId: nextLevel));
  }

  List<Tube> generateLevel(int level, {int? seed}) {
    final int effectiveMaxColors = 24;
    final int numColors = (level <= 1)
        ? 3
        : (level + 2).clamp(3, effectiveMaxColors);

    int numEmptyTubes = 2;
    if (level >= 10) numEmptyTubes = 3;
    if (level >= 25) numEmptyTubes = 4;
    if (level >= 75) numEmptyTubes = 3;

    final int numTubes = numColors + numEmptyTubes;
    final random = seed != null ? Random(seed) : Random();
    List<int> tubeCapacities = List.filled(numTubes, 4);

    List<List<SortingItem>> itemsInTubes = [];
    for (int i = 0; i < numTubes; i++) {
      itemsInTubes.add([]);
    }

    for (int i = 0; i < numColors; i++) {
      itemsInTubes[i] = List.generate(4, (_) => SortingItem(colorIndex: i));
    }

    if (level >= 15 || seed != null) {
      int stonesToPlace = 1;
      if (level >= 30) {
        stonesToPlace = 3;
      } else if (level >= 20 || seed != null) {
        stonesToPlace = 2;
      }

      int stonesPlaced = 0;
      int safetyLimit = 0;
      while (stonesPlaced < stonesToPlace && safetyLimit < 100) {
        safetyLimit++;
        int targetIndex = numColors + random.nextInt(numEmptyTubes);
        if (itemsInTubes[targetIndex].isEmpty) {
          itemsInTubes[targetIndex].add(
            const SortingItem(colorIndex: -1, isStone: true),
          );
          stonesPlaced++;
        }
      }
    }

    int targetMoves = (50 + pow(level.toDouble(), 1.4)).toInt();
    if (seed != null) targetMoves += 100;
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
        if (itemsInTubes[source].last.isStone) continue;
        final item = itemsInTubes[source].removeLast();
        itemsInTubes[target].add(item);
        successfulMoves++;
        lastSource = source;
        lastTarget = target;
      }
    }

    for (int t = 0; t < itemsInTubes.length; t++) {
      final tubeItems = itemsInTubes[t];
      if (tubeItems.isEmpty) continue;

      for (int i = 0; i < tubeItems.length; i++) {
        var itm = tubeItems[i];
        if (itm.isStone) continue;

        if (level >= 7 || seed != null) {
          int hideThreshold = 1;
          if (level >= 50) {
            hideThreshold = 4;
          } else if (level >= 15) {
            hideThreshold = 3;
          } else if (level >= 10) {
            hideThreshold = 2;
          }

          if (seed != null) hideThreshold = 2;

          if (i < hideThreshold && i < tubeItems.length - 1) {
            itm = SortingItem(
              colorIndex: itm.colorIndex,
              isHidden: true,
              isStone: itm.isStone,
              isLocked: itm.isLocked,
            );
          }

          if (level >= 20 || seed != null) {
            final isTubeFull = tubeItems.length >= tubeCapacities[t];
            if (random.nextDouble() < 0.15 &&
                i == tubeItems.length - 1 &&
                !isTubeFull) {
              itm = SortingItem(
                colorIndex: itm.colorIndex,
                isHidden: itm.isHidden,
                isStone: itm.isStone,
                isLocked: true,
              );
            }
          }
        }
        tubeItems[i] = itm;
      }
    }

    List<Tube> finalTubes = [];
    for (int i = 0; i < numTubes; i++) {
      finalTubes.add(Tube(items: itemsInTubes[i], capacity: tubeCapacities[i]));
    }
    return finalTubes;
  }
}
