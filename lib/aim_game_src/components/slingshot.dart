import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_game/aim_game_src/aim_game.dart';
import 'package:flutter_game/aim_game_src/components/components.dart';

import 'dart:math' as math;

import 'package:flutter_game/aim_game_src/config.dart';

class Slingshot extends CircleComponent
    with DragCallbacks, CollisionCallbacks, HasGameRef<AimGame> {
  Slingshot(Vector2 currentPos)
      : super(
          position: currentPos,
          paint: material.Paint()..color = material.Colors.transparent,
          anchor: Anchor.center,
        );
  Item? selectedItem;
  double gravity = 5;
  double shootForce = 600;
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
    size = Vector2(140, 140);
    add(SpriteComponent(
        size: Vector2(100, 100),
        position: size / 2,
        anchor: Anchor.center,
        sprite: Sprite(
          await Images().load('items/slingshot.png'),
        )));
    dragStartPosition = Vector2(position.x, position.y - 40);
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
    item.useCollisions = false;
    selectedItem = item;
    selectedItem!.position = dragStartPosition!;
  }

  void throwSelectedItem() async {
    selectedItem!.position = dragStartPosition!;
    selectedItem!.movementDirection = movementDirection;
    selectedItem!.useGravity = true;
    selectedItem!.useCollisions = true;
    selectedItem = null;
    // TODO delete below testing
    await Future.delayed(const Duration(seconds: 5));
    game.setSelectedItemForTest();
    game.camera.moveTo(Vector2(
        game.camera.viewport.position.x, game.homeMap!.height - gameHeight));
  }

  void updateTrajectory(Vector2 dir, double dt) async {
    var maxPoints = 300;
    game.world.removeAll(game.world.children.query<Trajectory>());
    Vector2 pos = dragStartPosition!;
    var vel = dir * shootForce * shootPowerScale;
    for (int i = 0; i < maxPoints; i++) {
      await game.world.add(Trajectory(position: pos, size: Vector2.all(4)));
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
    // selectedItem!.position = dragStartPosition!;
    isAiming = true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    if (selectedItem == null) {
      isAiming = false;
      return;
    }
    var endPoint = Vector2(event.canvasEndPosition.x,
        event.canvasEndPosition.y + (game.homeMap!.height - gameHeight));
    var length = math.sqrt(math.pow(endPoint.x - dragStartPosition!.x, 2) +
        math.pow(endPoint.y - dragStartPosition!.y, 2));
    if (length < minDragDistance) {
      isAiming = false;
      selectedItem!.position = dragStartPosition!;
      shootPowerScale = 0;
      game.world.removeAll(game.world.children.query<Trajectory>());
    } else if (length > maxDragDistance) {
      isAiming = true;
      shootPowerScale = 1;
      // Vector2 endPoint = event.canvasEndPosition;
      endPoint.lerp(dragStartPosition!, 1 - (maxDragDistance / length));
      dragEndPosition = endPoint;
      selectedItem!.position = dragEndPosition!;
      aimDirection = (dragStartPosition! - dragEndPosition!).normalized();
    } else {
      isAiming = true;
      shootPowerScale = length / maxDragDistance;

      dragEndPosition = endPoint;
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
    game.world.removeAll(game.world.children.query<Trajectory>());
  }
}
