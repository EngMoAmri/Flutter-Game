import 'components/item.dart';

class MatchResult {
  MatchResult(this.connectedItems, this.swappedItem, this.direction);
  List<Item> connectedItems;
  Item? swappedItem;
  MatchDirection direction;
}

enum MatchDirection {
  Vertical,
  Horizontal,
  LongVertical,
  LongHorizontal,
  Square,
  Super,
  None
}
