import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:dream_sort/core/services/ads_service.dart';
import 'package:dream_sort/core/theme/app_theme.dart';
import 'package:dream_sort/features/game/view/decor_page.dart';
import 'package:dream_sort/features/game/view/game_page.dart';
import 'package:dream_sort/features/game/view/levels_page.dart';

import 'package:dream_sort/features/multiplayer/view/multiplayer_menu_page.dart';
import 'package:dream_sort/features/settings/view/settings_page.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import 'package:dream_sort/features/game/repo/game_repository.dart';
import 'package:dream_sort/features/game/widgets/daily_reward_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    // Initialize Ads and show Consent Form if required
    AdsService.init();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Check Daily Reward
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DailyRewardDialog.checkAndShow(context, context.read<GameRepository>());
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          // 1. Premium Background
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

          // 2. Decorative Glows (Animated)
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Stack(
                children: [
                  _buildAnimatedGlow(
                    top: -50 + (20 * _bgController.value),
                    left: -50 - (20 * _bgController.value),
                    size: 300,
                    color: AppTheme.accent.withValues(alpha: 0.15),
                  ),
                  _buildAnimatedGlow(
                    bottom: 100 - (30 * _bgController.value),
                    right: -100 + (30 * _bgController.value),
                    size: 400,
                    color: Colors.purple.withValues(alpha: 0.1),
                  ),
                  _buildAnimatedGlow(
                    top: 200 + (50 * sin(_bgController.value * 2 * pi)),
                    right: -50,
                    size: 200,
                    color: Colors.blue.withValues(alpha: 0.05),
                  ),

                  // Floating Motes
                  ...List.generate(15, (index) {
                    final random = Random(index);
                    final startX = random.nextDouble() * 400;
                    final startY = random.nextDouble() * 800;
                    final speed = 0.5 + random.nextDouble();

                    return Positioned(
                      left:
                          startX +
                          (20 * sin(_bgController.value * 2 * pi * speed)),
                      top: startY - (100 * _bgController.value * speed) % 800,
                      child: Container(
                        width: 2 + (random.nextDouble() * 3),
                        height: 2 + (random.nextDouble() * 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(
                            alpha: 0.1 + (0.2 * random.nextDouble()),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),

          // 3. Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Column(
                children: [
                  // Header: Settings Icon (Top Right)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white70),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const Spacer(flex: 1), // Push Logo down slightly
                  // Logo Section
                  Column(
                    children: [
                      // Icon with Glow
                      AnimatedBuilder(
                        animation: _bgController,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accent.withValues(
                                    alpha:
                                        0.2 +
                                        (0.3 * sin(_bgController.value * pi)),
                                  ),
                                  blurRadius:
                                      40 + (20 * sin(_bgController.value * pi)),
                                  spreadRadius:
                                      5 + (5 * sin(_bgController.value * pi)),
                                ),
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: const Icon(
                          Icons.grid_4x4_rounded, // Abstract puzzle icon
                          color: AppTheme.accent,
                          size: 72,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Title
                      Text(
                        l10n.appTitle,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              l10n.subtitle,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 2), // Space between Logo and Buttons
                  // Buttons Section
                  _buildMenuButton(
                    context,
                    label: l10n.play,
                    icon: Icons.play_arrow_rounded,
                    colors: [const Color(0xFFFF4757), const Color(0xFFFF6B81)],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GamePage()),
                      );
                    },
                    isPrimary: true, // Bigger button
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    context,
                    label: l10n.dailyChallenge,
                    icon: Icons.calendar_today_rounded,
                    colors: [const Color(0xFFFFB300), const Color(0xFFF57C00)],
                    onTap: () {
                      final now = DateTime.now();
                      final seed = now.year * 10000 + now.month * 100 + now.day;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GamePage(
                            isDailyChallenge: true,
                            seed: seed,
                            initialLevel: 999, // Specific marker
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    context,
                    label: l10n.levels,
                    icon: Icons.grid_view_rounded,
                    colors: [const Color(0xFF1E90FF), const Color(0xFF5352ED)],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LevelsPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    context,
                    label: l10n.room,
                    icon: Icons.palette_rounded,
                    colors: [const Color(0xFF7D5FFF), const Color(0xFFA29BFE)],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DecorPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    context,
                    label: l10n.multiplayer,
                    icon: Icons.groups_rounded,
                    colors: [const Color(0xFF009688), const Color(0xFF4DB6AC)],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MultiplayerMenuPage(),
                        ),
                      );
                    },
                  ),

                  const Spacer(flex: 1), // Bottom spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isPrimary ? 64 : 56,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.1),
              blurRadius: 0,
              spreadRadius: -2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              // Shine Sweep Animation
              AnimatedBuilder(
                animation: _shineController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(-200 + (_shineController.value * 600), 0),
                    child: Transform.rotate(
                      angle: 0.5,
                      child: Container(
                        width: 40,
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.2),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: isPrimary ? 28 : 24),
                    const SizedBox(width: 12),
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        fontSize: isPrimary ? 20 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedGlow({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: color.a * 2),
              blurRadius: size / 2,
              spreadRadius: size / 4,
            ),
          ],
        ),
      ),
    );
  }
}
