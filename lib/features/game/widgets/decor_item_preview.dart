import 'package:dream_sort/features/game/models/decor_models.dart';
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
    // 1. Color Preview (Wall/Floor/Tube)
    if (item.type == DecorType.wall ||
        item.type == DecorType.floor ||
        item.type == DecorType.tube) {
      if (item.assetPath.startsWith('0xff') ||
          item.assetPath.startsWith('0xFF')) {
        final color = Color(int.parse(item.assetPath));
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: item.type == DecorType.tube
              ? Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : null,
        );
      }
    }

    // 2. Icon Preview (Props)
    if (item.iconData != null) {
      return Icon(
        item.iconData!,
        color: isLocked ? Colors.white24 : _getPropColor(item),
        size: 40,
      );
    }

    // Fallback
    return const Icon(Icons.image_not_supported, color: Colors.white24);
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
