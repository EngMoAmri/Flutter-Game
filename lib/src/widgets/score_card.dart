import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({
    super.key,
    required this.goul,
    required this.moves,
    required this.points,
  });

  final ValueNotifier<int> goul;
  final ValueNotifier<int> moves;
  final ValueNotifier<int> points;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ValueListenableBuilder<int>(
            valueListenable: goul,
            builder: (context, goul, child) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 18),
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    'Goul: $goul'.toUpperCase(),
                    style: Theme.of(context).textTheme.titleLarge!,
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<int>(
            valueListenable: moves,
            builder: (context, moves, child) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 18),
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    'Moves: $moves'.toUpperCase(),
                    style: Theme.of(context).textTheme.titleLarge!,
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<int>(
            valueListenable: points,
            builder: (context, points, child) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 18),
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    'Points: $points'.toUpperCase(),
                    style: Theme.of(context).textTheme.titleLarge!,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
