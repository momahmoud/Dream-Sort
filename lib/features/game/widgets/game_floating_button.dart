import 'package:flutter/material.dart';

class GameFloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final bool disabled;

  const GameFloatingButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: disabled
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
        border: Border.all(
          color: disabled ? Colors.white10 : Colors.white24,
          width: 1.5,
        ),
        boxShadow: disabled
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Center(
        child: Icon(
          icon,
          color: disabled ? Colors.white24 : Colors.white,
          size: 20,
        ),
      ),
    );

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: tooltip != null
          ? Tooltip(message: tooltip, child: widget)
          : widget,
    );
  }
}
