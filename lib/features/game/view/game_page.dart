import 'package:vibration/vibration.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:dream_sort/core/services/ads_service.dart';

import 'package:dream_sort/core/audio/audio_controller.dart';
import 'package:dream_sort/features/game/bloc/game_bloc.dart';
import 'package:dream_sort/features/game/models/decor_models.dart';
import 'package:dream_sort/features/game/repo/game_repository.dart';
import 'package:dream_sort/features/game/widgets/confetti_overlay.dart';
import 'package:dream_sort/features/game/widgets/flying_ball_manager.dart';
import 'package:dream_sort/features/game/widgets/game_bottom_controls.dart';
import 'package:dream_sort/features/game/widgets/game_header.dart';

import 'package:dream_sort/features/game/widgets/room_view.dart';
import 'package:dream_sort/features/game/widgets/game_board.dart';
import 'package:dream_sort/features/game/widgets/win_overlay_widget.dart';
import 'package:flutter/material.dart';

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

  // Ads
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = AdsService.loadBanner(
      onAdLoaded: (ad) {
        if (!mounted) {
          ad.dispose();
          return;
        }
        setState(() {
          _isBannerAdReady = true;
        });
      },
      onAdFailed: (error) {
        debugPrint('BannerAd failed to load: $error');
        _isBannerAdReady = false;
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _handleGameStateChange(BuildContext context, GameState state) {
    // 1. Manage Tube Keys
    if (_tubeKeys.length != state.tubes.length) {
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
        child: ValueListenableBuilder(
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

            return Scaffold(
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
                    child: Column(
                      children: [
                        // The Tubes Grid
                        Expanded(
                          child: BlocBuilder<GameBloc, GameState>(
                            builder: (context, state) {
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 600),
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
                                  key: ValueKey(state.levelId),
                                  child: GameBoard(
                                    tubeSkinColor: tubeSkinColor,
                                    tubeKeys: _tubeKeys,
                                    hiddenTargets: _hiddenTargets,
                                    bottomPadding:
                                        100, // Safe space for buttons
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (_isBannerAdReady && _bannerAd != null)
                          SizedBox(
                            width: _bannerAd!.size.width.toDouble(),
                            height: _bannerAd!.size.height.toDouble(),
                            child: AdWidget(ad: _bannerAd!),
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

                  // 4. Floating Controls (Undo, Add, Shuffle, Restart)
                  const GameBottomControls(),

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
            );
          },
        ),
      ),
    );
  }
}
