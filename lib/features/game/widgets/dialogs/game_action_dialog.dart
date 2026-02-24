import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GameActionDialog extends StatelessWidget {
  final String title;
  final String description;
  final Widget? icon; // Can be Icon or SvgPicture
  final String actionLabel;
  final VoidCallback onAction;
  final List<Color> actionGradientColors;
  final Color actionShadowColor;
  final Color? borderColor;
  final IconData? actionIconData;
  final String? cost;
  final String cancelLabel;
  final VoidCallback? onSecondaryAction;
  final String? secondaryActionLabel;
  final IconData? secondaryActionIconData;

  const GameActionDialog({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    required this.actionLabel,
    required this.onAction,
    this.actionGradientColors = const [Color(0xFF2196F3), Color(0xFF1976D2)],
    this.actionShadowColor = Colors.blue,
    this.borderColor,
    this.actionIconData,
    this.cost,
    this.cancelLabel = 'No Thanks',
    this.onSecondaryAction,
    this.secondaryActionLabel,
    this.secondaryActionIconData,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Main Card
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Button
                    GestureDetector(
                      onTap: onAction,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: actionGradientColors,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: actionShadowColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (actionIconData != null) ...[
                              Icon(
                                actionIconData,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              actionLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (cost != null) ...[
                              const SizedBox(width: 8),
                              SvgPicture.asset(
                                'assets/images/coin.svg',
                                width: 18,
                                height: 18,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                cost!, // e.g. "50)"
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (onSecondaryAction != null &&
                        secondaryActionLabel != null) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: onSecondaryAction,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF42425A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (secondaryActionIconData != null) ...[
                                Icon(
                                  secondaryActionIconData,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                secondaryActionLabel!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Cancel Button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white38,
                      ),
                      child: Text(cancelLabel),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Top Floating Icon
          if (icon != null)
            Positioned(
              top: -30,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor ?? actionShadowColor,
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: icon,
              ),
            ),
        ],
      ),
    );
  }
}
