import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/src/components/item.dart';
import 'package:flutter_game/src/config.dart';

class Node extends RectangleComponent {
  Node({required this.isUsable, required this.item, required this.nodePosition})
      : super(
          position: nodePosition,
          anchor: Anchor.center,
          paint: Paint()..color = Colors.blue.withAlpha(70),
        ); // to determine if the place can be fill with item or not
  bool isUsable;
  Item? item;
  Vector2 nodePosition;
  @override
  void onLoad() {
    size = Vector2(itemSize, itemSize);
  }
}
