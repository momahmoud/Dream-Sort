part of 'game_bloc.dart';

mixin GameRewardMixin on GameBlocBase {
  void _onAddCurrency(AddCurrency event, Emitter<GameState> emit) {
    repo.addCoins(event.amount);
    emit(state.copyWith(coinCount: state.coinCount + event.amount));
  }

  void _onRequestShuffle(RequestShuffle event, Emitter<GameState> emit) {
    if (state.coinCount >= RewardConstants.shuffleCost) {
      final newStars = state.coinCount - RewardConstants.shuffleCost;

      final allTubes = List<Tube>.from(state.tubes);
      final List<SortingItem> itemsToShuffle = [];
      final List<int> indicesToFill = [];

      for (int i = 0; i < allTubes.length; i++) {
        if (!allTubes[i].isCompleted) {
          itemsToShuffle.addAll(
            allTubes[i].items.map(
              (item) =>
                  SortingItem(colorIndex: item.colorIndex, isHidden: false),
            ),
          );
          indicesToFill.add(i);
        }
      }

      itemsToShuffle.shuffle();

      int currentItemIndex = 0;
      for (final tubeIndex in indicesToFill) {
        final capacity = allTubes[tubeIndex].capacity;
        final newItems = <SortingItem>[];

        while (newItems.length < capacity &&
            currentItemIndex < itemsToShuffle.length) {
          newItems.add(itemsToShuffle[currentItemIndex]);
          currentItemIndex++;
        }

        allTubes[tubeIndex] = Tube(items: newItems, capacity: capacity);
      }

      repo.spendCoins(RewardConstants.shuffleCost);
      audio.playMove();

      final isWon = allTubes.every((t) => t.isCompleted);
      final completed = allTubes.where((t) => t.isCompleted).length;

      if (isWon) {
        final wonTubes = allTubes.map((tube) {
          final revealedItems = tube.items.map((item) {
            return SortingItem(colorIndex: item.colorIndex, isHidden: false);
          }).toList();
          return Tube(items: revealedItems, capacity: tube.capacity);
        }).toList();

        audio.playWin();
        final maxLevel = repo.getMaxLevel();
        if (state.levelId >= maxLevel) {
          repo.unlockLevel(state.levelId + 1);
        }

        repo.addCoins(RewardConstants.winAfterPowerupBonus);
        final coinCountAfterWin =
            newStars + RewardConstants.winAfterPowerupBonus;

        emit(
          state.copyWith(
            tubes: wonTubes,
            status: GameStatus.won,
            coinCount: coinCountAfterWin,
            clearSelection: true,
            completedTubeCount: completed,
            remainingUndos: state.remainingUndos,
            levelEndTime: DateTime.now(),
          ),
        );
      } else {
        emit(
          state.copyWith(
            coinCount: newStars,
            tubes: allTubes,
            clearSelection: true,
            completedTubeCount: completed,
          ),
        );
      }
    }
  }

  void _onRequestHelp(RequestHelp event, Emitter<GameState> emit) {
    if (event.free || state.coinCount >= RewardConstants.helpCost) {
      final newStars = event.free
          ? state.coinCount
          : state.coinCount - RewardConstants.helpCost;

      final newTube = Tube(items: []);
      final newTubes = List<Tube>.from(state.tubes)..add(newTube);

      if (!event.free) {
        repo.spendCoins(RewardConstants.helpCost);
      }

      final completed = newTubes.where((t) => t.isCompleted).length;
      if (newTubes.every((t) => t.isCompleted)) {
        audio.playWin();
        final maxLevel = repo.getMaxLevel();
        if (state.levelId >= maxLevel) {
          repo.unlockLevel(state.levelId + 1);
        }
        repo.addCoins(RewardConstants.winAfterPowerupBonus);

        emit(
          state.copyWith(
            tubes: newTubes,
            status: GameStatus.won,
            coinCount: newStars + 10,
            clearSelection: true,
            completedTubeCount: completed,
            levelEndTime: DateTime.now(),
          ),
        );
      } else {
        emit(
          state.copyWith(
            coinCount: newStars,
            tubes: newTubes,
            clearSelection: true,
            completedTubeCount: completed,
          ),
        );
      }
    }
  }

  void _onTriggerFreeze(TriggerFreeze event, Emitter<GameState> emit) {
    emit(state.copyWith(isFrozen: true, clearSelection: true));
  }

  void _onAddPenalty(AddPenalty event, Emitter<GameState> emit) {
    final emptyTubeIndex = state.tubes.indexWhere((t) => t.isEmpty);

    if (emptyTubeIndex != -1) {
      final newTubes = List<Tube>.from(state.tubes)..removeAt(emptyTubeIndex);
      emit(state.copyWith(tubes: newTubes, clearSelection: true));
      audio.playPop();
    } else {
      final newTubes = state.tubes.map((tube) {
        if (!tube.isCompleted && !tube.isEmpty) {
          final newItems = List<SortingItem>.from(tube.items);
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
      audio.playPop();
    }
  }
}
