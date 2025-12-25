import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:dream_sort/core/services/ads_service.dart';

import 'package:dream_sort/core/audio/audio_controller.dart';
import 'package:dream_sort/features/game/bloc/game_bloc.dart';
import 'package:dream_sort/features/game/models/decor_models.dart';
import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:dream_sort/features/game/repo/game_repository.dart';
import 'package:dream_sort/features/game/widgets/confetti_overlay.dart';
import 'package:dream_sort/features/game/widgets/flying_ball.dart';
import 'package:dream_sort/features/game/widgets/game_floating_button.dart';
import 'package:dream_sort/features/game/widgets/game_menu_sheet.dart';
import 'package:dream_sort/features/game/widgets/room_view.dart';
import 'package:dream_sort/features/game/widgets/game_board.dart';
import 'package:dream_sort/features/game/widgets/win_overlay_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../l10n/app_localizations.dart';

class GamePage extends StatefulWidget {
  final int? initialLevel;

  const GamePage({super.key, this.initialLevel});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<GlobalKey> _tubeKeys = [];
  final Set<int> _hiddenTargets = {};
  int _lastHandledMoveId = -1;

  // Defines a flying ball animation
  final List<Widget> _flyingBalls = [];

  // ... timers ...
  Timer? _gameTimer;
  Duration _elapsed = Duration.zero;

