import 'package:flutter_game/src/components/item.dart';

class Node {
  Node({required this.isUsable, required this.item});
  // to determine if the place can be fill with item or not
  bool isUsable;
  Item? item;
}
