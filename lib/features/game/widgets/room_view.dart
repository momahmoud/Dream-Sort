import 'dart:math';
import 'package:dream_sort/features/game/models/decor_models.dart';
import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:dream_sort/features/game/widgets/ball_widget.dart';
import 'package:dream_sort/features/game/widgets/tube_widget.dart';
import 'package:dream_sort/features/game/widgets/dynamic_background.dart';
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

    return Stack(
      fit: StackFit.expand,
      children: [
        // WALL (Background - Dynamic)
        Positioned.fill(
          bottom: 150,
          child: DynamicBackground(baseColor: wallColor),
        ),

        // Floating Motes (Atmosphere)
        const Positioned.fill(child: _FloatingMotes()),

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

        // PAINTING
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
                  type: DecorType.painting,
                  itemId: paintItem.id,
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
                type: DecorType.rug,
                itemId: rugItem.id,
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
              type: DecorType.plant,
              itemId: plantItem.id,
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
              type: DecorType.lamp,
              itemId: lampItem.id,
              icon: lampItem.iconData!,
              color: Colors.orangeAccent,
              scale: 1.5,
              hasGlow: true,
            ),
          ),

        // GAMEPLAY PREVIEW (Tube + Ball Skins)
        if (showCenterVisual)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Tube Preview
                  // We need to pass the skin explicitly to TubeWidget or rely on Repo.
                  // Since Repo uses equipped items, it should automatically pick up changes
                  // IF the repo state has updated. The RoomView is rebuilt when we buy/equip items.
                  // However, TubeWidget inside RoomView might just use what the Repo says is equipped.
                  // Let's ensure TubeWidget logic reads the correct skin.
                  Transform.scale(
                    scale: 0.8,
                    child: IgnorePointer(
                      child: TubeWidget(
                        tube: Tube(
                          items: [
                            SortingItem(colorIndex: 0),
                            SortingItem(colorIndex: 1),
                            SortingItem(colorIndex: 2),
                          ],
                          capacity: 4,
                        ),
                        // Force a specific skin if needed, but TubeWidget pulls from Repo.
                        // Ideally we'd pass the skin from 'equipped' map to TubeWidget
                        // but TubeWidget is designed to pull from repo.
                        // Assuming RoomView rebuilds after equip, this is fine.
                        isSelected: false,
                        onTap: () {},
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Ball Preview
                  Transform.scale(
                    scale: 1.2,
                    child: IgnorePointer(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: BallWidget(
                          item: SortingItem(colorIndex: 0),
                          // BallWidget also pulls from Repo.
                        ),
                      ),
                    ),
                  ),
                ],
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
        (i) => i.type == type,
        orElse: () => DecorationData.items[0],
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
  final DecorType type;
  final String itemId; // Added to distinguish specific items
  final IconData icon;
  final Color color;
  final double scale;
  final bool hasGlow;

  const _FurnitureItem({
    required this.type,
    required this.itemId,
    required this.icon,
    required this.color,
    this.scale = 1.0,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    if (type == DecorType.rug) {
      return _buildRug();
    } else if (type == DecorType.painting) {
      return _buildPainting();
    } else if (type == DecorType.plant) {
      return _buildPlant();
    } else if (type == DecorType.lamp) {
      return _buildLamp();
    } else {
      return _buildStandardProp();
    }
  }

  Widget _buildRug() {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(1.2), // Perspective tilt to lay flat
      alignment: Alignment.center,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(icon, color: color.withValues(alpha: 0.8), size: 40),
        ),
      ),
    );
  }

  Widget _buildPainting() {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 80,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C), // Canvas background
          border: Border.all(
            color: const Color(0xFF8D6E63), // Wood frame
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRect(
          child: Center(child: Icon(icon, color: color, size: 40)),
        ),
      ),
    );
  }

  Widget _buildPlant() {
    // Pot Style
    final potColor = const Color(0xFF795548); // Brown

    return Transform.scale(
      scale: scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Foliage - using CustomPaint for organic shapes or specific icons
          SizedBox(
            height: 50,
            width: 50,
            child: _PlantFoliage(itemId: itemId, color: color, icon: icon),
          ),
          // Pot
          Container(
            width: 30,
            height: 25,
            decoration: BoxDecoration(
              color: potColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: potColor.withValues(alpha: 0.8),
                width: 2,
              ),
            ),
            child: Center(
              child: Container(
                width: 20,
                height: 2,
                color: Colors.black.withValues(alpha: 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLamp() {
    // Determine lamp style based on Item ID
    bool isWallLamp = itemId.contains('sconce') || itemId.contains('neon');
    bool isFloorLamp = !isWallLamp;

    if (itemId == 'lamp_sun') {
      return _buildSunLamp();
    }
    if (itemId == 'lamp_torch') {
      return _buildTorch();
    }

    return Transform.scale(
      scale: scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Lamp Shade / Light
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.9),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          // Stand (if floor lamp)
          if (isFloorLamp)
            Container(width: 4, height: 40, color: Colors.grey[400]),
          // Base
          if (isFloorLamp)
            Container(
              width: 20,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSunLamp() {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.orangeAccent,
              Colors.deepOrange,
              Colors.transparent,
            ],
            stops: const [0.3, 0.6, 1.0],
          ),
        ),
        child: const Center(
          child: Icon(Icons.sunny, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildTorch() {
    return Transform.scale(
      scale: scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Flame
          Container(
            width: 20,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withValues(alpha: 0.6),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          // Base
          Container(width: 6, height: 20, color: Colors.brown[700]),
        ],
      ),
    );
  }

  Widget _buildStandardProp() {
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

class _PlantFoliage extends StatelessWidget {
  final String itemId;
  final Color color;
  final IconData icon;

  const _PlantFoliage({
    required this.itemId,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (itemId.contains('cactus')) {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 14,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 15,
            child: Container(
              width: 8,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green[600],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      );
    }
    // Default fallback to icon but styled
    return Icon(icon, color: color, size: 40);
  }
}

class _FloatingMotes extends StatefulWidget {
  const _FloatingMotes();

  @override
  State<_FloatingMotes> createState() => _FloatingMotesState();
}

class _FloatingMotesState extends State<_FloatingMotes>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Mote> _motes = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    for (int i = 0; i < 15; i++) {
      _motes.add(_generateMote());
    }
  }

  _Mote _generateMote() {
    return _Mote(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * 2 + 1,
      speed: _random.nextDouble() * 0.005 + 0.002,
      drift: _random.nextDouble() * 0.02 - 0.01,
      opacity: _random.nextDouble() * 0.3 + 0.1,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(painter: _MotePainter(_motes, _controller.value));
      },
    );
  }
}

class _Mote {
  double x;
  double y;
  final double size;
  final double speed;
  final double drift;
  final double opacity;

  _Mote({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.drift,
    required this.opacity,
  });
}

class _MotePainter extends CustomPainter {
  final List<_Mote> motes;
  final double progress;

  _MotePainter(this.motes, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var mote in motes) {
      // Calculate current position with wrap-around
      final currentY = (mote.y - (progress * mote.speed * 100)) % 1.0;
      final currentX = (mote.x + sin(progress * pi * 2) * mote.drift) % 1.0;

      final pos = Offset(currentX * size.width, currentY * size.height);

      paint.color = Colors.white.withValues(
        alpha:
            mote.opacity * (0.5 + 0.5 * sin(progress * pi * 2 + mote.x * 10)),
      );

      canvas.drawCircle(pos, mote.size, paint);

      // Add a subtle glow/blur
      paint.color = paint.color.withValues(alpha: paint.color.a * 0.3);
      canvas.drawCircle(pos, mote.size * 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
