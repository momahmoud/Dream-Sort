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
import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../l10n/app_localizations.dart';

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
  int _lastHandledMoveId = -1;

  // Defines a flying ball animation
  final List<Widget> _flyingBalls = [];

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
      _tubeKeys = List.generate(state.tubes.length, (_) => GlobalKey());
    }

    // 2. Check for Win status
    if (state.status == GameStatus.won) {
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

  void _runBallAnimation(MoveDetails move, GameState state) async {
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

    // Items after move logic execution
    // Source has fewer items now. Target has more.
    // To animate FROM source, we need the position where they WERE.
    // Source originally had: currentItems + count.
    // Target originally had: currentItems - count.
    final targetItemsCount = state.tubes[move.targetIndex].items.length;
    final sourceCurrentCount = state.tubes[move.sourceIndex].items.length;

    // We animate `move.count` balls.
    // They start from Source Top down.
    // They end at Target Top up.

    double getBallTopY(int index, double widgetHeight) {
      // TubeWidget layout: Items are aligned to bottom.
      // Bottom padding: 12.
      // Item Height: 26.
      // Stack positioning uses 'bottom', but here we need 'top' relative to widget.
      const bottomPad = 12.0;
      const itemHeight = 26.0;

      // Calculate distance from bottom of widget to bottom of item
      final bottomOffset = bottomPad + (index * itemHeight);

      // Top Y relative to widget top = WidgetHeight - bottomOffset - itemHeight
      // Note: TubeWidget has a "Lip" (hover space) on top.
      // The RenderBox includes that hover space (30.0 extra).
      // The "Items" are inside a Container which is inside the SizedBox.
      // Actually, TubeWidget > GestureDetector > AnimatedScale > Column > SizedBox > Stack > Positioned(bottom:10).
      // So the RenderBox (sourceBox) is the TubeWidget (GestureDetector).
      // Its total height includes the hover space.
      // The items are pinned to the bottom of the SizedBox which matches the Column height?
      // Yes. So relying on RenderBox height is correct.

      return widgetHeight - bottomOffset - itemHeight;
    }

    // Adjust global offset.
    // The previous logic added `containerTopOffset`. Since we now calc from bottom, we don't need arbitrary header offsets if we use full height.
    // But let's verify visual alignment.
    // If we return `widgetHeight - ...`, that's `localY`.
    // sourcePos.dy + localY should be correct top-left of the ball.

    // Hide target items first
    setState(() {
      _hiddenTargets[move.targetIndex] =
          (_hiddenTargets[move.targetIndex] ?? 0) + move.count;
    });

    for (int i = 0; i < move.count; i++) {
      final sourceIndex = sourceCurrentCount + i;
      final targetIndex = targetItemsCount - move.count + i;

      final startLocalY = getBallTopY(sourceIndex, sourceBox.size.height);
      final endLocalY = getBallTopY(targetIndex, targetBox.size.height);

      final startPoint = Offset(
        sourcePos.dx + 4, // Center h-offset: (32 - 26)/2 = 3.
        sourcePos.dy + startLocalY,
      );
      final endPoint = Offset(targetPos.dx + 4, targetPos.dy + endLocalY);

      // Points above the tubes for entering/exiting "from the front/top"
      final exitPoint = Offset(startPoint.dx, sourcePos.dy - 20);
      final entryPoint = Offset(endPoint.dx, targetPos.dy - 20);

      final animationWidget = FlyingBall(
        start: startPoint,
        end: endPoint,
        exitPoint: exitPoint,
        entryPoint: entryPoint,
        item: SortingItem(colorIndex: move.colorIndex),
        onComplete: () {
          if (mounted) {
            setState(() {
              final currentHidden = _hiddenTargets[move.targetIndex] ?? 0;
              if (currentHidden > 0) {
                _hiddenTargets[move.targetIndex] = currentHidden - 1;
              }
              _flyingBalls.removeAt(0);
            });
          }
        },
      );

      setState(() {
        _flyingBalls.add(animationWidget);
      });

      // Stagger animations slightly?
      // await Future.delayed(const Duration(milliseconds: 50));
    }
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
                          'L.V ${state.levelId}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                actions: [
                  const SizedBox(width: 8),
                  // Undo
                  BlocBuilder<GameBloc, GameState>(
                    builder: (context, state) {
                      final isDisabled =
                          state.history.isEmpty || state.remainingUndos <= 0;
                      return GestureDetector(
                        onTap: isDisabled
                            ? null
                            : () {
                                context.read<GameBloc>().add(UndoMove());
                              },
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isDisabled ? 0.3 : 1.0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.undo_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                if (state.remainingUndos > 0) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '${state.remainingUndos}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.read<GameBloc>().add(ResetLevel()),
                    child: Container(
                      padding: const EdgeInsets.all(8), // Square-ish or Circle
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Star Badge
                  BlocBuilder<GameBloc, GameState>(
                    builder: (context, state) {
                      return Center(
                        child: GestureDetector(
                          onTap: () {
                            if (!AdsService.isEnabled) return;
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
                                    // Main Card
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: BackdropFilter(
                                        filter: ui.ImageFilter.blur(
                                          sigmaX: 10,
                                          sigmaY: 10,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                            24,
                                            48,
                                            24,
                                            24,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF1A1A2E,
                                            ).withValues(alpha: 0.8),
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
                                              Text(
                                                l10n.needMoreCoins,
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
                                                l10n.earnFreeCoins,
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
                                                              AddCurrency(
                                                                reward,
                                                              ),
                                                            );
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Row(
                                                              children: [
                                                                Text(
                                                                  l10n.earnedCoins(
                                                                    reward,
                                                                  ),
                                                                ),
                                                                SvgPicture.asset(
                                                                  'assets/images/coin.svg',
                                                                  width: 16,
                                                                  height: 16,
                                                                ),
                                                                const Text('!'),
                                                              ],
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
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
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
                                                        MainAxisAlignment
                                                            .center,
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
                                                  foregroundColor:
                                                      Colors.white38,
                                                ),
                                                child: Text(l10n.noThanks),
                                              ),
                                            ],
                                          ),
                                        ),
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
                                        child: SvgPicture.asset(
                                          'assets/images/coin.svg',
                                          width: 48,
                                          height: 48,
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
                              right: 10,
                              top: 3,
                              bottom: 3,
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
                                SvgPicture.asset(
                                  'assets/images/coin.svg',
                                  width: 20,
                                  height: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${state.coinCount}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (AdsService.isEnabled) ...[
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
                              ],
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
                  ..._flyingBalls,

                  // 4. Floating Controls (Undo, Add, Shuffle, Restart)
                  Positioned(
                    bottom: 55,
                    left: 16,
                    right: 16,
                    child: BlocBuilder<GameBloc, GameState>(
                      builder: (context, state) {
                        const int addCost = 50;
                        final canAffordAdd = state.coinCount >= addCost;
                        final canAffordShuffle = state.coinCount >= 20;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // 2. Center Buttons (Add Tube & Shuffle)
                            Column(
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
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  child: BackdropFilter(
                                                    filter: ui.ImageFilter.blur(
                                                      sigmaX: 10,
                                                      sigmaY: 10,
                                                    ),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.fromLTRB(
                                                            24,
                                                            48,
                                                            24,
                                                            24,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            const Color(
                                                              0xFF1A1A2E,
                                                            ).withValues(
                                                              alpha: 0.8,
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
                                                            color:
                                                                Colors.black45,
                                                            blurRadius: 20,
                                                            offset:
                                                                const Offset(
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
                                                          Text(
                                                            l10n.needHelp,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              color:
                                                                  Colors.white,
                                                              letterSpacing:
                                                                  0.5,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 12,
                                                          ),
                                                          Text(
                                                            l10n.addTubeDesc,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .white70,
                                                              height: 1.4,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 32,
                                                          ),

                                                          // Action Button
                                                          GestureDetector(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                ctx,
                                                              );
                                                              context
                                                                  .read<
                                                                    GameBloc
                                                                  >()
                                                                  .add(
                                                                    RequestHelp(),
                                                                  );
                                                            },
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    vertical:
                                                                        16,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                gradient: const LinearGradient(
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
                                                                    blurRadius:
                                                                        12,
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
                                                                children: [
                                                                  const Icon(
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
                                                                    l10n.addTube,
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          18,
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
                                                                Navigator.pop(
                                                                  ctx,
                                                                ),
                                                            style: TextButton.styleFrom(
                                                              foregroundColor:
                                                                  Colors
                                                                      .white38,
                                                            ),
                                                            child: Text(
                                                              l10n.noThanks,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$addCost',
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
                                        const SizedBox(width: 4),
                                        SvgPicture.asset(
                                          'assets/images/coin.svg',
                                          width: 16,
                                          height: 16,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

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
                                                      Text(
                                                        l10n.shuffleTitle,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
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
                                                      Text(
                                                        l10n.shuffleDesc,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
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
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .shuffle_rounded,
                                                                color: Colors
                                                                    .white,
                                                                size: 24,
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    l10n.shuffleAction,
                                                                    style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 4,
                                                                  ),
                                                                  SvgPicture.asset(
                                                                    'assets/images/coin.svg',
                                                                    width: 18,
                                                                    height: 18,
                                                                  ),
                                                                  const Text(
                                                                    ')',
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ],
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
                                                        child: Text(
                                                          l10n.cancel,
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '20',
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
                                        const SizedBox(width: 4),
                                        SvgPicture.asset(
                                          'assets/images/coin.svg',
                                          width: 16,
                                          height: 16,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Hint
                            Column(
                              children: [
                                GameFloatingButton(
                                  icon: Icons.lightbulb_rounded,
                                  disabled: state.coinCount < 25,
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
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              child: BackdropFilter(
                                                filter: ui.ImageFilter.blur(
                                                  sigmaX: 10,
                                                  sigmaY: 10,
                                                ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                        24,
                                                        48,
                                                        24,
                                                        24,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF1A1A2E,
                                                    ).withValues(alpha: 0.8),
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
                                                      Text(
                                                        l10n.needHint,
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
                                                      Text(
                                                        l10n.hintDesc,
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
                                                                RequestHint(),
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
                                                                    Colors
                                                                        .orange,
                                                                    Colors
                                                                        .deepOrange,
                                                                  ],
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  16,
                                                                ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .orange
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
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .lightbulb_rounded,
                                                                color: Colors
                                                                    .white,
                                                                size: 24,
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    l10n.getHint,
                                                                    style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 4,
                                                                  ),
                                                                  SvgPicture.asset(
                                                                    'assets/images/coin.svg',
                                                                    width: 18,
                                                                    height: 18,
                                                                  ),
                                                                  const Text(
                                                                    ')',
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ],
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
                                                        child: Text(
                                                          l10n.cancel,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Top Floating Icon
                                            Positioned(
                                              top: -30,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF1A1A2E,
                                                  ),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.orange,
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
                                                  Icons.lightbulb_rounded,
                                                  color: Colors.orange,
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '25',
                                      style: TextStyle(
                                        color: state.coinCount >= 25
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
                                    const SizedBox(width: 4),
                                    SvgPicture.asset(
                                      'assets/images/coin.svg',
                                      width: 16,
                                      height: 16,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
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
            );
          },
        ),
      ),
    );
  }
}
