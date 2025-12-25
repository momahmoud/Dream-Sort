import 'package:dream_sort/features/game/models/decor_models.dart';
import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:dream_sort/features/game/widgets/tube_widget.dart';
import 'package:flutter/material.dart';

class RoomView extends StatelessWidget {
  final Map<String, String> equipped; // e.g. {'wall': 'wall_blue', ...}
  final VoidCallback? onCenterItemTap;
  final bool showCenterVisual;

  const RoomView({
    super.key,
    required this.equipped,
    this.onCenterItemTap,
    this.showCenterVisual = true,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Resolve Items
    final wallId = equipped[DecorType.wall.name];
    final wallItem =
        _getItem(wallId, DecorType.wall) ??
        DecorationData.items.firstWhere((i) => i.id == 'wall_default');
    final wallColor = _parseColor(wallItem.assetPath, const Color(0xFF1A1A2E));

    final floorId = equipped[DecorType.floor.name];
    final floorItem =
        _getItem(floorId, DecorType.floor) ??
        DecorationData.items.firstWhere((i) => i.id == 'floor_default');
    final floorColor = _parseColor(
      floorItem.assetPath,
      const Color(0xFF3E2723),
    );

    final rugId = equipped[DecorType.rug.name];
    final rugItem = _getItem(rugId, DecorType.rug);

    final plantId = equipped[DecorType.plant.name];
    final plantItem = _getItem(plantId, DecorType.plant);

    final lampId = equipped[DecorType.lamp.name];
    final lampItem = _getItem(lampId, DecorType.lamp);

    final paintId = equipped[DecorType.painting.name];
    final paintItem = _getItem(paintId, DecorType.painting);

    final tubeId = equipped['tube'];
    Color? tubeSkinColor;
    if (tubeId != null) {
      final item = _getItem(tubeId, DecorType.tube);
      if (item != null) {
        try {
          tubeSkinColor = Color(int.parse(item.assetPath));
        } catch (_) {}
      }
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // WALL (Background)
        Positioned.fill(
          bottom: 150,
          child: Container(
            decoration: BoxDecoration(
              color: wallColor,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [wallColor, Color.lerp(wallColor, Colors.black, 0.2)!],
              ),
            ),
          ),
        ),

        // FLOOR
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 150,
          child: Container(
            decoration: BoxDecoration(
              color: floorColor,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(floorColor, Colors.black, 0.3)!,
                  floorColor,
                ],
              ),
            ),
          ),
        ),

        // BASEBOARD
        Positioned(
          bottom: 150,
          left: 0,
          right: 0,
          height: 10,
          child: Container(color: Colors.white12),
        ),

        // PAINTING (Only show if equipped, no default window)
        if (showCenterVisual &&
            paintItem != null &&
            paintItem.id != 'paint_none' &&
            paintItem.iconData != null)
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onCenterItemTap,
                child: _FurnitureItem(
                  icon: paintItem.iconData!,
                  color: Colors.purpleAccent,
                  scale: 1.2,
                ),
              ),
            ),
          ),

        // RUG
        if (rugItem != null &&
            rugItem.id != 'rug_none' &&
            rugItem.iconData != null)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: _FurnitureItem(
                icon: rugItem.iconData!,
                color: Colors.redAccent.shade100.withValues(alpha: 0.5),
                scale: 3.0,
              ),
            ),
          ),

        // PLANT
        if (plantItem != null &&
            plantItem.id != 'plant_none' &&
            plantItem.iconData != null)
          Positioned(
            bottom: 100,
            left: 20,
            child: _FurnitureItem(
              icon: plantItem.iconData!,
              color: Colors.greenAccent,
              scale: 1.5,
            ),
          ),

        // LAMP
        if (lampItem != null &&
            lampItem.id != 'lamp_none' &&
            lampItem.iconData != null)
          Positioned(
            bottom: 100,
            right: 20,
            child: _FurnitureItem(
              icon: lampItem.iconData!,
              color: Colors.orangeAccent,
              scale: 1.5,
              hasGlow: true,
            ),
          ),

        // TUBE PREVIEW (Center Floor) - Only show in Decor Mode
        if (showCenterVisual)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Transform.scale(
                scale: 0.8,
                child: IgnorePointer(
                  child: TubeWidget(
                    tube: Tube(
                      items: [
                        SortingItem(colorIndex: 0),
                        SortingItem(colorIndex: 1),
                        SortingItem(colorIndex: 0),
                      ],
                      capacity: 4,
                    ),
                    isSelected: false,
                    skinColor: tubeSkinColor,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  DecorItem? _getItem(String? id, DecorType type) {
    if (id == null) return null;
    return DecorationData.items.firstWhere(
      (i) => i.id == id,
      orElse: () => DecorationData.items.firstWhere(
        (i) => i.type == type, // Fallback to default of type
        orElse: () => DecorationData.items[0], // Ultimate fallback
      ),
    );
  }

  Color _parseColor(String path, Color fallback) {
    if (path.startsWith('0xff') || path.startsWith('0xFF')) {
      return Color(int.parse(path));
    }
    return fallback;
  }
}

class _FurnitureItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double scale;
  final bool hasGlow;

  const _FurnitureItem({
    required this.icon,
    required this.color,
    this.scale = 1.0,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: hasGlow
            ? BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 10,
                  ),
                ],
              )
            : null,
        child: Icon(
          icon,
          color: color,
          size: 60,
          shadows: [
            Shadow(
              color: Colors.black45,
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
        ),
      ),
    );
  }
}
