import 'package:dream_sort/core/theme/app_theme.dart';
import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:dream_sort/features/game/repo/game_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BallWidget extends StatefulWidget {
  final SortingItem item;
  final double size;
  final double opacity;
  final String? skin;

  const BallWidget({
    super.key,
    required this.item,
    this.size = 26.0,
    this.opacity = 1.0,
    this.skin,
  });

  @override
  State<BallWidget> createState() => _BallWidgetState();
}

class _BallWidgetState extends State<BallWidget> with TickerProviderStateMixin {
  late AnimationController _revealController;
  late Animation<double> _flareAnimation;
  late AnimationController _fogController;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flareAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeOut),
    );

    _fogController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(BallWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.isHidden && !widget.item.isHidden) {
      _revealController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _revealController.dispose();
    _fogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item.isStone) {
      return _buildStoneBall();
    }
    if (widget.item.isHidden) {
      return _buildHiddenBall();
    }

    final repo = context.read<GameRepository>();
    final isColorBlind = repo.isColorBlindEnabled;
    final skin = widget.skin ?? repo.getBallSkin();

    return Stack(
      children: [
        _buildSkinnedBall(skin),

        // Color Blind Symbol - Enhanced Visuals
        if (isColorBlind)
          Positioned.fill(
            child: Center(child: _getColorBlindSymbol(widget.item.colorIndex)),
          ),

        // Chains/Lock UI
        if (widget.item.isLocked) Positioned.fill(child: _buildChains()),

        // Reveal Flare Effect
        AnimatedBuilder(
          animation: _flareAnimation,
          builder: (context, child) {
            if (_revealController.value == 0 ||
                _revealController.value == 1.0) {
              return const SizedBox.shrink();
            }
            final flareOpacity =
                (1.0 - _revealController.value) * widget.opacity;
            return Transform.scale(
              scale: 1.0 + (_revealController.value * 1.5),
              child: Container(
                width: widget.size,
                height: widget.size * (44 / 48),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.8 * flareOpacity),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSkinnedBall(String skin) {
    switch (skin) {
      case 'neon':
        return _buildNeonBall();
      case 'emoji':
        return _buildEmojiBall();
      case 'jewel':
        return _buildJewelBall();
      case 'planets':
        return _buildPlanetBall();
      case 'sports':
        return _buildSportsBall();
      default:
        return _buildNormalBall();
    }
  }

  Widget _buildPlanetBall() {
    final baseColor = AppTheme
        .sortColors[widget.item.colorIndex % AppTheme.sortColors.length];
    final opacity = widget.opacity;
    final width = widget.size;
    final height = widget.size * (44 / 48);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.8 * opacity),
            baseColor.withValues(alpha: opacity),
            Color.lerp(
              baseColor,
              Colors.black,
              0.4,
            )!.withValues(alpha: opacity),
          ],
          center: const Alignment(-0.3, -0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.5 * opacity),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: width * 0.7,
          height: height * 0.7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2 * opacity),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSportsBall() {
    final List<IconData> sportsIcons = [
      Icons.sports_basketball_rounded,
      Icons.sports_soccer_rounded,
      Icons.sports_baseball_rounded,
      Icons.sports_tennis_rounded,
      Icons.sports_volleyball_rounded,
      Icons.sports_football_rounded,
      Icons.sports_cricket_rounded,
      Icons.sports_golf_rounded,
    ];
    final iconData = sportsIcons[widget.item.colorIndex % sportsIcons.length];
    final baseColor = AppTheme
        .sortColors[widget.item.colorIndex % AppTheme.sortColors.length];
    final opacity = widget.opacity;

    return Container(
      width: widget.size,
      height: widget.size * (44 / 48),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: opacity),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white30, width: 1),
      ),
      child: Center(
        child: Icon(
          iconData,
          color: Colors.white.withValues(alpha: 0.8 * opacity),
          size: widget.size * 0.65,
        ),
      ),
    );
  }

  Widget _buildNeonBall() {
    final baseColor = AppTheme
        .sortColors[widget.item.colorIndex % AppTheme.sortColors.length];
    final opacity = widget.opacity;
    final width = widget.size;
    final height = widget.size * (44 / 48);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.15 * opacity),
        shape: BoxShape.circle,
        border: Border.all(
          color: baseColor.withValues(alpha: 0.9 * opacity),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.6 * opacity),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: width * 0.4,
          height: height * 0.4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8 * opacity),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: baseColor.withValues(alpha: 0.8 * opacity),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiBall() {
    final baseColor = AppTheme
        .sortColors[widget.item.colorIndex % AppTheme.sortColors.length];
    final emojis = [
      '😊',
      '😎',
      '🤩',
      '🥳',
      '😇',
      '🤔',
      '😴',
      '🙄',
      '🔥',
      '💎',
      '🍀',
      '🍕',
    ];
    final emoji = emojis[widget.item.colorIndex % emojis.length];

    return Container(
      width: widget.size,
      height: widget.size * (44 / 48),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: widget.opacity),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white30, width: 1),
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: widget.size * 0.6)),
      ),
    );
  }

  Widget _buildJewelBall() {
    final baseColor = AppTheme
        .sortColors[widget.item.colorIndex % AppTheme.sortColors.length];
    final width = widget.size;
    final height = widget.size * (44 / 48);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.6 * widget.opacity),
            baseColor.withValues(alpha: widget.opacity),
            baseColor.withValues(alpha: 0.8 * widget.opacity),
            Colors.black.withValues(alpha: 0.2 * widget.opacity),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white54, width: 0.5),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.diamond_outlined,
              color: Colors.white.withValues(alpha: 0.3),
              size: width * 0.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalBall() {
    final baseColor = AppTheme
        .sortColors[widget.item.colorIndex % AppTheme.sortColors.length];
    final opacity = widget.opacity;
    final width = widget.size;
    final height = widget.size * (44 / 48);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor.withValues(alpha: 0.8 * opacity),
            baseColor.withValues(alpha: opacity),
            baseColor.withValues(alpha: 0.9 * opacity),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.4 * opacity),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3 * opacity),
            blurRadius: 2,
            offset: const Offset(1, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3 * opacity),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Inner gloss highlight
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width * 0.2),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.3 * opacity),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Top specular highlight
          Positioned(
            top: height * 0.1,
            left: width * 0.1,
            child: Container(
              width: width * 0.25,
              height: height * 0.15,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6 * opacity),
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

  Widget _getColorBlindSymbol(int index) {
    // Curated symbols that are distinct
    final List<IconData> symbols = [
      Icons.star_rounded,
      Icons.favorite_rounded,
      Icons.circle_rounded,
      Icons.square_rounded,
      Icons.change_history_rounded, // Triangle
      Icons.diamond_rounded,
      Icons.pentagon_rounded,
      Icons.hexagon_rounded,
      Icons.wb_sunny_rounded,
      Icons.auto_awesome_rounded,
      Icons.flash_on_rounded,
      Icons.eco_rounded,
      Icons.rocket_launch_rounded,
      Icons.anchor_rounded,
      Icons.ac_unit_rounded,
      Icons.pest_control_rodent_rounded,
      Icons.music_note_rounded,
      Icons.emoji_objects_rounded, // Lightbulb
      Icons.extension_rounded,
      Icons.brightness_2_rounded, // Moon
      Icons.terrain_rounded, // Mountains
      Icons.waves_rounded,
      Icons.palette_rounded,
      Icons.category_rounded,
    ];

    final iconData = symbols[index % symbols.length];
    final opacity = widget.opacity;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          // Subtle drop shadow for the icon itself to appear embossed
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2 * opacity),
            blurRadius: 1,
            offset: const Offset(0.5, 0.5),
          ),
        ],
      ),
      child: Icon(
        iconData,
        size: widget.size * 0.45,
        color: Colors.white.withValues(alpha: 0.7 * opacity),
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.2 * opacity),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildHiddenBall() {
    final width = widget.size;
    final height = widget.size * (44 / 48);
    final opacity = widget.opacity;

    return AnimatedBuilder(
      animation: _fogController,
      builder: (context, _) {
        final breathe = 1.0 + (_fogController.value * 0.1); // 1.0 -> 1.1
        final glowOpacity = 0.2 + (_fogController.value * 0.3); // 0.2 -> 0.5

        return Transform.scale(
          scale: breathe,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(
                0xFF673AB7,
              ).withValues(alpha: opacity), // Deep Purple
              borderRadius: BorderRadius.circular(width * 0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.purpleAccent.withValues(
                    alpha: glowOpacity * opacity,
                  ),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3 * opacity),
                  blurRadius: 3,
                  offset: const Offset(1, 2),
                ),
              ],
              border: Border.all(
                color: Colors.white30.withValues(alpha: opacity),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '?',
                style: TextStyle(
                  color: Colors.white.withValues(
                    alpha: (0.7 + glowOpacity * 0.5).clamp(0.0, 1.0) * opacity,
                  ),
                  fontSize: widget.size * 0.6,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoneBall() {
    final width = widget.size;
    final height = widget.size * (44 / 48);
    final opacity = widget.opacity;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF424242).withValues(alpha: opacity),
            const Color(0xFF757575).withValues(alpha: opacity),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(width * 0.2),
        border: Border.all(
          color: Colors.black54.withValues(alpha: opacity),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black45.withValues(alpha: opacity),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.block,
          color: Colors.grey.shade800.withValues(alpha: opacity),
          size: 18,
        ),
      ),
    );
  }

  Widget _buildChains() {
    final opacity = widget.opacity;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.shade400.withValues(
            alpha: opacity,
          ), // Metallic ring
          width: 3,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.lock_rounded,
          color: Colors.white.withValues(alpha: 0.9 * opacity),
          size: widget.size * 0.5,
          shadows: [
            Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(1, 1)),
          ],
        ),
      ),
    );
  }
}
