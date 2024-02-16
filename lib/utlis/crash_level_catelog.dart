import 'package:flutter_game/crash_game_src/components/components.dart';

class CrashLevelCatelog {
  final int goulPoints;
  final int moves;
  final Map<GoulItem, int> externalGouls;
  final Map<int, List<int>> disabledNodes;
  final int horizontalItemsCount;
  final int verticalItemsCount;
  CrashLevelCatelog(
      {required this.goulPoints,
      required this.moves,
      required this.externalGouls,
      required this.disabledNodes,
      required this.horizontalItemsCount,
      required this.verticalItemsCount});
}
