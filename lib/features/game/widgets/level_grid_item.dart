import 'package:dream_sort/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class LevelGridItem extends StatefulWidget {
  final int level;
  final bool isLocked;
  final bool isCurrent;
  final bool isCompleted; // NEW
  final VoidCallback onTap;

  const LevelGridItem({
    super.key,
    required this.level,
    required this.isLocked,
    required this.isCurrent,
    this.isCompleted = false,
    required this.onTap,
  });

  @override
  State<LevelGridItem> createState() => _LevelGridItemState();
}

class _LevelGridItemState extends State<LevelGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> get _gradientColors {
    if (widget.isLocked) {
      return [
        Colors.white.withValues(alpha: 0.05),
        Colors.white.withValues(alpha: 0.02),
      ];
    }
    if (widget.isCurrent) {
      // Match "Play" button: [Color(0xFFFF4757), Color(0xFFFF6B81)]
      return [const Color(0xFFFF4757), const Color(0xFFFF6B81)];
    }
    // Completed
    // Match "Levels" button: [Color(0xFF1E90FF), Color(0xFF5352ED)]
    return [const Color(0xFF1E90FF), const Color(0xFF5352ED)];
  }

  Color get _shadowColor {
    if (widget.isLocked) return Colors.transparent;
    if (widget.isCurrent) return const Color(0xFFFF4757).withValues(alpha: 0.4);
    return const Color(0xFF1E90FF).withValues(alpha: 0.3);
  }

  String _formatNumber(int number) {
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
    return GestureDetector(
      onTapDown: (_) => !widget.isLocked ? _controller.forward() : null,
      onTapUp: (_) => !widget.isLocked ? _controller.reverse() : null,
      onTapCancel: () => !widget.isLocked ? _controller.reverse() : null,
      onTap: widget.isLocked ? null : widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _gradientColors,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: widget.isLocked
                ? []
                : [
                    BoxShadow(
                      color: _shadowColor,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
            border: Border.all(
              color: widget.isCurrent
                  ? Colors.white.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.15),
              width: widget.isCurrent ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              // 1. Gloss / Inner Glow (Top Left Highlight)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6],
                  ),
                ),
              ),

              // 2. Deco Circle (Top Right)
              if (!widget.isLocked)
                Positioned(
                  top: -15,
                  right: -15,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

              // 3. Content
              Center(
                child: widget.isLocked
                    ? Icon(
                        Icons.lock_rounded,
                        color: Colors.white.withValues(alpha: 0.3),
                        size: 24,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatNumber(widget.level),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              // fontFamily: 'Play', // Handled by Theme
                              shadows: widget.isCompleted
                                  ? []
                                  : [
                                      const Shadow(
                                        color: Colors.black26,
                                        offset: Offset(1, 1),
                                        blurRadius: 3,
                                      ),
                                    ],
                            ),
                          ),
                        ],
                      ),
              ),

              // 4. Current Indicator (Dot)
              if (widget.isCurrent)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.play.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFDD2476),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
