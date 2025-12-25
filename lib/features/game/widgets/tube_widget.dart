import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:dream_sort/features/game/widgets/ball_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TubeWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Determine colors based on skin
    final baseColor = skinColor ?? Colors.white;
    final borderColor = baseColor.withValues(
      alpha: 0.5,
    ); // Stronger border for skins
    final bgColor = baseColor.withValues(alpha: 0.05);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          // Hovering Item (Animation placeholder)
          // Ideally, if selected, the top item should appear here or 'float' up.
          // For simplicity in this version, we animate the top item inside the stack or just translate it.
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
    );
  }

  List<Widget> _buildItemsList() {
    final widgets = <Widget>[];
    final items = tube.items;

    for (int i = items.length - 1; i >= 0; i--) {
      final item = items[i];
      final isTopItem = (i == items.length - 1);

      // Animation logic:
      // If this is the top item and we are asked to hide it (for animation), make it transparent.
      // Or if selected, translate it.

      final translationY = (isSelected && isTopItem) ? -20.0 : 0.0;
      final opacity = (hideTopItem && isTopItem) ? 0.0 : 1.0;

      widgets.add(
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          transform: Matrix4.translationValues(0, translationY, 0),
          child: Opacity(
            opacity: opacity,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              child: BallWidget(item: item),
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}
