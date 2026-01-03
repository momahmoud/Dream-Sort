import 'dart:math';

import 'package:dream_sort/core/audio/audio_controller.dart';
import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:dream_sort/features/game/repo/game_repository.dart';
import 'package:dream_sort/features/game/widgets/ball_widget.dart';
import 'package:dream_sort/features/game/widgets/particle_burst.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TubeWidget extends StatefulWidget {
  final Tube tube;
  final bool isSelected;
  final VoidCallback onTap;
  final int hiddenItemCount;
  final Color? skinColor;
  final String? skin;
  final bool isCompleted;

  const TubeWidget({
    super.key,
    required this.tube,
    required this.isSelected,
    required this.onTap,
    this.hiddenItemCount = 0,
    this.skinColor,
    this.skin,
    this.isCompleted = false,
  });

  @override
  State<TubeWidget> createState() => TubeWidgetState();
}

class TubeWidgetState extends State<TubeWidget> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  late AnimationController _shakeController;

  bool _isPressed = false;
  bool _triggerBurst = false;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  late AnimationController _shineController;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _hoverAnimation = Tween<double>(begin: -15.0, end: -25.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    if (widget.isSelected) {
      _hoverController.repeat(reverse: true);
    }

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowAnimation = Tween<double>(begin: 0.1, end: 0.4).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _shineAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );

    if (widget.isCompleted) {
      _triggerBurst = true;
      _glowController.repeat(reverse: true);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _shineController.forward(from: 0);
      });
    }
  }

  @override
  void didUpdateWidget(TubeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _hoverController.repeat(reverse: true);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _hoverController.stop();
      _hoverController.reset();
    }

    if (widget.isCompleted && !oldWidget.isCompleted) {
      setState(() {
        _triggerBurst = true;
      });
      _glowController.repeat(reverse: true);
      _shineController.forward(from: 0);
      context.read<AudioController>().playComplete();
    } else if (!widget.isCompleted && oldWidget.isCompleted) {
      _glowController.stop();
      _glowController.reset();
      _shineController.reset();
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _shakeController.dispose();
    _glowController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  void shake() {
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<GameRepository>();
    final skin = widget.skin ?? repo.getTubeSkin();

    const double ballSize = 26.0;
    const double bottomPad = 12.0;
    const double topPad = 18.0;
    final int capacity = widget.tube.capacity;

    final double tubeBodyHeight = bottomPad + (capacity * ballSize) + topPad;
    final double totalWidgetHeight = tubeBodyHeight + 30.0;
    const double tubeWidth = 32.0;
    const double tubeRadius = tubeWidth / 2;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final offset = sin(_shakeController.value * pi * 4) * 6;
          return Transform.translate(offset: Offset(offset, 0), child: child);
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: SizedBox(
            width: tubeWidth,
            height: totalWidgetHeight,
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                if (widget.isCompleted)
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, _) {
                      return Container(
                        width: tubeWidth + 10,
                        height: tubeBodyHeight + 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(tubeRadius + 5),
                            bottomRight: Radius.circular(tubeRadius + 5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(
                                _glowAnimation.value,
                              ),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                _buildSkinnedTubeLayer(
                  skin,
                  tubeWidth,
                  tubeBodyHeight,
                  tubeRadius,
                ),

                Positioned(
                  bottom: bottomPad,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildItemsList(),
                  ),
                ),

                if (widget.tube.items.any((i) => i.isHidden))
                  Positioned(
                    bottom: 5,
                    left: 0,
                    right: 0,
                    height: (widget.tube.capacity - 1) * (ballSize + 4),
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.3),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(tubeRadius),
                            bottomRight: Radius.circular(tubeRadius),
                          ),
                        ),
                      ),
                    ),
                  ),

                if (skin == 'glass' || skin == 'gold_rim')
                  IgnorePointer(
                    child: Container(
                      width: tubeWidth,
                      height: tubeBodyHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.05),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(tubeRadius),
                          bottomRight: Radius.circular(tubeRadius),
                        ),
                      ),
                    ),
                  ),

                if (widget.isCompleted)
                  IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _shineAnimation,
                      builder: (context, _) {
                        return ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(tubeRadius),
                            bottomRight: Radius.circular(tubeRadius),
                          ),
                          child: Container(
                            width: tubeWidth,
                            height: tubeBodyHeight,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(-1.0, _shineAnimation.value),
                                end: Alignment(
                                  1.0,
                                  _shineAnimation.value - 1.0,
                                ),
                                colors: [
                                  Colors.white.withValues(alpha: 0.0),
                                  Colors.white.withValues(alpha: 0.4),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                if (widget.isCompleted)
                  Positioned(
                    top: -30,
                    left: -50 + tubeRadius,
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: ParticleBurst(
                        isBursting: _triggerBurst,
                        onComplete: () {
                          if (mounted) {
                            setState(() => _triggerBurst = false);
                          }
                        },
                      ),
                    ),
                  ),

                if (widget.isCompleted)
                  Positioned(
                    top: 14.0,
                    child: ExcludeSemantics(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, -50 * (1 - value)),
                            child: Transform.scale(
                              scale: 0.8 + (0.2 * value),
                              child: child,
                            ),
                          );
                        },
                        child: _buildCap(tubeWidth),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkinnedTubeLayer(
    String skin,
    double width,
    double height,
    double radius,
  ) {
    Color borderColor = widget.isCompleted
        ? Colors.amber.withValues(alpha: 0.8)
        : Colors.white24;
    double borderWidth = 2.0;
    Color bgColor = Colors.white.withValues(alpha: 0.05);

    switch (skin) {
      case 'bamboo':
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF8D6E63), Color(0xFFBCAAA4), Color(0xFF8D6E63)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(radius),
              bottomRight: Radius.circular(radius),
            ),
            border: Border.all(color: const Color(0xFF5D4037), width: 3),
          ),
          child: CustomPaint(painter: BambooPainter()),
        );
      case 'metal':
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2D3436), Color(0xFF636E72), Color(0xFF2D3436)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(radius),
              bottomRight: Radius.circular(radius),
            ),
            border: Border.all(color: const Color(0xFF00D2FF), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D2FF).withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      case 'crystal':
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.5),
                const Color(0xFFE1F5FE).withValues(alpha: 0.3),
                const Color(0xFF81D4FA).withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(radius),
              bottomRight: Radius.circular(radius),
            ),
            border: Border.all(color: const Color(0xFFB3E5FC), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D2FF).withValues(alpha: 0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CustomPaint(painter: CrystalPainter()),
        );
      case 'magma':
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xFF3E2723), Color(0xFFD84315), Color(0xFFBF360C)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(radius),
              bottomRight: Radius.circular(radius),
            ),
            border: Border.all(color: const Color(0xFFFF3D00), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.deepOrange.withValues(alpha: 0.4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CustomPaint(painter: MagmaPainter()),
        );
      case 'gold_rim':
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(radius),
              bottomRight: Radius.circular(radius),
            ),
            border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
          ),
        );
      default:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(radius),
              bottomRight: Radius.circular(radius),
            ),
            border: Border(
              left: BorderSide(color: borderColor, width: borderWidth),
              right: BorderSide(color: borderColor, width: borderWidth),
              bottom: BorderSide(color: borderColor, width: borderWidth),
            ),
          ),
        );
    }
  }

  Widget _buildCap(double tubeWidth) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: tubeWidth - 6,
          height: 18,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF8D6E63), Color(0xFF5D4037), Color(0xFF8D6E63)],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        Container(
          width: 46,
          height: 14,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFECB3), Color(0xFFFFC107), Color(0xFFFF6F00)],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 20,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        Positioned(
          top: -4,
          child: Container(
            width: 14,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Colors.white, Colors.redAccent, Colors.red],
                center: Alignment(-0.3, -0.3),
                radius: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildItemsList() {
    final widgets = <Widget>[];
    final items = widget.tube.items;

    for (int i = items.length - 1; i >= 0; i--) {
      final item = items[i];
      final isTopItem = (i == items.length - 1);
      Widget child = BallWidget(item: item);

      if (isTopItem && widget.isSelected) {
        child = Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.6),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      }

      child = Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: child,
      );

      if (isTopItem && widget.isSelected) {
        widgets.add(
          AnimatedBuilder(
            animation: _hoverAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _hoverAnimation.value),
                child: child,
              );
            },
            child: child,
          ),
        );
      } else {
        final isHiddenByAnimation =
            (i >= items.length - widget.hiddenItemCount);
        final opacity = isHiddenByAnimation ? 0.0 : 1.0;
        widgets.add(
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: Opacity(opacity: opacity, child: child),
          ),
        );
      }
    }
    return widgets;
  }
}

class BambooPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5D4037).withValues(alpha: 0.3)
      ..strokeWidth = 2;

    // Draw horizontal segments
    for (double i = 40; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(BambooPainter oldDelegate) => false;
}

class CrystalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw some crystal refraction lines
    final path = Path();
    path.moveTo(size.width * 0.2, 0);
    path.lineTo(size.width * 0.8, size.height);
    path.moveTo(size.width * 0.7, 0);
    path.lineTo(size.width * 0.1, size.height * 0.6);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CrystalPainter oldDelegate) => false;
}

class MagmaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepOrange.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    // Draw subtle magma "cracks" or glow spots
    final rand = Random(42);
    for (int i = 0; i < 5; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final r = 2.0 + rand.nextDouble() * 4.0;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(MagmaPainter oldDelegate) => false;
}
