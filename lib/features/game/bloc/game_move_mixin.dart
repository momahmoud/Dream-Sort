part of 'game_bloc.dart';

mixin GameMoveMixin on GameBlocBase {
  void _onUndoMove(UndoMove event, Emitter<GameState> emit) {
    if (state.isFrozen) return;
    if (state.moveHistory.isEmpty) return;
    if (state.remainingUndos <= 0) return;

    final move = state.moveHistory.last;
    final newMoveHistory = List<MoveDetails>.from(state.moveHistory)
      ..removeLast();
    final previousTubes = _applyReverseMove(state.tubes, move);

    Vibration.hasVibrator().then((has) {
      if (has == true) {
        Vibration.vibrate(duration: 50, amplitude: 50);
      }
    });

    final completed = previousTubes.where((t) => t.isCompleted).length;

    emit(
      state.copyWith(
        tubes: previousTubes,
        moveHistory: newMoveHistory,
        clearSelection: true,
        status: GameStatus.playing,
        completedTubeCount: completed,
        remainingUndos: state.remainingUndos - 1,
        undosUsed: state.undosUsed + 1,
        clearLastComboReward: true,
      ),
    );
  }

  List<Tube> _applyReverseMove(List<Tube> tubes, MoveDetails move) {
    final result = List<Tube>.from(tubes);
    var sourceTube = result[move.sourceIndex];
    var targetTube = result[move.targetIndex];
    for (int i = 0; i < move.count; i++) {
      final item = targetTube.topItem!;
      targetTube = targetTube.removeItem();
      sourceTube = sourceTube.addItem(item)!;
    }
    result[move.sourceIndex] = sourceTube;
    result[move.targetIndex] = targetTube;
    return result;
  }

  void _onTubeTapped(TubeTapped event, Emitter<GameState> emit) {
    final currentState = state;
    final baseState = currentState.hintMove != null
        ? currentState.copyWith(clearHint: true)
        : currentState;
    if (currentState.hintMove != null) {
      emit(baseState);
    }

    if (baseState.status == GameStatus.won) return;

    if (baseState.isFrozen) {
      Vibration.hasVibrator().then((has) {
        if (has == true) {
          Vibration.vibrate(pattern: [0, 50, 50, 50]);
        }
      });
      return;
    }

    final tappedIndex = event.tubeIndex;
    if (baseState.frozenTubeIndices.contains(tappedIndex)) {
      Vibration.hasVibrator().then((has) {
        if (has == true) {
          Vibration.vibrate(pattern: [0, 30, 30, 30]);
        }
      });
      audio.playError();
      return;
    }

    final sourceIndex = baseState.selectedTubeIndex;

    if (sourceIndex == null) {
      if (!baseState.tubes[tappedIndex].isEmpty) {
        final topItem = baseState.tubes[tappedIndex].topItem!;
        if (topItem.isHidden) return;
        if (topItem.isStone || topItem.isLocked) {
          Vibration.hasVibrator().then((has) {
            if (has == true) {
              Vibration.vibrate(pattern: [0, 30, 30, 30]);
            }
          });
          audio.playError();
          return;
        }

        HapticFeedback.selectionClick();
        Vibration.hasVibrator().then((has) {
          if (has == true) {
            Vibration.vibrate(duration: 10, amplitude: 30);
          }
        });
        audio.playSelect();
        emit(baseState.copyWith(
          selectedTubeIndex: tappedIndex,
          lastActivityAt: DateTime.now(),
          clearLastComboReward: true,
        ));
      }
      return;
    }

    if (sourceIndex == tappedIndex) {
      HapticFeedback.selectionClick();
      audio.playDeselect();
      emit(baseState.copyWith(
        clearSelection: true,
        lastActivityAt: DateTime.now(),
        clearLastComboReward: true,
      ));
      return;
    }

    final sourceTube = baseState.tubes[sourceIndex];
    final targetTube = baseState.tubes[tappedIndex];

    if (isValidMove(sourceTube, targetTube)) {
      audio.playMove();
      Vibration.hasVibrator().then((has) {
        if (has == true) {
          Vibration.vibrate(duration: 25, amplitude: 100);
        }
      });

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

        if (!tempTarget.isEmpty && tempTarget.topItem!.isLocked) {
          final targetBase = List<SortingItem>.from(tempTarget.items);
          targetBase[targetBase.length - 1] = SortingItem(
            colorIndex: targetBase.last.colorIndex,
            isHidden: targetBase.last.isHidden,
            isStone: targetBase.last.isStone,
            isLocked: false,
          );
          tempTarget = Tube(items: targetBase, capacity: tempTarget.capacity);

          Vibration.hasVibrator().then((has) {
            if (has == true) {
              Vibration.vibrate(pattern: [0, 50, 50, 50]);
            }
          });
        }

        tempTarget = tempTarget.addItem(movingItem)!;
      }

      final newTubes = List<Tube>.from(baseState.tubes);
      newTubes[sourceIndex] = tempSource;
      newTubes[tappedIndex] = tempTarget;

      if (!tempSource.isEmpty) {
        final topItem = tempSource.topItem!;
        if (topItem.isHidden || topItem.isLocked) {
          final revealedItem = SortingItem(
            colorIndex: topItem.colorIndex,
            isHidden: false,
            isStone: topItem.isStone,
            isLocked: false,
          );

          final currentItems = List<SortingItem>.from(tempSource.items);
          currentItems[currentItems.length - 1] = revealedItem;
          newTubes[sourceIndex] = Tube(
            items: currentItems,
            capacity: tempSource.capacity,
          );
        }
      }

      final move = MoveDetails(
        sourceIndex: sourceIndex,
        targetIndex: tappedIndex,
        colorIndex: itemToMove.colorIndex,
        moveId: DateTime.now().microsecondsSinceEpoch,
        count: moveCount,
      );
      final newMoveHistory = List<MoveDetails>.from(baseState.moveHistory)
        ..add(move);

      final isWon = newTubes.every((t) => t.isCompleted);
      final completed = newTubes.where((t) => t.isCompleted).length;
      final progressMove = completed > baseState.completedTubeCount;
      final newCombo = progressMove ? baseState.comboCount + 1 : 0;
      int comboReward = 0;
      if (newCombo == RewardConstants.comboThreshold3) {
        comboReward = RewardConstants.comboRewardAt3;
      } else if (newCombo == RewardConstants.comboThreshold5) {
        comboReward = RewardConstants.comboRewardAt5;
      } else if (newCombo >= RewardConstants.comboThreshold8) {
        comboReward = RewardConstants.comboRewardAt8;
      }
      if (comboReward > 0) repo.addCoins(comboReward);

      if (isWon) {
        final wonTubes = newTubes.map((tube) {
          final revealedItems = tube.items.map((item) {
            return SortingItem(
              colorIndex: item.colorIndex,
              isHidden: false,
              isStone: false,
            );
          }).toList();
          return Tube(items: revealedItems, capacity: tube.capacity);
        }).toList();

        audio.playWin();
        final maxLevel = repo.getMaxLevel();
        if (baseState.levelId >= maxLevel) {
          repo.unlockLevel(baseState.levelId + 1);
        }

        int baseReward = baseState.isDailyChallenge
            ? RewardConstants.baseRewardDaily
            : RewardConstants.baseRewardNormal;
        int bonus = 0;
        if (baseState.undosUsed == 0) {
          bonus = baseState.isDailyChallenge
              ? RewardConstants.undoBonusPerfectDaily
              : RewardConstants.undoBonusPerfectNormal;
        } else if (baseState.undosUsed <= RewardConstants.undoGoodMaxUndos) {
          bonus = baseState.isDailyChallenge
              ? RewardConstants.undoBonusGoodDaily
              : RewardConstants.undoBonusGoodNormal;
        }

        int timeBonus = 0;
        final endTime = DateTime.now();
        if (baseState.levelStartTime != null) {
          final seconds = endTime
              .difference(baseState.levelStartTime!)
              .inSeconds;
          if (seconds <= RewardConstants.timeBonusFastSeconds) {
            timeBonus = RewardConstants.timeBonusFast;
          } else if (seconds <= RewardConstants.timeBonusGoodSeconds) {
            timeBonus = RewardConstants.timeBonusGood;
          }
        }

        final totalReward = baseReward + bonus + timeBonus + comboReward;
        repo.addCoins(totalReward);
        final newStars = baseState.coinCount + totalReward;

        emit(
          GameState(
            tubes: wonTubes,
            moveHistory: const [],
            status: GameStatus.won,
            levelId: baseState.levelId,
            coinCount: newStars,
            lastMove: move,
            completedTubeCount: completed,
            isFrozen: false,
            isDailyChallenge: baseState.isDailyChallenge,
            levelStartTime: baseState.levelStartTime,
            levelEndTime: endTime,
            comboCount: newCombo,
            lastComboReward: null,
          ),
        );
      } else {
        emit(
          baseState.copyWith(
            tubes: newTubes,
            moveHistory: newMoveHistory,
            clearSelection: true,
            lastMove: move,
            completedTubeCount: completed,
            comboCount: newCombo,
            coinCount: baseState.coinCount + comboReward,
            lastComboReward: comboReward > 0 ? comboReward : null,
            clearLastComboReward: comboReward == 0,
            lastActivityAt: DateTime.now(),
            frozenTubeIndices: [],
          ),
        );
      }
    } else {
      if (!targetTube.isEmpty) {
        HapticFeedback.selectionClick();
        audio.playSelect();
        emit(baseState.copyWith(
          selectedTubeIndex: tappedIndex,
          lastActivityAt: DateTime.now(),
          clearLastComboReward: true,
        ));
      } else {
        HapticFeedback.heavyImpact();
        audio.playError();
        emit(baseState.copyWith(
          clearSelection: true,
          lastActivityAt: DateTime.now(),
          clearLastComboReward: true,
        ));
      }
    }
  }

  void _onBuyUndos(BuyUndos event, Emitter<GameState> emit) {
    if (state.status != GameStatus.playing) return;
    if (!event.free && state.coinCount < RewardConstants.undoPackCost) return;

    if (!event.free) {
      repo.spendCoins(RewardConstants.undoPackCost);
    }

    emit(state.copyWith(
      remainingUndos: state.remainingUndos + RewardConstants.undoPackCount,
      coinCount: event.free
          ? state.coinCount
          : state.coinCount - RewardConstants.undoPackCost,
    ));
  }

  void _onPressureFreezeTube(PressureFreezeTube event, Emitter<GameState> emit) {
    if (state.levelId < RewardConstants.pressureModeMinLevel) return;
    if (state.status != GameStatus.playing) return;
    if (state.tubes.isEmpty) return;
    final current = List<int>.from(state.frozenTubeIndices);
    if (current.length >= state.tubes.length - 1) return;

    final candidates = List<int>.generate(
      state.tubes.length,
      (i) => i,
    ).where((i) => !current.contains(i)).toList();
    if (candidates.isEmpty) return;

    current.add(candidates[Random().nextInt(candidates.length)]);
    emit(state.copyWith(
      frozenTubeIndices: current,
      lastActivityAt: DateTime.now(),
    ));
  }

}
