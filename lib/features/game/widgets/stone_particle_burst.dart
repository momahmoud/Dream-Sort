import 'dart:math';
import 'package:flutter/material.dart';

class StoneParticleBurst extends StatefulWidget {
  final bool isBursting;
  final VoidCallback? onComplete;

  const StoneParticleBurst({
    super.key,
    required this.isBursting,
    this.onComplete,
  });

  @override
  State<StoneParticleBurst> createState() => _StoneParticleBurstState();
}

class _StoneParticleBurstState extends State<StoneParticleBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<StoneParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Faster burst
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
  void didUpdateWidget(StoneParticleBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBursting && !oldWidget.isBursting) {
      _startBurst();
    }
  }

  void _startBurst() {
    _particles.clear();
    for (int i = 0; i < 12; i++) {
      _particles.add(_generateParticle());
    }
    _controller.forward(from: 0);
  }

  StoneParticle _generateParticle() {
    // Generate particles in a small upward cone or general outward explosion
    final angle = -pi / 2 + (_random.nextDouble() - 0.5) * 2; // Upward-ish
    final speed = _random.nextDouble() * 5 + 2;

    return StoneParticle(
      position: const Offset(0, 0),
      velocity: Offset(cos(angle) * speed, sin(angle) * speed),
      color: Color.lerp(
        Colors.grey.shade600,
        Colors.brown.shade400,
        _random.nextDouble(),
      )!,
      scale: _random.nextDouble() * 0.5 + 0.3,
      rotation: _random.nextDouble() * 2 * pi,
      rotationSpeed: (_random.nextDouble() - 0.5) * 0.5,
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
          painter: StonePainter(_particles, 1.0 - t),
          size: Size.infinite,
        );
      },
    );
  }

  void _updateParticles(double t) {
    const gravity = 0.8;
    for (var p in _particles) {
      p.position += p.velocity;
      p.velocity += const Offset(0, gravity); // Gravity
      p.rotation += p.rotationSpeed;
    }
  }
}

class StoneParticle {
  Offset position;
  Offset velocity;
  Color color;
  double scale;
  double rotation;
  double rotationSpeed;

  StoneParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.scale,
    this.rotation = 0,
    this.rotationSpeed = 0,
  });
}

class StonePainter extends CustomPainter {
  final List<StoneParticle> particles;
  final double opacity;

  StonePainter(this.particles, this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    for (var p in particles) {
      paint.color = p.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(center.dx + p.position.dx, center.dy + p.position.dy);
      canvas.rotate(p.rotation);

      // Draw a little irregular rock shape (rectangle/square)
      final s = 6 * p.scale;
      canvas.drawRect(Rect.fromLTWH(-s / 2, -s / 2, s, s), paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
