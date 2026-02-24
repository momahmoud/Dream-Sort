part of 'game_bloc.dart';

// Scoring constants — easy to tune, avoids magic numbers in loops
const int _scoreComplete  = 600;
const int _scoreStackBase = 80;
const int _scoreStackLayer = 25;
const int _scoreUnblockHidden = 120;
const int _scoreUnblockUseful = 50;
const int _scoreClearMixed   = 60;
const int _penaltyWasteEmpty = -1200;
const int _penaltyEmptyHom   = -250;
const int _penaltyEmptyMix   = -40;

mixin GameHintMixin on GameBlocBase {
  void _onRequestHint(RequestHint event, Emitter<GameState> emit) {
    if (state.coinCount < RewardConstants.hintCost) return;

    final tubes = state.tubes;
    final n = tubes.length;
    _Move? best;
    int bestScore = -999999;

    outer:
    for (int si = 0; si < n; si++) {
      final source = tubes[si];
      if (source.isEmpty || source.isCompleted) continue;
      final top = source.topItem!;
      if (top.isHidden || top.isStone || top.isLocked) continue;

      // Pre-count consecutive movable items from top
      final srcItems = source.items;
      final topColor = top.colorIndex;
      int consecutive = 0;
      for (int k = srcItems.length - 1; k >= 0; k--) {
        final item = srcItems[k];
        if (item.colorIndex == topColor && !item.isHidden && !item.isStone) {
          consecutive++;
        } else {
          break;
        }
      }

      // Optimization 1: pre-filter — only iterate tubes that can receive topColor
      for (int ti = 0; ti < n; ti++) {
        if (si == ti) continue;
        final target = tubes[ti];
        if (target.isFull) continue;
        // Valid target: empty OR top matches color
        if (!target.isEmpty && target.topItem!.colorIndex != topColor) continue;

        final space = target.capacity - target.items.length;
        final count = consecutive < space ? consecutive : space;
        final score = _score(si, ti, topColor, count, source, target, tubes, n);

        if (score > bestScore) {
          bestScore = score;
          best = _Move(si, ti, topColor, count);
          // Optimization 3: perfect completion found — no need to scan further
          if (bestScore >= _scoreComplete) break outer;
        }
      }
    }

    if (best == null) return;

    repo.spendCoins(RewardConstants.hintCost);
    emit(state.copyWith(
      hintMove: MoveDetails(
        sourceIndex: best.sourceIndex,
        targetIndex: best.targetIndex,
        colorIndex: best.colorIndex,
        moveId: -1,
        count: best.count,
      ),
      coinCount: state.coinCount - RewardConstants.hintCost,
    ));
  }

  int _score(
    int si, int ti, int colorIndex, int count,
    Tube src, Tube tgt,
    List<Tube> tubes, int n,
  ) {
    int score = 0;
    final srcItems = src.items;
    final tgtItems = tgt.items;
    final srcLen = srcItems.length;
    final tgtLen = tgtItems.length;
    final cap = tgt.capacity;

    // Completing a tube
    if (tgtLen + count == cap) score += _scoreComplete;

    // Optimization 2: isValidMove already guarantees tgt top matches colorIndex,
    // so ALL items stacked there are same color — no inner loop needed.
    if (tgtLen > 0) {
      score += _scoreStackBase + (tgtLen * _scoreStackLayer);
    }

    // Unblocking item below moved stack
    if (srcLen > count) {
      final below = srcItems[srcLen - count - 1];
      if (below.isHidden) {
        score += _scoreUnblockHidden;
      } else {
        final colorBelow = below.colorIndex;
        for (int i = 0; i < n; i++) {
          if (i == si) continue;
          final t = tubes[i];
          if (t.items.isNotEmpty) {
            final top = t.topItem!;
            if (!top.isHidden && top.colorIndex == colorBelow) {
              score += _scoreUnblockUseful;
              break;
            }
          }
        }
      }
    }

    // Source homogeneity (one loop, early exit)
    bool srcHom = true;
    if (srcLen > 1) {
      final c = srcItems.first.colorIndex;
      for (int i = 1; i < srcLen; i++) {
        if (srcItems[i].colorIndex != c) { srcHom = false; break; }
      }
    }

    if (srcLen == count) {
      score += srcHom && tgt.isEmpty ? _penaltyWasteEmpty : _scoreClearMixed;
    }

    if (tgt.isEmpty) {
      score += srcHom ? _penaltyEmptyHom : _penaltyEmptyMix;
    }

    return score;
  }
}

class _Move {
  final int sourceIndex;
  final int targetIndex;
  final int colorIndex;
  final int count;
  const _Move(this.sourceIndex, this.targetIndex, this.colorIndex, this.count);
}
