import 'package:dream_sort/features/game/models/decor_models.dart';
import 'package:flutter/material.dart';
import 'package:dream_sort/l10n/app_localizations.dart';

class DecorCategoryTabs extends StatelessWidget {
  final DecorType selectedType;
  final ValueChanged<DecorType> onSelect;

  const DecorCategoryTabs({
    super.key,
    required this.selectedType,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: DecorType.values.map((type) {
          final isSelected = type == selectedType;
          return GestureDetector(
            onTap: () => onSelect(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white24,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(type),
                    size: 18,
                    color: isSelected ? Colors.black : Colors.white70,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getCategoryName(context, type).toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getCategoryName(BuildContext context, DecorType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case DecorType.wall:
        return l10n.decorTypeWall;
      case DecorType.floor:
        return l10n.decorTypeFloor;
      case DecorType.rug:
        return l10n.decorTypeRug;
      case DecorType.plant:
        return l10n.decorTypePlant;
      case DecorType.lamp:
        return l10n.decorTypeLamp;
      case DecorType.painting:
        return l10n.decorTypePainting;
      case DecorType.tube:
        return l10n.decorTypeTube;
      case DecorType.ball:
        return l10n.decorTypeBall;
    }
  }

  IconData _getCategoryIcon(DecorType type) {
    switch (type) {
      case DecorType.wall:
        return Icons.wallpaper;
      case DecorType.floor:
        return Icons.grid_view;
      case DecorType.rug:
        return Icons.check_box_outline_blank_rounded;
      case DecorType.plant:
        return Icons.local_florist;
      case DecorType.lamp:
        return Icons.lightbulb_outline;
      case DecorType.painting:
        return Icons.image;
      case DecorType.tube:
        return Icons.science;
      case DecorType.ball:
        return Icons.circle;
    }
  }
}
