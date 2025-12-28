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

  const GamePage({super.key, this.initialLevel});

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

    double getBallTopY(int index) {
      // Tube Height 160 (updated), Pad 10. Item Height ~34? (Ball size 34).
      // We need exact mapping to TubeWidget layout.
      // TubeWidget stack: bottom: 10 + (index * size?).
      // TubeWidget uses BallWidget size=34.
      // Let's assume vertical spacing is just height of ball (34).

      // TubeWidget::SizedBox height 210.
      // TubeWidget::Stack::Container height 160.
      // Items Positioned bottom 10.
      // Top Y = ContainerHeight - (10 + (index * 34) + 34).
      const containerHeight = 160.0;
      const bottomPad = 10.0;
      const itemHeight = 34.0;

      final bottomY = bottomPad + (index * itemHeight);
      return containerHeight -
          bottomY -
          itemHeight; // relative to container top
    }

    // Adjust global offset.
    // sourcePos points to the TubeWidget column? no, the RenderBox of TubeWidget.
    // TubeWidget has a SizedBox(width:42, height:190) > Stack > Container(height:160) at bottom.
    // So the Container starts at (190 - 160) = 30 from top of widget.
    const containerTopOffset = 30.0;

    // Hide target items first
    setState(() {
      _hiddenTargets[move.targetIndex] =
          (_hiddenTargets[move.targetIndex] ?? 0) + move.count;
    });

    for (int i = 0; i < move.count; i++) {
      // Source was at (sourceCurrentCount + (count - 1 - i))
      // Target will be at (targetItemsCount - count + i)
      // Wait, order matches. Bottom-most moved ball goes to Bottom-most empty slot.
      // Actually, in stack logic:
      // Top Source -> Top Target?
      // Source: [A, B] -> move 2 -> [].
      // B was on top. A was below.
      // Target: [].
      // Result Target: [A, B].
      // So B moves to B position (index 1). A moves to A position (index 0).
      // Since we are moving a chunk, visual continuity suggests preserving order.
      // Source top (B) goes to Target top (B).
      // Source (A) goes to Target (A).

      // Source Index for this ball:
      // The one at index `sourceCurrentCount + i`
      final sourceIndex = sourceCurrentCount + i;

      // Target Index:
      // The one at index `targetItemsCount - move.count + i`
      final targetIndex = targetItemsCount - move.count + i;

      final startLocalY = getBallTopY(sourceIndex) + containerTopOffset;
      final endLocalY = getBallTopY(targetIndex) + containerTopOffset;

      final startPoint = Offset(
        sourcePos.dx + 4,
        sourcePos.dy + startLocalY,
      ); // +4 centering adjustment
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
                        Colors.black.withOpacity(0.8),
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
                                              ).withOpacity(0.8),
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(
                                                  0.1,
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
                                                                    'You earned $reward ',
                                                                  ),
                                                                  SvgPicture.asset(
                                                                    'assets/images/coin.svg',
                                                                    width: 16,
                                                                    height: 16,
                                                                  ),
                                                                  const Text(
                                                                    '!',
                                                                  ),
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
                                                              .withOpacity(0.4),
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
                                                  child: const Text(
                                                    'No, thanks',
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
                                right: 4,
                                top: 2,
                                bottom: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.amber.withOpacity(0.6),
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
                  RepaintBoundary(
                    child: RoomView(
                      equipped: equippedMap,
                      showCenterVisual: false,
                    ),
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
                                        color: Colors.black.withOpacity(0.8),
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
                                                        ).withOpacity(0.8),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              24,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors.white
                                                              .withOpacity(0.1),
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
                                                          const Text(
                                                            'Need Help?',
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
                                                          const Text(
                                                            'Add an extra empty tube to make\nsolving this puzzle easier!',
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
                                                                        .withOpacity(
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
                                                                    'Add Tube',
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
                                                            child: const Text(
                                                              'No, thanks',
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
                                                color: Colors.black.withOpacity(
                                                  0.8,
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
                                                          .withOpacity(0.1),
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
                                                                    .withOpacity(
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
                                                                  const Text(
                                                                    'Shuffle (-20',
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
                                                color: Colors.black.withOpacity(
                                                  0.8,
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

                            const Spacer(),

                            // 3. Restart Button (Right)
                            GameFloatingButton(
                              icon: Icons.refresh_rounded,
                              onTap: () {
                                context.read<GameBloc>().add(ResetLevel());
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
                              color: Colors.black.withOpacity(
                                0.5,
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
