import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:dream_sort/features/game/widgets/ball_widget.dart';
import 'package:flutter/material.dart';

class FlyingBall extends StatelessWidget {
  final Offset start;
  final Offset end;
  final SortingItem item;
  final VoidCallback onComplete;

  const FlyingBall({
    super.key,
    required this.start,
    required this.end,
    required this.item,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: start, end: end),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      onEnd: onComplete,
      builder: (context, offset, child) {
        return Positioned(left: offset.dx, top: offset.dy, child: child!);
      },
      child: BallWidget(item: item),
    );
  }
}
