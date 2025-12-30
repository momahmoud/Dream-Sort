import 'dart:math';

import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:dream_sort/features/game/widgets/ball_widget.dart';
import 'package:dream_sort/features/game/widgets/particle_burst.dart';
import 'package:flutter/material.dart';

class TubeWidget extends StatefulWidget {
  final Tube tube;
  final bool isSelected;
  final VoidCallback onTap;
  final int hiddenItemCount;
  final Color? skinColor;
  final bool isCompleted;

  const TubeWidget({
    super.key,
    required this.tube,
    required this.isSelected,
    required this.onTap,
    this.hiddenItemCount = 0,
    this.skinColor,
    this.isCompleted = false,
  });

  @override
  State<TubeWidget> createState() => TubeWidgetState();
}

// Public State class so we can call shake() via GlobalKey
class TubeWidgetState extends State<TubeWidget> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  late AnimationController _shakeController;
  // Removed unused _shakeAnimation

  bool _isPressed = false;
  bool _triggerBurst = false;

  @override
  void initState() {
    super.initState();
    // Hover Animation (Selection)
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

    // Shake Animation (Error)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });

    if (widget.isCompleted) {
      _triggerBurst = true; // Initial state check
    }
  }

  @override
  void didUpdateWidget(TubeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Selection Handle
    if (widget.isSelected && !oldWidget.isSelected) {
      _hoverController.repeat(reverse: true);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _hoverController.stop();
      _hoverController.reset();
    }

    // Completion Handle
    if (widget.isCompleted && !oldWidget.isCompleted) {
      setState(() {
        _triggerBurst = true;
      });
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void shake() {
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on skin
    final baseColor = widget.skinColor ?? Colors.white;
    final borderColor = baseColor.withOpacity(0.5); // Stronger border for skins
    final bgColor = baseColor.withOpacity(0.05);

    // Dynamic Height Calculation
    const double ballSize = 26.0; // Decreased from 30.0
    const double bottomPad = 12.0; // Slight increase
    const double topPad = 18.0; // Reduced from 40.0
    final int capacity = widget.tube.capacity;

    // Calculate the glass tube body height (just the glass part)
    final double tubeBodyHeight = bottomPad + (capacity * ballSize) + topPad;

    // The total widget height (including hover space above)
    final double totalWidgetHeight = tubeBodyHeight + 30.0;
    const double tubeWidth = 32.0; // Decreased from 38.0
    const double tubeRadius = tubeWidth / 2; // 16.0

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final offset = sin(_shakeController.value * pi * 4) * 6;
          return Transform.translate(offset: Offset(offset, 0), child: child);
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Column(
            children: [
              // Hovering Item (Animation placeholder)
              SizedBox(
                width: tubeWidth,
                height: totalWidgetHeight,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    // 1. The Glass Tube Background (Back layer)
                    Container(
                      width: tubeWidth,
                      height: tubeBodyHeight,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(tubeRadius),
                          bottomRight: Radius.circular(tubeRadius),
                        ),
                        border: Border(
                          left: BorderSide(color: borderColor, width: 2),
                          right: BorderSide(color: borderColor, width: 2),
                          bottom: BorderSide(color: borderColor, width: 2),
                          top: BorderSide.none,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),

                    // 2. The Items
                    Positioned(
                      bottom: bottomPad, // Use constant 12.0
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _buildItemsList(),
                      ),
                    ),

                    // 2.5 Fog Overlay (If containing mystery items)
                    // We check if any item is hidden in the tube to show a subtle fog effect
                    if (widget.tube.items.any((i) => i.isHidden))
                      Positioned(
                        bottom: 5,
                        left: 0,
                        right: 0,
                        height:
                            (widget.tube.capacity - 1) *
                            (ballSize + 4), // Approx cover
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.0),
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

                    // 3. Front Reflection (Glass Glare)
                    IgnorePointer(
                      child: Container(
                        width: tubeWidth,
                        height: tubeBodyHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                              Colors.white.withOpacity(0.05),
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

                    // 4. Particle Burst (On Completion)
                    if (widget.isCompleted)
                      Positioned(
                        top: -30, // Start slightly above
                        left:
                            -50 +
                            tubeRadius, // Center relative to width 42 (21 is center) -> -29
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: ParticleBurst(
                            isBursting: _triggerBurst,
                            onComplete: () {},
                          ),
                        ),
                      ),

                    // 5. Completed "Cap" / Lid
                    if (widget.isCompleted)
                      Positioned(
                        top: _resultCapTopOffset(
                          tubeBodyHeight,
                        ), // Position dynamically
                        child: ExcludeSemantics(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              // Slide down and scale up slightly
                              return Transform.translate(
                                offset: Offset(0, -50 * (1 - value)),
                                child: Transform.scale(
                                  scale: 0.8 + (0.2 * value),
                                  child: child,
                                ),
                              );
                            },
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                // 1. The Cork Body (Plug)
                                Container(
                                  width:
                                      tubeWidth -
                                      6, // Adjusted for new width (38 - 6 = 32)
                                  height: 18,
                                  margin: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xFF8D6E63), // Brown 400
                                        Color(0xFF5D4037), // Brown 700
                                        Color(0xFF8D6E63),
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(4),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                // 2. The Fancy Cap (Top)
                                Container(
                                  width: 46,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFFFFECB3), // Lighter Gold
                                        Color(0xFFFFC107), // Gold
                                        Color(0xFFFF6F00), // Dark Gold
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.2),
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
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                                // 3. The Gem/Seal on Top
                                Positioned(
                                  top: -4,
                                  child: Container(
                                    width: 14,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                      gradient: const RadialGradient(
                                        colors: [
                                          Colors.white,
                                          Colors.redAccent,
                                          Colors.red,
                                        ],
                                        center: Alignment(-0.3, -0.3),
                                        radius: 0.8,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.4),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _resultCapTopOffset(double tubeHeight) {
    // Basic heuristic: The cap should sit near the top.
    // If tubeHeight is ~160, old top was 10. (Pad 24 - 10 ~ 14 offset?)
    // Let's say topPadding is 24. We want it slightly inside.
    return 14.0;
  }

  List<Widget> _buildItemsList() {
    final widgets = <Widget>[];
    final items = widget.tube.items;

    for (int i = items.length - 1; i >= 0; i--) {
      final item = items[i];
      final isTopItem = (i == items.length - 1);

      // Animation logic:
      // If this is the top item and selected, use the animated controller value.
      Widget child = BallWidget(item: item);

      // Add Glow if selected
      if (isTopItem && widget.isSelected) {
        child = Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.6),
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
        // Normal item or simple opacity hide
        // Hide top N items
        final isHiddenByAnimation =
            (i >= items.length - widget.hiddenItemCount);
        final opacity = isHiddenByAnimation ? 0.0 : 1.0;

        widgets.add(
          AnimatedContainer(
            // Gentle entry animation only
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
