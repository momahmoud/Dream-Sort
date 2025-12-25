import 'dart:math';
import 'package:flutter/material.dart';

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
      duration: const Duration(seconds: 2),
    )..repeat();

    // Generate particles
    for (int i = 0; i < 50; i++) {
      _particles.add(_generateParticle());
    }
  }

  Particle _generateParticle() {
    return Particle(
      position: Offset(
        _random.nextDouble() * 400,
        -20 - _random.nextDouble() * 200,
      ), // Start above
      color: HSLColor.fromAHSL(
        1,
        _random.nextDouble() * 360,
        0.8,
        0.5,
      ).toColor(),
      speed: _random.nextDouble() * 4 + 2,
      angle: _random.nextDouble() * 2 * pi,
      spin: _random.nextDouble() * 0.2 - 0.1,
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
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          _updateParticles(MediaQuery.of(context).size);
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
      p.position = Offset(
        p.position.dx + sin(p.angle),
        p.position.dy + p.speed,
      );
      p.angle += p.spin;

      if (p.position.dy > size.height) {
        // Reset to top
        p.position = Offset(_random.nextDouble() * size.width, -20);
      }
    }
  }
}

class Particle {
  Offset position;
  Color color;
  double speed;
  double angle;
  double spin;

  Particle({
    required this.position,
    required this.color,
    required this.speed,
    required this.angle,
    required this.spin,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<Particle> particles;

  ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var p in particles) {
      paint.color = p.color;
      canvas.save();
      canvas.translate(p.position.dx, p.position.dy);
      canvas.rotate(p.angle);
      canvas.drawRect(const Rect.fromLTWH(-4, -4, 8, 8), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
