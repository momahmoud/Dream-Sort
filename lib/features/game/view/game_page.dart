import 'package:vibration/vibration.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:dream_sort/core/services/ads_service.dart';

import 'package:dream_sort/core/audio/audio_controller.dart';
import 'package:dream_sort/features/game/bloc/game_bloc.dart';
import 'package:dream_sort/features/game/models/decor_models.dart';
import 'package:dream_sort/features/game/repo/game_repository.dart';
import 'package:dream_sort/features/game/widgets/confetti_overlay.dart';
import 'package:dream_sort/features/game/widgets/dialogs/game_action_dialog.dart';
import 'package:dream_sort/features/game/widgets/flying_ball_manager.dart';
import 'package:dream_sort/features/game/widgets/game_bottom_controls.dart';
import 'package:dream_sort/features/game/widgets/game_header.dart';

import 'package:dream_sort/features/game/widgets/room_view.dart';
import 'package:dream_sort/features/game/widgets/game_board.dart';
import 'package:dream_sort/features/game/widgets/win_overlay_widget.dart';
import 'package:dream_sort/features/game/widgets/hint_overlay.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dream_sort/l10n/app_localizations.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GamePage extends StatefulWidget {
  final int? initialLevel;
  final int? seed;
  final bool isDailyChallenge;

  const GamePage({
    super.key,
    this.initialLevel,
    this.seed,
    this.isDailyChallenge = false,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<GlobalKey> _tubeKeys = [];
  final Map<int, int> _hiddenTargets = {};
  DateTime? _lastLevelStartTime;

  // Ads
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  bool _isBannerAdLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBannerAd();
  }

  Future<void> _loadBannerAd() async {
    if (_isBannerAdReady || _bannerAd != null || _isBannerAdLoading) return;
    _isBannerAdLoading = true;

    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
          MediaQuery.of(context).size.width.truncate(),
        );

    if (size == null) {
      debugPrint('Unable to get height of anchored banner.');
      _isBannerAdLoading = false;
      return;
    }

    _bannerAd = AdsService.loadBanner(
      size: size,
      onAdLoaded: (ad) {
        if (!mounted) {
          ad.dispose();
          return;
        }
        setState(() {
          _bannerAd = ad as BannerAd;
          _isBannerAdReady = true;
          _isBannerAdLoading = false;
        });
      },
      onAdFailed: (error) {
        debugPrint('BannerAd failed to load: $error');
        _isBannerAdReady = false;
        _isBannerAdLoading = false;
        _bannerAd?.dispose();
        _bannerAd = null;
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<bool> _showQuitDialog(BuildContext innerContext) async {
    final state = innerContext.read<GameBloc>().state;
    if (state.moveHistory.isEmpty || state.status == GameStatus.won) {
      return true;
    }
    final l10n = AppLocalizations.of(innerContext)!;
    final confirmed = await showDialog<bool>(
      context: innerContext,
      builder: (_) => GameActionDialog(
        title: l10n.quitGame,
        description: l10n.quitGameDesc,
        icon: const Icon(
          Icons.exit_to_app_rounded,
          color: Colors.white,
          size: 36,
        ),
        borderColor: Colors.redAccent,
        actionLabel: l10n.quitGameAction,
        actionIconData: Icons.exit_to_app_rounded,
        actionGradientColors: const [Color(0xFFE53935), Color(0xFFB71C1C)],
        actionShadowColor: Colors.red,
        onAction: () => Navigator.of(innerContext).pop(true),
        cancelLabel: l10n.keepPlaying,
      ),
    );
    return confirmed == true;
  }

  void _handleGameStateChange(BuildContext context, GameState state) {
    // 1. Manage Tube Keys
    bool isNewGameInstance = _lastLevelStartTime != state.levelStartTime;
    if (isNewGameInstance) {
      _lastLevelStartTime = state.levelStartTime;
    }

    if (_tubeKeys.length != state.tubes.length || isNewGameInstance) {
      setState(() {
        _tubeKeys = List.generate(state.tubes.length, (_) => GlobalKey());
      });
    }

    // 2. Check for Win status
    // 2. Check for Win status
    if (state.status == GameStatus.won) {
      // Haptic Feedback for Win
      Vibration.hasVibrator().then((has) {
        if (has == true) {
          Vibration.vibrate(pattern: [0, 50, 100, 50]);
        }
      });
      // Show Interstitial on Win (Best Practice: Preloaded)
      AdsService.showInterstitial();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Force rebuild when popping back from DecorPage to update wall color
    return BlocProvider(
      create: (context) =>
          GameBloc(
            repo: context.read<GameRepository>(),
            audio: context.read<AudioController>(),
          )..add(
            LoadLevel(
              levelId: widget.initialLevel,
              seed: widget.seed,
              isDailyChallenge: widget.isDailyChallenge,
            ),
          ),
      child: BlocListener<GameBloc, GameState>(
        listener: (context, state) => _handleGameStateChange(context, state),
        child: Stack(
          children: [
            ValueListenableBuilder(
              valueListenable: Hive.box(
                'game_data',
              ).listenable(keys: ['equipped_items']),
              builder: (context, box, child) {
                final equippedMap = Map<String, String>.from(
                  box.get('equipped_items', defaultValue: {}) as Map,
                );

                Color? tubeSkinColor;
                final tubeId = equippedMap['tube'];
                if (tubeId != null) {
                  try {
                    final item = DecorationData.items.firstWhere(
                      (i) => i.id == tubeId,
                    );
                    tubeSkinColor = Color(int.parse(item.assetPath));
                  } catch (_) {}
                }

                return PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, _) async {
                    if (didPop) return;
                    final nav = Navigator.of(context);
                    final canLeave = await _showQuitDialog(context);
                    if (canLeave) nav.pop();
                  },
                  child: Scaffold(
                    extendBodyBehindAppBar: true,
                    appBar: const GameHeader(),
                    body: Stack(
                      children: [
                        // 1. Room Background
                        BlocBuilder<GameBloc, GameState>(
                          builder: (context, state) {
                            // Biome Logic
                            final int level = state.levelId;
                            Map<String, String> biomeOverrides = {};

                            // We can simulate different "Wall" colors via the existing 'wall' key
                            // 0xFF... color string.
                            // Dreamscape (1-20): Deep Purple 0xFF2D2C50 (Defaultish)
                            // Cyberpunk (21-40): Dark Blue/Black 0xFF050A19
                            // Zen Garden (41-60): Soft Beige/Green 0xFFEBEBD3
                            // Space (61+): Pitch Black 0xFF000000

                            if (!equippedMap.containsKey('wall')) {
                              if (level <= 20) {
                                biomeOverrides['wall'] = '0xFF2D2C50';
                              } else if (level <= 40) {
                                biomeOverrides['wall'] = '0xFF050A19';
                              } else if (level <= 60) {
                                biomeOverrides['wall'] =
                                    '0xFF3E4E42'; // Dark Greenish (Zen)
                              } else {
                                biomeOverrides['wall'] = '0xFF000000';
                              }
                            }

                            final effectiveEquipped = {
                              ...biomeOverrides,
                              ...equippedMap,
                            };

                            return RepaintBoundary(
                              child: RoomView(
                                equipped: effectiveEquipped,
                                showCenterVisual: false,
                              ),
                            );
                          },
                        ),

                        // 2. Main Game Content
                        SafeArea(
                          bottom: false,
                          child: Stack(
                            children: [
                              // The Tubes Grid
                              Positioned.fill(
                                child: BlocBuilder<GameBloc, GameState>(
                                  builder: (context, state) {
                                    return AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 600,
                                      ),
                                      switchInCurve: Curves.easeOutBack,
                                      switchOutCurve: Curves.easeIn,
                                      transitionBuilder: (child, animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: ScaleTransition(
                                            scale: Tween<double>(
                                              begin: 0.9,
                                              end: 1.0,
                                            ).animate(animation),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: RepaintBoundary(
                                        key: ValueKey(
                                          '${state.levelId}_${state.levelStartTime?.millisecondsSinceEpoch ?? 0}',
                                        ),
                                        child: GameBoard(
                                          tubeSkinColor: tubeSkinColor,
                                          tubeKeys: _tubeKeys,
                                          hiddenTargets: _hiddenTargets,
                                          bottomPadding: 140,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Controls & Ad
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const GameBottomControls(),
                                    BlocBuilder<GameBloc, GameState>(
                                      builder: (context, state) {
                                        if (_isBannerAdReady &&
                                            _bannerAd != null &&
                                            state.status != GameStatus.won) {
                                          return SizedBox(
                                            width: _bannerAd!.size.width
                                                .toDouble(),
                                            height: _bannerAd!.size.height
                                                .toDouble(),
                                            child: AdWidget(ad: _bannerAd!),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 3. Flying Balls Values
                        // 3. Flying Balls Manager
                        FlyingBallManager(
                          tubeKeys: _tubeKeys,
                          onHiddenTargetsChanged: (val) {
                            setState(() {
                              _hiddenTargets.clear();
                              _hiddenTargets.addAll(val);
                            });
                          },
                        ),

                        // 4. Hint Overlay
                        BlocBuilder<GameBloc, GameState>(
                          builder: (context, state) {
                            if (state.hintMove != null &&
                                state.hintMove!.sourceIndex <
                                    _tubeKeys.length &&
                                state.hintMove!.targetIndex <
                                    _tubeKeys.length) {
                              return HintOverlay(
                                sourceKey:
                                    _tubeKeys[state.hintMove!.sourceIndex],
                                targetKey:
                                    _tubeKeys[state.hintMove!.targetIndex],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),

                        // Combo flash overlay
                        BlocBuilder<GameBloc, GameState>(
                          builder: (context, state) {
                            final amount = state.lastComboReward;
                            if (amount == null) return const SizedBox.shrink();
                            return _ComboFlashOverlay(
                              amount: amount,
                              onClear: () => context.read<GameBloc>().add(
                                ClearComboReward(),
                              ),
                            );
                          },
                        ),

                        // 5. Win Overlay & Confetti
                        BlocConsumer<GameBloc, GameState>(
                          listener: (context, state) {
                            // Win Overlay Listener
                          },
                          builder: (context, state) {
                            if (state.status == GameStatus.won) {
                              return Stack(
                                children: [
                                  // Confetti Particles
                                  const ConfettiOverlay(),
                                  // Win Card
                                  Container(
                                    color: Colors.black.withValues(
                                      alpha: 0.5,
                                    ), // Dim background
                                    child: WinOverlayWidget(
                                      onRestartTimer:
                                          () {}, // No timer restart needed
                                    ),
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ), // closes Scaffold
                ); // closes PopScope
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ComboFlashOverlay extends StatefulWidget {
  final int amount;
  final VoidCallback onClear;

  const _ComboFlashOverlay({required this.amount, required this.onClear});

  @override
  State<_ComboFlashOverlay> createState() => _ComboFlashOverlayState();
}

class _ComboFlashOverlayState extends State<_ComboFlashOverlay>
    with SingleTickerProviderStateMixin {
  Timer? _clearTimer;
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
    _clearTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) widget.onClear();
    });
  }

  @override
  void dispose() {
    _clearTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.5),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '+${widget.amount}',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Combo!',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
