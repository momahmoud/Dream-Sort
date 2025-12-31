import 'package:dream_sort/features/game/repo/game_repository.dart';
import 'package:dream_sort/features/game/view/game_page.dart';
import 'package:dream_sort/features/game/widgets/level_grid_item.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dream_sort/l10n/app_localizations.dart';

class LevelsPage extends StatelessWidget {
  const LevelsPage({super.key});

  static String _formatNumber(BuildContext context, int number) {
    final locale = AppLocalizations.of(context)?.localeName ?? 'en';
    if (locale == 'ar') {
      const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
      String result = number.toString();
      for (int i = 0; i < 10; i++) {
        result = result.replaceAll(english[i], arabic[i]);
      }
      return result;
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<GameRepository>();
    final maxLevel = repo.getMaxLevel();
    final stars = repo.getStars();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.selectLevel,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          // Star Badge matched to GamePage
          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 3,
              bottom: 3,
            ),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.amber.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/coin.svg',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatNumber(context, stars),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Rich Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E), // Deep Dark Blue
                  Color(0xFF16213E),
                  Color(0xFF1A1A2E),
                ],
              ),
            ),
          ),
          // Subtle Pattern Overlay (Optional)
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: GridPaper(
                color: Colors.white,
                divisions: 4,
                subdivisions: 4,
                interval: 200,
              ),
            ),
          ),

          SafeArea(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, // Denser grid for cleaner look on mobile
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: 150, // Increased level count
              itemBuilder: (context, index) {
                final level = index + 1;

                // Logic
                final bool isLocked = level > maxLevel;
                final bool isCurrent = level == maxLevel;
                final bool isCompleted = level < maxLevel;

                return LevelGridItem(
                  level: level,
                  isLocked: isLocked,
                  isCurrent: isCurrent,
                  isCompleted: isCompleted,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GamePage(initialLevel: level),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
