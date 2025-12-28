import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:dream_sort/features/game/widgets/ball_widget.dart';
import 'package:flutter/material.dart';

class FlyingBall extends StatelessWidget {
  final Offset start;
  final Offset end;
  final Offset? exitPoint;
  final Offset? entryPoint;
  final SortingItem item;
  final VoidCallback onComplete;

  const FlyingBall({
    super.key,
    required this.start,
    required this.end,
    this.exitPoint,
    this.entryPoint,
    required this.item,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      onEnd: onComplete,
      builder: (context, value, child) {
        Offset position;
        double scale = 1.0;

        if (exitPoint != null && entryPoint != null) {
          // 3-Stage Animation: Rise -> Arc -> Fall
          const riseEnd = 0.2;
          const arcEnd = 0.8;

          if (value <= riseEnd) {
            // Stage 1: Rise (Linear)
            final t = value / riseEnd;
            position = Offset.lerp(start, exitPoint!, t)!;
            scale = 1.0 + (0.1 * t); // Slight scale up
          } else if (value <= arcEnd) {
            // Stage 2: Arc (Quadratic Bezier)
            final t = (value - riseEnd) / (arcEnd - riseEnd);

            // Calculate Control Point for the Arc
            final midX = (exitPoint!.dx + entryPoint!.dx) / 2;
            final dist = (exitPoint! - entryPoint!).distance;
            // Ensure arch clears well; use a minimum height or proportional
            final archHeight = dist * 0.3 + 20.0;
            final peakY =
                (exitPoint!.dy < entryPoint!.dy
                    ? exitPoint!.dy
                    : entryPoint!.dy) -
                archHeight;
            final controlPoint = Offset(midX, peakY);

            position = _calculateQuadraticBezier(
              t,
              exitPoint!,
              controlPoint,
              entryPoint!,
            );

            // Scale peaks at center of arc
            scale = 1.1 + (0.1 * (0.5 - (t - 0.5).abs()) * 2);
          } else {
            // Stage 3: Fall (Linear with bounce effect?) -> Just Linear/EaseIn
            final t = (value - arcEnd) / (1.0 - arcEnd);
            position = Offset.lerp(entryPoint!, end, t)!;
            scale = 1.1 - (0.1 * t); // Scale down
          }
        } else {
          // Fallback to simple Bezier if no exit/entry points provided
          final midX = (start.dx + end.dx) / 2;
          final dist = (start - end).distance;
          final archHeight = dist * 0.5;
          final minY = (start.dy < end.dy ? start.dy : end.dy) - archHeight;
          final controlPoint = Offset(midX, minY);

          position = _calculateQuadraticBezier(value, start, controlPoint, end);
          scale = 1.0 + (0.2 * (0.5 - (value - 0.5).abs()) * 2);
        }

        return Positioned(
          left: position.dx,
          top: position.dy,
          child: ExcludeSemantics(
            child: Transform.scale(scale: scale, child: child!),
          ),
        );
      },
      child: BallWidget(item: item),
    );
  }

  Offset _calculateQuadraticBezier(double t, Offset p0, Offset p1, Offset p2) {
    final t1 = 1 - t;
    return p0 * t1 * t1 + p1 * 2 * t1 * t + p2 * t * t;
  }
}
