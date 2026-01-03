import 'dart:math';
import 'package:flutter/material.dart';

enum ConfettiShape { square, circle, star }

class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Generate more particles with variety
    for (int i = 0; i < 80; i++) {
      _particles.add(_generateParticle());
    }
  }

  Particle _generateParticle() {
    final shape =
        ConfettiShape.values[_random.nextInt(ConfettiShape.values.length)];
    return Particle(
      position: Offset(
        _random.nextDouble() * 500, // Will be updated by size in build
        -20 - _random.nextDouble() * 500,
      ),
      color: [
        Colors.amber,
        Colors.pinkAccent,
        Colors.cyanAccent,
        Colors.lightGreenAccent,
        Colors.orangeAccent,
        Colors.white,
      ][_random.nextInt(6)].withValues(alpha: 0.8),
      speed: _random.nextDouble() * 3 + 1.5,
      angle: _random.nextDouble() * 2 * pi,
      spin: _random.nextDouble() * 0.15 - 0.075,
      shape: shape,
      size: _random.nextDouble() * 6 + 4,
      oscillationSpeed: _random.nextDouble() * 0.05 + 0.02,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          _updateParticles(constraints.biggest);
          return CustomPaint(
            painter: ConfettiPainter(_particles),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  void _updateParticles(Size size) {
    for (var p in _particles) {
      // Gentle side-to-side oscillation
      final oscillation =
          sin(_controller.value * 2 * pi * 10 * p.oscillationSpeed) * 0.5;

      p.position = Offset(p.position.dx + oscillation, p.position.dy + p.speed);
      p.angle += p.spin;

      // Wrap horizontal
      if (p.position.dx < -20) {
        p.position = Offset(size.width + 20, p.position.dy);
      }
      if (p.position.dx > size.width + 20) {
        p.position = Offset(-20, p.position.dy);
      }

      if (p.position.dy > size.height) {
        // Reset to top with random X
        p.position = Offset(_random.nextDouble() * size.width, -50);
      }
    }
  }
}

class Particle {
  Offset position;
  final Color color;
  final double speed;
  double angle;
  final double spin;
  final ConfettiShape shape;
  final double size;
  final double oscillationSpeed;

  Particle({
    required this.position,
    required this.color,
    required this.speed,
    required this.angle,
    required this.spin,
    required this.shape,
    required this.size,
    required this.oscillationSpeed,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<Particle> particles;

  ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      paint.color = p.color;
      canvas.save();
      canvas.translate(p.position.dx, p.position.dy);
      canvas.rotate(p.angle);

      // Add 3D-like perspective flip based on angle
      final scaleX = cos(p.angle);
      canvas.scale(scaleX.abs(), 1.0);

      switch (p.shape) {
        case ConfettiShape.square:
          canvas.drawRect(
            Rect.fromLTWH(-p.size / 2, -p.size / 2, p.size, p.size),
            paint,
          );
          break;
        case ConfettiShape.circle:
          canvas.drawCircle(Offset.zero, p.size / 2, paint);
          break;
        case ConfettiShape.star:
          _drawStar(canvas, Offset.zero, 5, p.size, p.size / 2, paint);
          break;
      }
      canvas.restore();
    }
  }

  void _drawStar(
    Canvas canvas,
    Offset center,
    int points,
    double outerRadius,
    double innerRadius,
    Paint paint,
  ) {
    final Path path = Path();
    final double angle = pi / points;

    for (int i = 0; i < 2 * points; i++) {
      final double r = i.isEven ? outerRadius : innerRadius;
      final double currAngle = i * angle;
      final double x = center.dx + r * cos(currAngle);
      final double y = center.dy + r * sin(currAngle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
