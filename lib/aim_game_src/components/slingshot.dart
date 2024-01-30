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
  double shootForce = 500;
  Vector2 aimDirection = Vector2(0, 0);
  Vector2 movementDirection = Vector2(0, 0);
  double maxDragDistance = 100;
  double minDragDistance = 10;
  double shootPowerScale = 0;

  Vector2? dragStartPosition;
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
    dragStartPosition = Vector2(position.x - 20, position.y - 50);
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
    // add(item);
    item.useGravity = false;
    selectedItem = item;
    selectedItem!.position = dragStartPosition!;
  }

  void throwSelectedItem() async {
    selectedItem!.position = dragStartPosition!;
    selectedItem!.movementDirection = movementDirection;
    selectedItem!.useGravity = true;
    selectedItem = null;
    // TODO delete below testing
    await Future.delayed(const Duration(seconds: 5));
    game.setSelectedItemForTest();
  }

  void updateTrajectory(Vector2 dir, double dt) {
    var maxPoints = 300;
    removeAll(children.query<RectangleComponent>());
    var pos = Vector2((size.x / 2) - 20,
        0); // TODO this position is approximate I think I should make the correct position
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
    var length = math.sqrt(
        math.pow(event.canvasEndPosition.x - dragStartPosition!.x, 2) +
            math.pow(event.canvasEndPosition.y - dragStartPosition!.y, 2));
    if (length < minDragDistance) {
      isAiming = false;
      selectedItem!.position = dragStartPosition!;
      shootPowerScale = 0;
      removeAll(children.query<RectangleComponent>());
    } else if (length > maxDragDistance) {
      isAiming = true;
      shootPowerScale = 1;
      // TODO calculate the end positon
      dragEndPosition = event.canvasEndPosition * (length / maxDragDistance);
      selectedItem!.position = dragEndPosition!;
      aimDirection = (dragStartPosition! - dragEndPosition!).normalized();
    } else {
      isAiming = true;
      shootPowerScale = length / maxDragDistance;

      dragEndPosition = event.canvasEndPosition;
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
