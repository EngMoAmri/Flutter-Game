import 'package:flame/components.dart';
import 'package:flutter_game/src/components/item.dart';

class Node extends PositionComponent {
  Node({required this.isUsable, required this.item});
  // to determine if the place can be fill with item or not
  bool isUsable;
  Item? item;

  @override
  void onLoad() {
    if (item != null) {
      add(item!);
    }
  }

  // @override
  // void render(Canvas canvas) {
  //   if (visible) {
  //   } // If not visible none of the children will be rendered
  // }
}
