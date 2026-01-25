import 'package:dream_sort/features/game/bloc/game_bloc.dart';
import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:dream_sort/features/game/widgets/tube_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/audio/audio_controller.dart';

class GameBoard extends StatelessWidget {
  final bool isInteractive;
  final VoidCallback? onWin;
  final Color? tubeSkinColor;

  final List<GlobalKey>? tubeKeys;
  final Map<int, int>? hiddenTargets;
  final double bottomPadding;

  const GameBoard({
    super.key,
    this.isInteractive = true,
    this.onWin,
    this.tubeSkinColor,
    this.tubeKeys,
    this.hiddenTargets,
    this.bottomPadding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {
        if (state.status == GameStatus.won) {
          onWin?.call();
        }
      },
      builder: (context, state) {
        return Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final tubes = state.tubes;
                      final count = tubes.length;

                      // Calculate max columns based on available width
                      // Each tube is 32px wide + 8px padding on each side = 48px
                      // Add some margin for safety
                      const double tubeWidth = 32.0;
                      const double tubePadding = 16.0; // 8px on each side
                      const double tubeWithPadding = tubeWidth + tubePadding;

                      // Get screen width and calculate how many tubes can fit
                      final screenWidth = MediaQuery.of(context).size.width;
                      final availableWidth = screenWidth - 32;
                      final maxColumns = (availableWidth / tubeWithPadding)
                          .floor()
                          .clamp(3, 8);

                      final widgets = List.generate(count, (index) {
                        return _StaggeredEntrance(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: TubeWidget(
                              key: tubeKeys != null && index < tubeKeys!.length
                                  ? tubeKeys![index]
                                  : null,
                              tube: tubes[index],
                              isSelected: state.selectedTubeIndex == index,
                              hiddenItemCount: hiddenTargets?[index] ?? 0,
                              skinColor: tubeSkinColor,
                              isCompleted:
                                  tubes[index].items.isNotEmpty &&
                                  tubes[index].isCompleted &&
                                  (hiddenTargets?[index] ?? 0) == 0,
                              onTap: isInteractive
                                  ? () {
                                      final bloc = context.read<GameBloc>();

                                      // STONE CHECK (Visual Feedback)
                                      final thisTube = state.tubes[index];
                                      if (!thisTube.isEmpty &&
                                          thisTube.topItem!.isStone) {
                                        // Trigger Stone Effect locally
                                        context
                                            .read<AudioController>()
                                            .playStoneImpact();
                                        if (tubeKeys != null &&
                                            index < tubeKeys!.length) {
                                          (tubeKeys![index].currentState
                                                  as TubeWidgetState?)
                                              ?.triggerStoneEffect();
                                        }
                                        return; // Don't send event to bloc (or send it if bloc needs to log it, but bloc just errors anyway)
                                      }

                                      // Local Validity Check for Shake Feedback
                                      final selectedIndex =
                                          state.selectedTubeIndex;
                                      if (selectedIndex != null &&
                                          selectedIndex != index) {
                                        final source =
                                            state.tubes[selectedIndex];
                                        final target = state.tubes[index];
                                        final isValid = _isMoveValid(
                                          source,
                                          target,
                                        );

                                        if (!isValid) {
                                          // Trigger Shake
                                          if (tubeKeys != null &&
                                              index < tubeKeys!.length) {
                                            final key = tubeKeys![index];
                                            (key.currentState
                                                    as TubeWidgetState?)
                                                ?.shake();
                                          }
                                        }
                                      }
                                      bloc.add(TubeTapped(index));
                                    }
                                  : () {},
                            ),
                          ),
                        );
                      });

                      // Layout Logic with dynamic columns:
                      List<Widget> rows = [];

                      for (int i = 0; i < count; i += maxColumns) {
                        final end = (i + maxColumns < count)
                            ? i + maxColumns
                            : count;
                        final chunk = widgets.sublist(i, end);

                        rows.add(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: chunk,
                          ),
                        );
                        if (end < count) {
                          rows.add(const SizedBox(height: 0));
                        }
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: rows,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isMoveValid(Tube source, Tube target) {
    if (source.isEmpty) return false;
    if (target.isFull) return false;
    if (target.isEmpty) return true;
    return source.topItem!.colorIndex == target.topItem!.colorIndex;
  }
}

class _StaggeredEntrance extends StatefulWidget {
  final int index;
  final Widget child;

  const _StaggeredEntrance({required this.index, required this.child});

  @override
  State<_StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<_StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Delay based on index
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
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
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(scale: _scale.value, child: child),
        );
      },
      child: widget.child,
    );
  }
}
