import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Container()),
                    Image.asset('assets/icons/star_off.png', width: 36),
                    Expanded(child: Container()),
                    Image.asset('assets/icons/star_on.png', width: 36),
                    Expanded(child: Container()),
                    Image.asset('assets/icons/star.gif', width: 36),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                ValueListenableBuilder<int>(
                  valueListenable: goul,
                  builder: (context, goul, child) {
                    return ValueListenableBuilder<int>(
                      valueListenable: points,
                      builder: (context, points, child) {
                        return LinearProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                          value: points / goul,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
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
