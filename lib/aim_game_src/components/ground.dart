import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Ground extends PositionComponent {
  Ground({required this.fraction, required size, required position})
      : super(size: size, position: position);
  final double fraction;
  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    debugMode = true;
    add(RectangleHitbox());
  }
}