  // Ads
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
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
    _gameTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _startTimer() {
    _elapsed = Duration.zero;
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsed += const Duration(seconds: 1);
        });
      }
    });
  }

  String _formatTime(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _handleGameStateChange(BuildContext context, GameState state) {
    // 1. Manage Tube Keys
    if (_tubeKeys.length != state.tubes.length) {
      _tubeKeys = List.generate(state.tubes.length, (_) => GlobalKey());
    }

    // 2. Check for Win to stop timer
    if (state.status == GameStatus.won) {
      _gameTimer?.cancel();
      _gameTimer?.cancel();
      // Show Interstitial on Win (Best Practice: Preloaded)
      AdsService.showInterstitial();
    }

    // 3. Detect Move Animation
    if (state.lastMove != null &&
        state.lastMove!.moveId != _lastHandledMoveId) {
      _lastHandledMoveId = state.lastMove!.moveId;
      _runBallAnimation(state.lastMove!, state);
    }
  }

  void _runBallAnimation(MoveDetails move, GameState state) {
    final sourceKey = _tubeKeys[move.sourceIndex];
    final targetKey = _tubeKeys[move.targetIndex];

    final sourceContext = sourceKey.currentContext;
    final targetContext = targetKey.currentContext;

    if (sourceContext == null || targetContext == null) return;

    // Calculate positions
    final sourceBox = sourceContext.findRenderObject() as RenderBox;
    final targetBox = targetContext.findRenderObject() as RenderBox;

    final sourcePos = sourceBox.localToGlobal(Offset.zero);
    final targetPos = targetBox.localToGlobal(Offset.zero);

    final sourceCount = state.tubes[move.sourceIndex].items.length;
    final targetCount = state.tubes[move.targetIndex].items.length;

    double getBallTopY(int index) {
      const tubeHeight = 240.0;
      const bottomPad = 10.0;
      const itemHeight = 44.0;

      final bottomY = bottomPad + (index * 48.0);
      return tubeHeight - bottomY - itemHeight;
    }

    final startLocalY = getBallTopY(sourceCount);
    final endLocalY = getBallTopY(targetCount - 1);

    final startPoint = Offset(sourcePos.dx + 6, sourcePos.dy + startLocalY);
    final endPoint = Offset(targetPos.dx + 6, targetPos.dy + endLocalY);

    // Create Animation Widget
    final animationWidget = FlyingBall(
      start: startPoint,
      end: endPoint,
      item: SortingItem(colorIndex: move.colorIndex),
      onComplete: () {
        if (mounted) {
          setState(() {
            _hiddenTargets.remove(move.targetIndex);
            _flyingBalls.removeAt(0); // Assumes FIFO
          });
        }
      },
    );

    setState(() {
      _hiddenTargets.add(move.targetIndex);
      _flyingBalls.add(animationWidget);
    });
  }

  void _showMenuBottomSheet(BuildContext context, GameBloc bloc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) =>
          BlocProvider.value(value: bloc, child: const GameMenuSheet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Force rebuild when popping back from DecorPage to update wall color
    return BlocProvider(
      create: (context) => GameBloc(
        repo: context.read<GameRepository>(),
        audio: context.read<AudioController>(),
      )..add(LoadLevel(levelId: widget.initialLevel)),
      child: BlocListener<GameBloc, GameState>(
        listener: (context, state) => _handleGameStateChange(context, state),
        child: ValueListenableBuilder(
          valueListenable: Hive.box(
            'game_data',
          ).listenable(keys: ['equipped_items']),
          builder: (context, box, child) {
            final gameBloc = context.read<GameBloc>(); // Capture Bloc
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
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                titleSpacing: 0,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
                title: BlocBuilder<GameBloc, GameState>(
                  builder: (context, state) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.levelTitle(state.levelId),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.0,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(1, 1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        // Timer Display
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black26, // Subtle pill
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _formatTime(_elapsed),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                actions: [
                  // Star Badge
                  BlocBuilder<GameBloc, GameState>(
                    builder: (context, state) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  insetPadding: const EdgeInsets.all(20),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Main Card
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                          24,
                                          48,
                                          24,
                                          24,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              const Color(0xFF2A2A40),
                                              const Color(0xFF1A1A2E),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.1,
                                            ),
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black45,
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'Need More Stars?',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            const Text(
                                              'Watch a short video to instantly earn\n+50 Free Stars!',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white70,
                                                height: 1.4,
                                              ),
                                            ),
                                            const SizedBox(height: 32),

                                            // Watch Button
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(ctx);
                                                AdsService.showRewarded(
                                                  onUserEarnedReward: (amount) {
                                                    // Force 50 stars regardless of what AdMob returns
                                                    const reward = 50;
                                                    if (context.mounted) {
                                                      context
                                                          .read<GameBloc>()
                                                          .add(
                                                            AddCurrency(reward),
                                                          );
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'You earned $reward ⭐!',
                                                          ),
                                                          backgroundColor:
                                                              Colors.amber,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                );
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                        colors: [
                                                          Color(0xFFFFC107),
                                                          Color(0xFFFF9800),
                                                        ],
                                                      ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.amber
                                                          .withValues(
                                                            alpha: 0.4,
                                                          ),
                                                      blurRadius: 12,
                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Icon(
                                                      Icons
                                                          .play_circle_filled_rounded,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Watch Video',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),

                                            // Cancel Button
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white38,
                                              ),
                                              child: const Text('No, thanks'),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Top Floating Icon
                                      Positioned(
                                        top: -30,
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1A1A2E),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.amber,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 10,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.star_rounded,
                                            color: Colors.amber,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 4,
                                top: 2,
                                bottom: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.amber.withValues(alpha: 0.6),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${state.starCount}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.amber,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      size: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Menu Button
                  IconButton(
                    icon: const Icon(Icons.grid_view_rounded),
                    tooltip: l10n.menu,
                    color: Colors.white,
                    onPressed: () => _showMenuBottomSheet(context, gameBloc),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              body: Stack(
                children: [
                  // 1. Room Background
                  RoomView(equipped: equippedMap, showCenterVisual: false),

                  // 2. Main Game Content
                  SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        // The Tubes Grid
                        Expanded(
                          child: BlocBuilder<GameBloc, GameState>(
                            builder: (context, state) {
                              return GameBoard(
                                tubeSkinColor: tubeSkinColor,
                                tubeKeys: _tubeKeys,
                                hiddenTargets: _hiddenTargets,
                                bottomPadding: 100, // Safe space for buttons
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
                  ..._flyingBalls,

                  // 4. Floating Controls (Undo, Add, Shuffle, Restart)
                  Positioned(
                    bottom: 55,
                    left: 24,
                    right: 24,
                    child: BlocBuilder<GameBloc, GameState>(
                      builder: (context, state) {
                        const int addCost = 50;
                        final canAffordAdd = state.starCount >= addCost;
                        final canAffordShuffle = state.starCount >= 20;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Undo Button (Left)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GameFloatingButton(
                                  icon: Icons.undo_rounded,
                                  disabled:
                                      state.history.isEmpty ||
                                      state.remainingUndos <= 0,
                                  onTap: () =>
                                      context.read<GameBloc>().add(UndoMove()),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '${state.remainingUndos}',
                                  style: TextStyle(
                                    color: state.remainingUndos > 0
                                        ? Colors.white
                                        : Colors.redAccent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.8,
                                        ),
                                        offset: const Offset(1, 1),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(),

                            // 2. Center Buttons (Add Tube & Shuffle)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Add Tube
                                Column(
                                  children: [
                                    GameFloatingButton(
                                      icon: Icons.queue_rounded,
                                      disabled: !canAffordAdd,
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => Dialog(
                                            backgroundColor: Colors.transparent,
                                            insetPadding: const EdgeInsets.all(
                                              20,
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              clipBehavior: Clip.none,
                                              children: [
                                                // Main Card
                                                Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                        24,
                                                        48,
                                                        24,
                                                        24,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        const Color(0xFF2A2A40),
                                                        const Color(0xFF1A1A2E),
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          24,
                                                        ),
                                                    border: Border.all(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      width: 1,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black45,
                                                        blurRadius: 20,
                                                        offset: const Offset(
                                                          0,
                                                          10,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Text(
                                                        'Need Help?',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: Colors.white,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      const Text(
                                                        'Add an extra empty tube to make\nsolving this puzzle easier!',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.white70,
                                                          height: 1.4,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 32,
                                                      ),

                                                      // Action Button
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.pop(ctx);
                                                          context
                                                              .read<GameBloc>()
                                                              .add(
                                                                RequestHelp(),
                                                              );
                                                        },
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 16,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            gradient:
                                                                const LinearGradient(
                                                                  colors: [
                                                                    Color(
                                                                      0xFF4CAF50,
                                                                    ),
                                                                    Color(
                                                                      0xFF2E7D32,
                                                                    ),
                                                                  ],
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  16,
                                                                ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .green
                                                                    .withValues(
                                                                      alpha:
                                                                          0.4,
                                                                    ),
                                                                blurRadius: 12,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      4,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: const [
                                                              Icon(
                                                                Icons
                                                                    .add_circle_outline_rounded,
                                                                color: Colors
                                                                    .white,
                                                                size: 24,
                                                              ),
                                                              SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                'Add Tube (-50⭐)',
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 16,
                                                      ),

                                                      // Cancel Button
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(ctx),
                                                        style:
                                                            TextButton.styleFrom(
                                                              foregroundColor:
                                                                  Colors
                                                                      .white38,
                                                            ),
                                                        child: const Text(
                                                          'Cancel',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // Top Floating Icon
                                                Positioned(
                                                  top: -30,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF1A1A2E,
                                                      ),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.green,
                                                        width: 2,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 10,
                                                          offset: const Offset(
                                                            0,
                                                            5,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: const Icon(
                                                      Icons.science_rounded,
                                                      color: Colors.green,
                                                      size: 40,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      '$addCost ⭐',
                                      style: TextStyle(
                                        color: canAffordAdd
                                            ? const Color(0xFFFFC107)
                                            : Colors.grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.8,
                                            ),
                                            offset: const Offset(1, 1),
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(width: 24),

                                // Shuffle
                                Column(
                                  children: [
                                    GameFloatingButton(
                                      icon: Icons.shuffle_rounded,
                                      disabled: !canAffordShuffle,
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => Dialog(
                                            backgroundColor: Colors.transparent,
                                            insetPadding: const EdgeInsets.all(
                                              20,
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              clipBehavior: Clip.none,
                                              children: [
                                                // Main Card
                                                Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                        24,
                                                        48,
                                                        24,
                                                        24,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        const Color(0xFF2A2A40),
                                                        const Color(0xFF1A1A2E),
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          24,
                                                        ),
                                                    border: Border.all(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      width: 1,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black45,
                                                        blurRadius: 20,
                                                        offset: const Offset(
                                                          0,
                                                          10,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Text(
                                                        'Shuffle?',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: Colors.white,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      const Text(
                                                        'Rearrange balls to find new moves!\n(Completed tubes stay safe)',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.white70,
                                                          height: 1.4,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 32,
                                                      ),

                                                      // Action Button
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.pop(ctx);
                                                          context
                                                              .read<GameBloc>()
                                                              .add(
                                                                RequestShuffle(),
                                                              );
                                                        },
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 16,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            gradient:
                                                                const LinearGradient(
                                                                  colors: [
                                                                    Color(
                                                                      0xFF2196F3,
                                                                    ),
                                                                    Color(
                                                                      0xFF1976D2,
                                                                    ),
                                                                  ],
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  16,
                                                                ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .blue
                                                                    .withValues(
                                                                      alpha:
                                                                          0.4,
                                                                    ),
                                                                blurRadius: 12,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      4,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: const [
                                                              Icon(
                                                                Icons
                                                                    .shuffle_rounded,
                                                                color: Colors
                                                                    .white,
                                                                size: 24,
                                                              ),
                                                              SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                'Shuffle (-20⭐)',
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 16,
                                                      ),

                                                      // Cancel Button
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(ctx),
                                                        style:
                                                            TextButton.styleFrom(
                                                              foregroundColor:
                                                                  Colors
                                                                      .white38,
                                                            ),
                                                        child: const Text(
                                                          'Cancel',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // Top Floating Icon
                                                Positioned(
                                                  top: -30,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF1A1A2E,
                                                      ),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.blue,
                                                        width: 2,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 10,
                                                          offset: const Offset(
                                                            0,
                                                            5,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: const Icon(
                                                      Icons.shuffle_rounded,
                                                      color: Colors.blue,
                                                      size: 40,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      '20 ⭐',
                                      style: TextStyle(
                                        color: canAffordShuffle
                                            ? const Color(0xFFFFC107)
                                            : Colors.grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.8,
                                            ),
                                            offset: const Offset(1, 1),
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const Spacer(),

                            // 3. Restart Button (Right)
                            GameFloatingButton(
                              icon: Icons.refresh_rounded,
                              onTap: () {
                                context.read<GameBloc>().add(ResetLevel());
                                _startTimer();
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // 5. Win Overlay & Confetti
                  BlocConsumer<GameBloc, GameState>(
                    listener: (context, state) {
                      if (state.status == GameStatus.won) {
                        _gameTimer?.cancel(); // Stop timer on win
                      }
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
                                elapsed: _elapsed,
                                onRestartTimer: _startTimer,
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
