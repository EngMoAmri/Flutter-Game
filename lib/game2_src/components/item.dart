import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter_game/game1_src/config.dart';
import 'package:flutter_game/game1_src/recycle_rush.dart';
import 'dart:math' as math;

enum ItemType {
  can,
  carton,
  glass,
  pan,
  bottle,
  superType,
}

class Item extends CircleComponent
    with KeyboardHandler,
    DragCallbacks, HasCollisionDetection, HasGameRef<RecycleRush> {
  Item({required this.image, required this.type, required this.itemPosition})
      : super(
          radius: 25,
          
          position: itemPosition,
          paint: material.Paint()..color = material.Colors.white24,
          anchor: Anchor.center,
        );
  Image image;
  ItemType type; // this is not final coz it maight  change
  Vector2 itemPosition;
  double gravity = 60;
  double power = 10.0;
  Vector2? minPower;
  Vector2? maxPower;
  late Vector2 force;
  Vector2? dragStartPosition;
  Vector2? dragEndPosition;
  bool isMoving = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(itemSize, itemSize);

    add(SpriteComponent(
        size: size,
        sprite: Sprite(
          image,
        )));
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    if (position.y < gameHeight) {
      position.y += gravity * dt;
    }
  }
  void throwItem(){
    vel
  }
  // moveToTarget
  Future<void> moveToTarget(Vector2 targetPos, double duration) async {
    isMoving = true;
    add(MoveToEffect(
      targetPos,
      EffectController(duration: duration),
    ));
    await Future.delayed(Duration(milliseconds: (duration * 1000).toInt()));
    isMoving = false;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    dragStartPosition = event.localPosition;
    print(dragStartPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    dragEndPosition = event.localEndPosition;
  }

  @override
  void onDragEnd(DragEndEvent event) async {
    super.onDragEnd(event);
    print(dragEndPosition);
    force = (dragStartPosition! - dragEndPosition!) *  (minPower! - maxPower!).length;
    
    print(dragEndPosition);
  }
}
