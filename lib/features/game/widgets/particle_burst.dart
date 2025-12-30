import 'dart:math';
import 'package:flutter/material.dart';

class ParticleBurst extends StatefulWidget {
  final bool isBursting;
  final VoidCallback? onComplete;

  const ParticleBurst({super.key, required this.isBursting, this.onComplete});

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<BurstParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.isBursting) {
      _startBurst();
    }
  }

  @override
  void didUpdateWidget(ParticleBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBursting && !oldWidget.isBursting) {
      _startBurst();
    }
  }

  void _startBurst() {
    _particles.clear();
    for (int i = 0; i < 30; i++) {
      _particles.add(_generateParticle());
    }
    _controller.forward(from: 0);
  }

  BurstParticle _generateParticle() {
    final angle = _random.nextDouble() * 2 * pi;
    final speed = _random.nextDouble() * 10 + 5;
    return BurstParticle(
      position: const Offset(0, 0), // Center
      velocity: Offset(cos(angle) * speed, sin(angle) * speed),
      color: HSLColor.fromAHSL(
        1,
        _random.nextDouble() * 360,
        0.8,
        0.6,
      ).toColor(),
      scale: _random.nextDouble() * 0.5 + 0.5,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.isAnimating) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value;
        _updateParticles(t);
        return CustomPaint(
          painter: BurstPainter(_particles, 1.0 - t),
          size: Size.infinite,
        );
      },
    );
  }

  void _updateParticles(double t) {
    // Gravity effect
    const gravity = 0.5;
    for (var p in _particles) {
      p.position += p.velocity;
      p.velocity += const Offset(0, gravity); // Gravity pulls down
    }
  }
}

class BurstParticle {
  Offset position;
  Offset velocity;
  Color color;
  double scale;

  BurstParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.scale,
  });
}

class BurstPainter extends CustomPainter {
  final List<BurstParticle> particles;
  final double opacity;

  BurstPainter(this.particles, this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    // Assume center is (width/2, height/2)
    final center = Offset(size.width / 2, size.height / 2);

    for (var p in particles) {
      paint.color = p.color.withOpacity(opacity);
      canvas.drawCircle(center + p.position, 4 * p.scale, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
