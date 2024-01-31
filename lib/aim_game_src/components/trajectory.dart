import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Trajectory extends RectangleComponent {
  Trajectory({required size, required position})
      : super(
            size: size, paint: Paint()..color = Colors.red, position: position);
  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
  }
}
