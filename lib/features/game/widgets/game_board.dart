import 'package:dream_sort/features/game/bloc/game_bloc.dart';
import 'package:dream_sort/features/game/widgets/tube_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameBoard extends StatelessWidget {
  final bool isInteractive;
  final VoidCallback? onWin;
  final Color? tubeSkinColor;

  final List<GlobalKey>? tubeKeys;
  final Set<int>? hiddenTargets;
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

                      final widgets = List.generate(count, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TubeWidget(
                            key: tubeKeys != null && index < tubeKeys!.length
                                ? tubeKeys![index]
                                : null,
                            tube: tubes[index],
                            isSelected: state.selectedTubeIndex == index,
                            hideTopItem:
                                hiddenTargets?.contains(index) ?? false,
                            skinColor: tubeSkinColor,
                            onTap: isInteractive
                                ? () => context.read<GameBloc>().add(
                                    TubeTapped(index),
                                  )
                                : () {},
                          ),
                        );
                      });

                      // Layout Logic:
                      // Ensure rows are balanced and symmetric.
                      // Max 4 columns works best for vertical mobile and split screens.
                      const int maxColumns = 4;
                      List<Widget> rows = [];

                      // Chunk the widgets
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
                        // Add spacing if not last
                        if (end < count) {
                          rows.add(
                            const SizedBox(height: 12),
                          ); // Increased spacing slightly
                        }
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: rows,
                      );
                    },
                  ),
                  if (state.isFrozen)
                    IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.cyanAccent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.ac_unit, color: Colors.white, size: 40),
                            SizedBox(height: 8),
                            Text(
                              'FROZEN!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10,
                                    color: Colors.blue,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
