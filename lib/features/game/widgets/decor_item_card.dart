import 'package:dream_sort/features/game/models/decor_models.dart';
import 'package:dream_sort/features/game/widgets/decor_item_preview.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class DecorItemCard extends StatelessWidget {
  final DecorItem item;
  final bool isUnlocked;
  final bool isEquipped;
  final VoidCallback onTap;

  const DecorItemCard({
    super.key,
    required this.item,
    required this.isUnlocked,
    required this.isEquipped,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 140,
        margin: const EdgeInsets.only(right: 16, bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isEquipped
                ? Colors.amber
                : Colors.white.withValues(alpha: 0.1),
            width: isEquipped ? 3 : 1,
          ),
          boxShadow: [
            if (isEquipped)
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.2),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Preview Area
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                    ),
                    child: Center(
                      child: DecorItemPreview(
                        item: item,
                        isLocked: !isUnlocked && !item.isDefault,
                      ),
                    ),
                  ),
                ),
                // Info Area
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getItemName(context, item.id, item.name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isUnlocked)
                          Row(
                            children: [
                              const Icon(
                                Icons.monetization_on_rounded,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${item.cost}',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                        else if (isEquipped)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              l10n.equipped.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          )
                        else
                          Text(
                            l10n.owned,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Locked Overlay
            if (!isUnlocked && !item.isDefault)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    size: 14,
                    color: Colors.white70,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getItemName(BuildContext context, String id, String defaultName) {
    final l10n = AppLocalizations.of(context)!;
    switch (id) {
      case 'tube_default':
        return l10n.item_tube_default;
      case 'tube_bamboo':
        return l10n.item_tube_bamboo;
      case 'tube_metal':
        return l10n.item_tube_metal;
      case 'tube_gold_rim':
        return l10n.item_tube_gold_rim;
      case 'wall_default':
        return l10n.item_wall_default;
      case 'wall_purple':
        return l10n.item_wall_purple;
      case 'wall_teal':
        return l10n.item_wall_teal;
      case 'wall_red':
        return l10n.item_wall_red;
      case 'wall_grey':
        return l10n.item_wall_grey;
      case 'wall_black':
        return l10n.item_wall_black;
      case 'wall_sunset':
        return l10n.item_wall_sunset;
      case 'wall_matrix':
        return l10n.item_wall_matrix;
      case 'floor_default':
        return l10n.item_floor_default;
      case 'floor_marble':
        return l10n.item_floor_marble;
      case 'floor_stone':
        return l10n.item_floor_stone;
      case 'floor_carpet':
        return l10n.item_floor_carpet;
      case 'floor_gold':
        return l10n.item_floor_gold;
      case 'floor_grass':
        return l10n.item_floor_grass;
      case 'plant_none':
        return l10n.item_plant_none;
      case 'plant_fern':
        return l10n.item_plant_fern;
      case 'plant_bamboo':
        return l10n.item_plant_bamboo;
      case 'plant_tree':
        return l10n.item_plant_tree;
      case 'plant_lotus':
        return l10n.item_plant_lotus;
      case 'plant_cactus':
        return l10n.item_plant_cactus;
      case 'lamp_none':
        return l10n.item_lamp_none;
      case 'lamp_classic':
        return l10n.item_lamp_classic;
      case 'lamp_modern':
        return l10n.item_lamp_modern;
      case 'lamp_sun':
        return l10n.item_lamp_sun;
      case 'lamp_torch':
        return l10n.item_lamp_torch;
      case 'rug_none':
        return l10n.item_rug_none;
      case 'rug_shag':
        return l10n.item_rug_shag;
      case 'rug_round':
        return l10n.item_rug_round;
      case 'rug_royal':
        return l10n.item_rug_royal;
      case 'rug_persian':
        return l10n.item_rug_persian;
      case 'paint_none':
        return l10n.item_paint_none;
      case 'paint_abstract':
        return l10n.item_paint_abstract;
      case 'paint_portrait':
        return l10n.item_paint_portrait;
      case 'paint_landscape':
        return l10n.item_paint_landscape;
      case 'paint_starry':
        return l10n.item_paint_starry;
      case 'tube_crystal':
        return l10n.item_tube_crystal;
      case 'tube_magma':
        return l10n.item_tube_magma;
      case 'ball_default':
        return l10n.item_ball_default;
      case 'ball_neon':
        return l10n.item_ball_neon;
      case 'ball_emoji':
        return l10n.item_ball_emoji;
      case 'ball_jewel':
        return l10n.item_ball_jewel;
      case 'ball_planets':
        return l10n.item_ball_planets;
      case 'ball_sports':
        return l10n.item_ball_sports;
      default:
        return defaultName;
    }
  }
}
