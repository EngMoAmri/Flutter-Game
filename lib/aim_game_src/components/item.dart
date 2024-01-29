import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_game/aim_game_src/aim_game.dart';
import 'package:flutter_game/aim_game_src/components/ground.dart';
import 'package:flutter_game/crash_game_src/config.dart';
// import 'dart:math' as math;

enum ItemType {
  can,
  carton,
  glass,
  pan,
  bottle,
  superType,
}

class Item extends CircleComponent
    with CollisionCallbacks, HasGameRef<AimGame> {
  Item(Vector2 itemPosition, {required this.image, required this.type})
      : super(
          position: itemPosition,
          paint: material.Paint()..color = material.Colors.white24,
          anchor: Anchor.center,
        );
  Image image;
  ItemType type; // this is not final coz it maight  change
  double gravity = 5;
  bool useGravity = true; // this to prevent gravity when it is on slingshot
  Vector2 movementDirection = Vector2(0, 0);
  bool isGrounded = false;
  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(itemSize, itemSize) * 0.8;

    add(SpriteComponent(
        size: size,
        sprite: Sprite(
          image,
        )));
    add(CircleHitbox(
      radius: radius,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isGrounded && useGravity) {
      movementDirection.y += gravity;
      position += movementDirection * dt;
      // TODO friction
    } else if (isGrounded &&
        (movementDirection.x > 1 || movementDirection.x < -1)) {
      // this is fraction
      position.x += movementDirection.x * dt;
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Ground) {
      isGrounded = true;
    }
    if (intersectionPoints.first.x <= position.x ||
        intersectionPoints.first.x >= position.x + size.x) {
      movementDirection.x = -movementDirection.x;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    // fraction
    if (other is Ground) {
      if (movementDirection.x > 1 || movementDirection.x < -1) {
        if (movementDirection.x > 0) {
          movementDirection.x -= other.fraction;
        } else {
          movementDirection.x += other.fraction;
        }
      } else {
        movementDirection.x = 0;
      }
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is Ground) {
      isGrounded = false;
    }
  }

  // @override
  // void onDragStart(DragStartEvent event) {
  //   super.onDragStart(event);
  //   dragStartPosition = size / 2;
  //   isAiming = true;
  // }

  // @override
  // void onDragUpdate(DragUpdateEvent event) {
  //   super.onDragUpdate(event);
  //   dragEndPosition = event.localEndPosition;
  //   aimDirection = (dragStartPosition! - dragEndPosition!).normalized();
  // }

  // @override
  // void onDragEnd(DragEndEvent event) async {
  //   super.onDragEnd(event);
  //   movementDirection = aimDirection * shootForce;
  //   y -= 10;
  //   isAiming = false;
  //   await Future.delayed(const Duration(milliseconds: 20));
  //   removeAll(children.query<RectangleComponent>());
  // }
}
