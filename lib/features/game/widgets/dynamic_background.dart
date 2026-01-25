import 'dart:async';
import 'package:flutter/material.dart';

class DynamicBackground extends StatefulWidget {
  final Color baseColor;

  const DynamicBackground({super.key, required this.baseColor});

  @override
  State<DynamicBackground> createState() => _DynamicBackgroundState();
}

class _DynamicBackgroundState extends State<DynamicBackground> {
  late Color _color1;
  late Color _color2;
  late Timer _timer;
  int _phase = 0;

  @override
  void initState() {
    super.initState();
    _updateColors();
    // Slowly shift colors every few seconds
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _phase++;
          _updateColors();
        });
      }
    });
  }

  void _updateColors() {
    // Generate subtle variations of the base color
    // Phase 0: Base -> Darker
    // Phase 1: Slightly lighter -> Base
    // Phase 2: Base shifted Hue -> Darker

    final HSLColor hsl = HSLColor.fromColor(widget.baseColor);

    double hueShift = (_phase % 3 == 0) ? 0 : ((_phase % 3 == 1) ? 10 : -10);
    double lightShift = (_phase % 2 == 0) ? 0.0 : 0.05;

    final c1 = hsl
        .withHue((hsl.hue + hueShift) % 360)
        .withLightness((hsl.lightness + lightShift).clamp(0.1, 0.9))
        .toColor();
    final c2 = hsl
        .withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0))
        .toColor();

    _color1 = c1;
    _color2 = c2;
  }

  @override
  void didUpdateWidget(DynamicBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.baseColor != widget.baseColor) {
      _updateColors();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_color1, _color2],
        ),
      ),
    );
  }
}
