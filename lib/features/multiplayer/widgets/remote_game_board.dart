import 'package:dream_sort/features/game/models/game_models.dart';
import 'package:dream_sort/features/game/widgets/tube_widget.dart';
import 'package:flutter/material.dart';

class RemoteGameBoard extends StatelessWidget {
  final List<Tube> tubes;
  final bool isFrozen;
  final Color? tubeSkinColor;

  const RemoteGameBoard({
    super.key,
    required this.tubes,
    this.isFrozen = false,
    this.tubeSkinColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final count = tubes.length;

                  final widgets = List.generate(count, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TubeWidget(
                        tube: tubes[index],
                        isSelected: false, // Remote is never selected by us
                        skinColor: tubeSkinColor,
                        onTap: () {}, // Not interactive
                      ),
                    );
                  });

                  // Layout Logic specific for this smaller view potentially,
                  // but we'll stick to the standard logic for consistency.
                  const int maxColumns = 5;
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
                      rows.add(const SizedBox(height: 5));
                    }
                  }

                  return Column(mainAxisSize: MainAxisSize.min, children: rows);
                },
              ),
              if (isFrozen)
                IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.cyanAccent, width: 2),
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
  }
}
