import 'dart:math';

import 'package:flutter/material.dart';

class HintOverlay extends StatefulWidget {
  final GlobalKey sourceKey;
  final GlobalKey targetKey;
  final VoidCallback? onAnimationComplete;

  const HintOverlay({
    super.key,
    required this.sourceKey,
    required this.targetKey,
    this.onAnimationComplete,
  });

  @override
  State<HintOverlay> createState() => _HintOverlayState();
}

class _HintOverlayState extends State<HintOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Offset? _startPos;
  Offset? _endPos;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        _controller.forward();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculatePositions();
      _controller.forward();
    });
  }

  void _calculatePositions() {
    final sourceBox =
        widget.sourceKey.currentContext?.findRenderObject() as RenderBox?;
    final targetBox =
        widget.targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (sourceBox != null && targetBox != null) {
      final sourceOffset = sourceBox.localToGlobal(Offset.zero);
      final targetOffset = targetBox.localToGlobal(Offset.zero);
      final sourceSize = sourceBox.size;
      final targetSize = targetBox.size;

      setState(() {
        // Start from top of source tube
        _startPos = sourceOffset + Offset(sourceSize.width / 2, 20);
        // End at top of target tube
        _endPos = targetOffset + Offset(targetSize.width / 2, 20);

        // Update animation relative to local coordinates if we were using Stack with absolute positioning?
        // Actually, since we are in a fullscreen Overlay/Stack, using global offsets might be tricky if the stack isn't full screen.
        // Assuming HintOverlay is in a Stack covering the screen or same coordinate space.
        // If it's in the GamePage Stack (which is usually safe area/body), localToGlobal is screen coords.
        // We probably need to convert global back to local if the parent stack isn't root.
        // For simplicity, we assume fullscreen stack or we convert.
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_startPos == null || _endPos == null) return const SizedBox.shrink();

    // Convert global offsets to local offsets for this widget
    final RenderBox? parentBox = context.findRenderObject() as RenderBox?;
    Offset p1 = _startPos!;
    Offset p2 = _endPos!;

    if (parentBox != null) {
      p1 = parentBox.globalToLocal(p1);
      p2 = parentBox.globalToLocal(p2);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final currentPos = Offset.lerp(p1, p2, _controller.value)!;
        // Arc movement?
        // Let's add a bit of arc height
        final t = _controller.value;
        final heightOffset = sin(t * 3.14159) * -50.0; // Arch up by 50px
        final arcedPos = Offset(currentPos.dx, currentPos.dy + heightOffset);

        return Stack(
          children: [
            Positioned(
              left: arcedPos.dx - 24, // Centered (Icon 48)
              top: arcedPos.dy - 48, // Tip at point
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: const Icon(
                  Icons.touch_app_rounded,
                  size: 48,
                  color: Colors.white,
                  shadows: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 8,
                      offset: Offset(2, 2),
                    ),
                    BoxShadow(
                      color: Colors.amber,
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
