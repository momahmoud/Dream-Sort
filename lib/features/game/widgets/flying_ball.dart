import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:dream_sort/features/game/widgets/ball_widget.dart';
import 'package:flutter/material.dart';

class FlyingBall extends StatefulWidget {
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
  State<FlyingBall> createState() => _FlyingBallState();
}

class _FlyingBallState extends State<FlyingBall> {
  final List<Offset> _trail = [];
  static const int _maxTrailSize = 12;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      onEnd: widget.onComplete,
      builder: (context, value, child) {
        Offset position;
        double scale = 1.0;

        if (widget.exitPoint != null && widget.entryPoint != null) {
          const riseEnd = 0.2;
          const arcEnd = 0.8;

          if (value <= riseEnd) {
            final t = value / riseEnd;
            position = Offset.lerp(widget.start, widget.exitPoint!, t)!;
            scale = 1.0 + (0.1 * t);
          } else if (value <= arcEnd) {
            final t = (value - riseEnd) / (arcEnd - riseEnd);
            final midX = (widget.exitPoint!.dx + widget.entryPoint!.dx) / 2;
            final dist = (widget.exitPoint! - widget.entryPoint!).distance;
            final archHeight = dist * 0.3 + 20.0;
            final peakY =
                (widget.exitPoint!.dy < widget.entryPoint!.dy
                    ? widget.exitPoint!.dy
                    : widget.entryPoint!.dy) -
                archHeight;
            final controlPoint = Offset(midX, peakY);

            position = _calculateQuadraticBezier(
              t,
              widget.exitPoint!,
              controlPoint,
              widget.entryPoint!,
            );
            scale = 1.1 + (0.1 * (0.5 - (t - 0.5).abs()) * 2);
          } else {
            final t = (value - arcEnd) / (1.0 - arcEnd);
            position = Offset.lerp(widget.entryPoint!, widget.end, t)!;
            scale = 1.1 - (0.1 * t);
          }
        } else {
          final midX = (widget.start.dx + widget.end.dx) / 2;
          final dist = (widget.start - widget.end).distance;
          final archHeight = dist * 0.5;
          final minY =
              (widget.start.dy < widget.end.dy
                  ? widget.start.dy
                  : widget.end.dy) -
              archHeight;
          final controlPoint = Offset(midX, minY);

          position = _calculateQuadraticBezier(
            value,
            widget.start,
            controlPoint,
            widget.end,
          );
          scale = 1.0 + (0.2 * (0.5 - (value - 0.5).abs()) * 2);
        }

        if (_trail.isEmpty || (_trail.last - position).distance > 2) {
          _trail.add(position);
          if (_trail.length > _maxTrailSize) {
            _trail.removeAt(0);
          }
        }

        return Stack(
          children: [
            // Render Trail without Opacity widget (passing opacity to BallWidget)
            ...List.generate(_trail.length, (index) {
              final pos = _trail[index];
              final trailOpacity = (index + 1) / _trail.length * 0.5;
              final trailScale = (index + 1) / _trail.length * scale * 0.8;

              return Positioned(
                left: pos.dx,
                top: pos.dy,
                child: Transform.scale(
                  scale: trailScale,
                  child: BallWidget(item: widget.item, opacity: trailOpacity),
                ),
              );
            }),

            // Render Actual Ball
            Positioned(
              left: position.dx,
              top: position.dy,
              child: ExcludeSemantics(
                child: Transform.scale(
                  scale: scale,
                  child: BallWidget(item: widget.item),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Offset _calculateQuadraticBezier(double t, Offset p0, Offset p1, Offset p2) {
    final t1 = 1 - t;
    return p0 * t1 * t1 + p1 * 2 * t1 * t + p2 * t * t;
  }
}
