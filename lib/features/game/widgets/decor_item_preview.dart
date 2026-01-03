import 'package:dream_sort/features/game/models/decor_models.dart';
import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:dream_sort/features/game/widgets/ball_widget.dart';
import 'package:dream_sort/features/game/widgets/tube_widget.dart';
import 'package:flutter/material.dart';

class DecorItemPreview extends StatelessWidget {
  final DecorItem item;
  final bool isLocked;

  const DecorItemPreview({
    super.key,
    required this.item,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = isLocked ? 0.3 : 1.0;

    // 1. Tube Skin Preview
    if (item.type == DecorType.tube) {
      return Opacity(
        opacity: opacity,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FittedBox(
            fit: BoxFit.contain,
            child: IgnorePointer(
              child: TubeWidget(
                tube: Tube(
                  items: [
                    SortingItem(colorIndex: 0),
                    SortingItem(colorIndex: 1),
                  ],
                  capacity: 4,
                ),
                isSelected: false,
                onTap: () {},
                skin: item.id.replaceFirst('tube_', ''),
              ),
            ),
          ),
        ),
      );
    }

    // 2. Ball Skin Preview
    if (item.type == DecorType.ball) {
      return Opacity(
        opacity: opacity,
        child: Center(
          child: BallWidget(
            item: SortingItem(colorIndex: 0),
            size: 44,
            skin: item.id.replaceFirst('ball_', ''),
          ),
        ),
      );
    }

    // 3. Color Preview (Wall/Floor)
    if (item.type == DecorType.wall || item.type == DecorType.floor) {
      if (item.assetPath.startsWith('0xff') ||
          item.assetPath.startsWith('0xFF')) {
        final color = Color(int.parse(item.assetPath));
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: opacity),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3 * opacity),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      }
    }

    // 4. Icon Preview (Props)
    if (item.iconData != null) {
      if (item.type == DecorType.painting) {
        return Container(
          width: 50,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C).withValues(alpha: opacity),
            border: Border.all(
              color: const Color(0xFF8D6E63).withValues(alpha: opacity),
              width: 2,
            ),
          ),
          child: Icon(
            item.iconData!,
            color: _getPropColor(item).withValues(alpha: opacity),
            size: 24,
          ),
        );
      } else if (item.type == DecorType.rug) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(0.8), // Slight tilt for preview
          alignment: Alignment.center,
          child: Container(
            width: 50,
            height: 38,
            decoration: BoxDecoration(
              color: _getPropColor(item).withValues(alpha: 0.2 * opacity),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getPropColor(item).withValues(alpha: 0.5 * opacity),
                width: 1.5,
              ),
            ),
            child: Icon(
              item.iconData!,
              color: _getPropColor(item).withValues(alpha: 0.8 * opacity),
              size: 24,
            ),
          ),
        );
      } else if (item.type == DecorType.plant) {
        // Mini Plant Preview
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              item.iconData!,
              color: Colors.greenAccent.withValues(alpha: opacity),
              size: 28,
            ),
            Container(
              width: 18,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF795548).withValues(alpha: opacity),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
                border: Border.all(
                  color: const Color(0xFF5D4037).withValues(alpha: opacity),
                  width: 1.5,
                ),
              ),
            ),
          ],
        );
      } else if (item.type == DecorType.lamp) {
        // Mini Lamp Preview
        if (item.id == 'lamp_sun') {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.orangeAccent.withValues(alpha: opacity),
                  Colors.deepOrange.withValues(alpha: opacity),
                  Colors.transparent,
                ],
                stops: const [0.3, 0.6, 1.0],
              ),
            ),
            child: Icon(
              Icons.sunny,
              color: Colors.white.withValues(alpha: opacity),
              size: 20,
            ),
          );
        } else if (item.id == 'lamp_torch') {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: opacity),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withValues(alpha: 0.5 * opacity),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
              Container(
                width: 4,
                height: 10,
                color: Colors.brown[700]!.withValues(alpha: opacity),
              ),
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withValues(alpha: 0.8 * opacity),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orangeAccent.withValues(alpha: 0.4 * opacity),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                item.iconData!,
                color: Colors.white.withValues(alpha: opacity),
                size: 16,
              ),
            ),
            Container(
              width: 2,
              height: 14,
              color: Colors.grey[400]!.withValues(alpha: opacity),
            ),
            Container(
              width: 12,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.grey[400]!.withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        );
      }

      return Icon(
        item.iconData!,
        color: _getPropColor(item).withValues(alpha: opacity),
        size: 40,
      );
    }

    // Fallback
    return Icon(
      Icons.image_not_supported,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  Color _getPropColor(DecorItem item) {
    switch (item.type) {
      case DecorType.plant:
        return Colors.greenAccent;
      case DecorType.lamp:
        return Colors.orangeAccent;
      case DecorType.rug:
        return Colors.redAccent.shade100;
      case DecorType.painting:
        return Colors.purpleAccent;
      default:
        return Colors.white;
    }
  }
}
