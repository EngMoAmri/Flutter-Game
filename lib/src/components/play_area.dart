import 'dart:async';
import 'package:flame/collisions.dart'; // Add this import

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../recycle_rush.dart';

class PlayArea extends RectangleComponent with HasGameReference<RecycleRush> {
  PlayArea()
      : super(
          paint: Paint()..color = const Color(0xfff2e8cf),
          children: [RectangleHitbox()],
        );

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    size = Vector2(game.width, game.height);
  }
}
