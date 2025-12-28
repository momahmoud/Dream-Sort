import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:dream_sort/features/game/widgets/ball_widget.dart';
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
  State<TubeWidget> createState() => _TubeWidgetState();
}

class _TubeWidgetState extends State<TubeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isPressed = false;

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
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on skin
    final baseColor = widget.skinColor ?? Colors.white;
    final borderColor = baseColor.withOpacity(0.5); // Stronger border for skins
    final bgColor = baseColor.withOpacity(0.05);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        // Haptic feedback handled in Bloc usually, but nice to have immediate response
        // HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0, // Scale effect on tap
        duration: const Duration(milliseconds: 100),
        child: Column(
          children: [
            // Hovering Item (Animation placeholder)
            SizedBox(
              width: 42,
              height: 190, // Slightly taller to accommodate floating item
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // 1. The Glass Tube Background (Back layer)
                  Container(
                    width: 42,
                    height: 160,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(21),
                        bottomRight: Radius.circular(21),
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
                    bottom: 10, // Padding from bottom of tube
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildItemsList(),
                    ),
                  ),

                  // 3. Front Reflection (Glass Glare)
                  IgnorePointer(
                    child: Container(
                      width: 42,
                      height: 160,
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
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(21),
                          bottomRight: Radius.circular(21),
                        ),
                      ),
                    ),
                  ),

                  // 4. Completed "Cap" / Lid
                  if (widget.isCompleted)
                    Positioned(
                      top: 10, // Positioned to "plug" the top
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
                                width: 36,
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
    );
  }

  List<Widget> _buildItemsList() {
    final widgets = <Widget>[];
    final items = widget.tube.items;

    for (int i = items.length - 1; i >= 0; i--) {
      final item = items[i];
      final isTopItem = (i == items.length - 1);

      // Animation logic:
      // If this is the top item and selected, use the animated controller value.
      Widget child = Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: BallWidget(item: item),
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
