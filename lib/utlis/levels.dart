import 'package:flutter_game/crash_game_src/components/components.dart';

import 'crash_level_catelog.dart';

List levels = [
  CrashLevelCatelog(
      goulPoints: 30,
      moves: 30,
      externalGouls: {
        GoulItem(type: ItemType.bottle, powerType: PowerType.none): 15,
      },
      disabledNodes: {}, // TODO
      horizontalItemsCount: 5,
      verticalItemsCount: 5)
];
