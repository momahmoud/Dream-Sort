import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:dream_sort/features/game/widgets/ball_widget.dart';
import 'package:flutter/material.dart';

class TubeWidget extends StatefulWidget {
  final Tube tube;
  final bool isSelected;
  final VoidCallback onTap;
  final bool hideTopItem;
  final Color? skinColor;

  const TubeWidget({
    super.key,
    required this.tube,
    required this.isSelected,
    required this.onTap,
    this.hideTopItem = false,
    this.skinColor,
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
    final borderColor = baseColor.withValues(
      alpha: 0.5,
    ); // Stronger border for skins
    final bgColor = baseColor.withValues(alpha: 0.05);

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
              width: 60,
              height: 240, // Slightly taller to accommodate floating item
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // 1. The Glass Tube Background (Back layer)
                  Container(
                    width: 60,
                    height: 200,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      border: Border(
                        left: BorderSide(color: borderColor, width: 2),
                        right: BorderSide(color: borderColor, width: 2),
                        bottom: BorderSide(color: borderColor, width: 2),
                        top: BorderSide.none,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
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
                      width: 60,
                      height: 200,
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
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
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
        final opacity = (widget.hideTopItem && isTopItem) ? 0.0 : 1.0;

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
