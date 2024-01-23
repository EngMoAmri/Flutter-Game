import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/src/components/item.dart';
import 'package:flutter_game/src/config.dart';

class Node extends RectangleComponent {
  Node(Vector2 nodePosition, {required this.isUsable, required this.item})
      : super(
          position: nodePosition,
          anchor: Anchor.center,
          paint: Paint()..color = Colors.white54.withAlpha(200),
        ); // to determine if the place can be fill with item or not
  bool isUsable;
  Item? item;
  @override
  void onLoad() {
    size = Vector2(itemSize, itemSize);
  }
  // @override
  // void onGameResize(Vector2 size) {
  //   // nodePosition = position
  //   super.onGameResize(size);
  // }
}
