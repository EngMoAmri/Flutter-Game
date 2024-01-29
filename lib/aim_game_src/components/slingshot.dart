import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/painting.dart';
import 'package:flutter_game/aim_game_src/aim_game.dart';

import 'item.dart';
import 'dart:math' as math;

class Slingshot extends CircleComponent
    with DragCallbacks, CollisionCallbacks, HasGameRef<AimGame> {
  Slingshot(Vector2 currentPos)
      : super(
          position: currentPos,
          paint: material.Paint()..color = material.Colors.white10,
          anchor: Anchor.center,
        );
  Item? selectedItem;
  double gravity = 5;
  double shootForce = 300;
  Vector2 aimDirection = Vector2(0, 0);
  Vector2 movementDirection = Vector2(0, 0);
  Vector2? dragStartPosition;
  double maxDragDistance = 100;
  double minDragDistance = 10;
  double shootPowerScale = 0;

  Vector2? dragEndPosition;
  bool isAiming = false;
  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(120, 120);
    add(SpriteComponent(
        // priority: -1, //TODO hide the bottom of this
        // position: size / 2,
        size: Vector2(100, 100),
        sprite: Sprite(
          await Images().load('items/slingshot.png'),
        )));
    dragStartPosition = Vector2(size.x / 2, 0);
  }

  double timeElapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    // this is because the dt is not fixed so this make the trajectory line shaking
    // TODO find a better solution
    if (isAiming && timeElapsed > 0.1 && dt < 0.05) {
      updateTrajectory(aimDirection, dt);
      timeElapsed = 0;
    }
    timeElapsed += dt;
  }

  void setSelectedItem(Item item) {
    add(item);
    item.useGravity = false;
    selectedItem = item;
    selectedItem!.position = dragStartPosition!;
  }

  void throwSelectedItem() {
    // selectedItem!.removeFromParent();
    selectedItem!.position = dragStartPosition!;
    selectedItem!.movementDirection = movementDirection;
    selectedItem!.useGravity = true;
    selectedItem = null;
  }

  void updateTrajectory(Vector2 dir, double dt) {
    var maxPoints = 300;
    removeAll(children.query<RectangleComponent>());
    var pos = dragStartPosition!;
    var vel = dir * shootForce * shootPowerScale;
    for (int i = 0; i < maxPoints; i++) {
      add(RectangleComponent(
          position: pos,
          paint: Paint()..color = material.Colors.red,
          size: Vector2.all(4)));
      vel.y += gravity;
      pos += vel * dt;
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (selectedItem == null) {
      isAiming = false;
      return;
    }
    selectedItem!.position = dragStartPosition!;
    isAiming = true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (selectedItem == null) {
      isAiming = false;
      return;
    }
    Vector2 endPosition = event.localEndPosition;
    var length = math.sqrt(math.pow(endPosition.x - dragStartPosition!.x, 2) +
        math.pow(endPosition.y - dragStartPosition!.y, 2));
    if (length < minDragDistance) {
      isAiming = false;
      selectedItem!.position = dragStartPosition!;
      shootPowerScale = 0;
      removeAll(children.query<RectangleComponent>());
    } else if (length > maxDragDistance) {
      isAiming = true;
      shootPowerScale = 1;
      var itemEndPoint = endPosition / (length / 100);
      dragEndPosition = itemEndPoint;
      selectedItem!.position = dragEndPosition!;
      aimDirection = (dragStartPosition! - dragEndPosition!).normalized();
    } else {
      isAiming = true;
      shootPowerScale = length / maxDragDistance;

      dragEndPosition = event.localEndPosition;
      selectedItem!.position = dragEndPosition!;
      aimDirection = (dragStartPosition! - dragEndPosition!).normalized();
    }
  }

  @override
  void onDragEnd(DragEndEvent event) async {
    super.onDragEnd(event);

    if (isAiming == false) {
      return;
    }
    if (selectedItem == null) {
      isAiming = false;
      return;
    }

    movementDirection = aimDirection * shootForce * shootPowerScale;
    isAiming = false;
    throwSelectedItem();
    await Future.delayed(const Duration(milliseconds: 20));
    removeAll(children.query<RectangleComponent>());
  }
}
