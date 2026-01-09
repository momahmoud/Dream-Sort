import 'package:dream_sort/features/game/bloc/game_bloc.dart';
import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:dream_sort/features/game/widgets/flying_ball.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FlyingBallManager extends StatefulWidget {
  final List<GlobalKey> tubeKeys;
  final ValueChanged<Map<int, int>> onHiddenTargetsChanged;

  const FlyingBallManager({
    super.key,
    required this.tubeKeys,
    required this.onHiddenTargetsChanged,
  });

  @override
  State<FlyingBallManager> createState() => _FlyingBallManagerState();
}

class _FlyingBallManagerState extends State<FlyingBallManager> {
  final List<Widget> _flyingBalls = [];
  final Map<int, int> _hiddenTargets = {};

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameBloc, GameState>(
      listener: (context, state) {
        if (state.status == GameStatus.initial) {
          _clearAnimations();
        } else if (state.lastMove != null) {
          _runBallAnimation(state.lastMove!, state);
        }
      },
      listenWhen: (previous, current) {
        // Clear if status reset
        if (current.status == GameStatus.initial &&
            previous.status != GameStatus.initial) {
          return true;
        }
        // Run animation if lastMove changed
        return previous.lastMove != current.lastMove;
      },
      child: Stack(children: _flyingBalls),
    );
  }

  void _clearAnimations() {
    setState(() {
      _flyingBalls.clear();
      _hiddenTargets.clear();
    });
    widget.onHiddenTargetsChanged({});
  }

  void _runBallAnimation(MoveDetails move, GameState state) {
    if (move.sourceIndex >= widget.tubeKeys.length ||
        move.targetIndex >= widget.tubeKeys.length) {
      return;
    }

    // Haptic feedback on move
    HapticFeedback.lightImpact();

    final sourceKey = widget.tubeKeys[move.sourceIndex];
    final targetKey = widget.tubeKeys[move.targetIndex];

    final sourceContext = sourceKey.currentContext;
    final targetContext = targetKey.currentContext;

    if (sourceContext == null || targetContext == null) return;

    // Calculate positions
    final sourceBox = sourceContext.findRenderObject() as RenderBox;
    final targetBox = targetContext.findRenderObject() as RenderBox;

    final sourcePos = sourceBox.localToGlobal(Offset.zero);
    final targetPos = targetBox.localToGlobal(Offset.zero);

    final targetItemsCount = state.tubes[move.targetIndex].items.length;
    final sourceCurrentCount = state.tubes[move.sourceIndex].items.length;

    // Use a local helper or method for getBallTopY
    // Since we are in a class, we can define it as a method or keep it nested.
    // Keeping it nested for closure context if needed, but it only needs widgetHeight.

    // Update hidden targets immediately
    setState(() {
      _hiddenTargets[move.targetIndex] =
          (_hiddenTargets[move.targetIndex] ?? 0) + move.count;
    });
    // Notify parent
    widget.onHiddenTargetsChanged(Map.from(_hiddenTargets));

    for (int i = 0; i < move.count; i++) {
      final sourceIndex = sourceCurrentCount + i;
      final targetIndex = targetItemsCount - move.count + i;

      final startLocalY = _getBallTopY(sourceIndex, sourceBox.size.height);
      final endLocalY = _getBallTopY(targetIndex, targetBox.size.height);

      final startPoint = Offset(
        sourcePos.dx + 4, // Center h-offset
        sourcePos.dy + startLocalY,
      );
      final endPoint = Offset(targetPos.dx + 4, targetPos.dy + endLocalY);

      final exitPoint = Offset(startPoint.dx, sourcePos.dy - 20);
      final entryPoint = Offset(endPoint.dx, targetPos.dy - 20);

      final animationWidget = FlyingBall(
        start: startPoint,
        end: endPoint,
        exitPoint: exitPoint,
        entryPoint: entryPoint,
        item: SortingItem(colorIndex: move.colorIndex),
        onComplete: () {
          if (mounted) {
            setState(() {
              final currentHidden = _hiddenTargets[move.targetIndex] ?? 0;
              if (currentHidden > 0) {
                _hiddenTargets[move.targetIndex] = currentHidden - 1;
              }
              if (_flyingBalls.isNotEmpty) {
                _flyingBalls.removeAt(
                  0,
                ); // Removing specific widget is tricky if order changes?
                // FlyingBall calls onComplete. This closure captures the specific animation?
                // Wait. logic in GamePage was `_flyingBalls.removeAt(0)`.
                // This assumes FIFO completion?
                // If animations have same duration, yes.
              }
            });
            widget.onHiddenTargetsChanged(Map.from(_hiddenTargets));
          }
        },
      );

      setState(() {
        _flyingBalls.add(animationWidget);
      });
    }
  }

  double _getBallTopY(int index, double widgetHeight) {
    const bottomPad = 12.0;
    const itemHeight = 26.0;
    final bottomOffset = bottomPad + (index * itemHeight);
    return widgetHeight - bottomOffset - itemHeight;
  }
}
