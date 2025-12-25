import 'package:flutter/material.dart';

class LevelGridItem extends StatefulWidget {
  final int level;
  final bool isLocked;
  final bool isCurrent;
  final VoidCallback onTap;

  const LevelGridItem({
    super.key,
    required this.level,
    required this.isLocked,
    required this.isCurrent,
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
            gradient: widget.isLocked
                ? LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.05),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isCurrent
                        ? [const Color(0xFFFF512F), const Color(0xFFDD2476)]
                        : [const Color(0xFF1CB5E0), const Color(0xFF000046)],
                  ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: widget.isLocked
                ? []
                : [
                    BoxShadow(
                      color: widget.isCurrent
                          ? Colors.pinkAccent.withValues(alpha: 0.4)
                          : Colors.cyanAccent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
            border: Border.all(
              color: widget.isCurrent
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.1),
              width: widget.isCurrent ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              if (!widget.isLocked)
                Positioned(
                  top: -10,
                  right: -10,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Center(
                child: widget.isLocked
                    ? Icon(
                        Icons.lock_rounded,
                        color: Colors.white.withValues(alpha: 0.2),
                        size: 24,
                      )
                    : Text(
                        '${widget.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
              ),
              if (widget.isCurrent)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
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
