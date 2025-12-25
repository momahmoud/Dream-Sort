import 'package:dream_sort/core/theme/app_theme.dart';
import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:flutter/material.dart';

class BallWidget extends StatelessWidget {
  final SortingItem item;
  final double size;

  const BallWidget({super.key, required this.item, this.size = 48.0});

  @override
  Widget build(BuildContext context) {
    // If hidden, render a mystery ball
    if (item.isHidden) {
      final width = size;
      final height = size * (44 / 48);
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(width * 0.3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 2,
              offset: const Offset(1, 2),
            ),
          ],
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        child: const Center(
          child: Text(
            '?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // Cycle through colors based on index
    final color =
        AppTheme.sortColors[item.colorIndex % AppTheme.sortColors.length];

    // Maintain aspect ratio nicely if size changes
    final width = size;
    final height = size * (44 / 48); // 44 height for 48 width originally

    return Container(
      // External margin is handled by parent usually, but we keep the visual style self-contained
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.3), // approx 14 for 48
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.8),
            color,
            color.withValues(alpha: 0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(1, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Specular highlight
          Positioned(
            top: height * 0.1,
            left: width * 0.1,
            child: Container(
              width: width * 0.25,
              height: height * 0.15,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.all(
                  Radius.elliptical(width * 0.25, height * 0.15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
