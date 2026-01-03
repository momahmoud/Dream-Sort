import 'package:dream_sort/features/game/bloc/game_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../l10n/app_localizations.dart';

class WinOverlayWidget extends StatefulWidget {
  final VoidCallback onRestartTimer;

  const WinOverlayWidget({super.key, required this.onRestartTimer});

  @override
  State<WinOverlayWidget> createState() => _WinOverlayWidgetState();
}

class _WinOverlayWidgetState extends State<WinOverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  late AnimationController _pulseController;
  late Animation<double> _coinPulseAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Entrance Animation (Pop in)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // 2. Continuous Coin Pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _coinPulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // Start entrance
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Theme colors matching the screenshot style (Green Success Theme)
    const accentColor = Color(0xFF4CAF50); // Vibrant Green
    const darkBg = Color(0xFF16213E);

    return Center(
      child: AnimatedBuilder(
        animation: _entranceController,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(scale: _scaleAnimation.value, child: child),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: darkBg,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: accentColor, width: 3),
            boxShadow: [
              // Outer glow matching the screenshot
              BoxShadow(
                color: accentColor.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 2,
              ),
              // Inner subtle shine
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.05),
                blurRadius: 0,
                spreadRadius: 0,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Pulsing Coin
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _coinPulseAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    'assets/images/coin.svg',
                    width: 100,
                    height: 100,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 2. Text with Glow
              Text(
                l10n.dreamSorted,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  height: 1.1,
                  shadows: [
                    Shadow(
                      color: accentColor,
                      blurRadius: 15,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),

              // Coin Result
              BlocBuilder<GameBloc, GameState>(
                builder: (context, state) {
                  int reward = state.isDailyChallenge ? 100 : 25;
                  if (state.undosUsed == 0) {
                    reward += state.isDailyChallenge ? 50 : 20;
                  } else if (state.undosUsed <= 2) {
                    reward += state.isDailyChallenge ? 25 : 10;
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, color: Colors.amber, size: 24),
                        Text(
                          '$reward',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          'assets/images/coin.svg',
                          width: 32,
                          height: 32,
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Perfect Badge
              BlocBuilder<GameBloc, GameState>(
                builder: (context, state) {
                  if (state.undosUsed > 0) return const SizedBox(height: 16);
                  return Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.perfect,
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ],
                    ),
                  );
                },
              ),

              // 3. Shiny Gradient Button
              StatefulBuilder(
                builder: (context, setState) {
                  return GestureDetector(
                    onTap: () {
                      context.read<GameBloc>().add(NextLevel());
                      widget.onRestartTimer();
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF66BB6A),
                                  Color(0xFF43A047),
                                  Color(0xFF2E7D32),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.nextLevel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          // Shine Effect
                          Positioned.fill(child: _ShinyOverlay()),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShinyOverlay extends StatefulWidget {
  @override
  State<_ShinyOverlay> createState() => _ShinyOverlayState();
}

class _ShinyOverlayState extends State<_ShinyOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
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
        return Transform.translate(
          offset: Offset(
            -200 + (400 * _controller.value), // Sweep across
            0,
          ),
          child: Transform.rotate(
            angle: 0.5, // Slanted shine
            child: Container(
              width: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.3),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
