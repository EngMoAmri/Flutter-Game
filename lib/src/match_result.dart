import 'components/item.dart';

class MatchResult {
  MatchResult(this.connectedItems, this.direction);
  List<Item> connectedItems;
  MatchDirection direction;
}

enum MatchDirection {
  Vertical,
  Horizontal,
  LongVertical,
  LongHorizontal,
  Super,
  None
}
