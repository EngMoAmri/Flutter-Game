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
    debugMode = true;
    size = Vector2(itemSize, itemSize);
    add(SpriteComponent(
        size: size,
        sprite: Sprite(
          image,
        )));
    add(CircleHitbox(
      radius: radius - 2,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isGrounded && useGravity) {
      movementDirection.y += gravity;
      position += movementDirection * dt;
    } else if (isGrounded &&
        (movementDirection.x > 1 || movementDirection.x < -1)) {
      position.x += movementDirection.x * dt;
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Ground) {
      var x1 = intersectionPoints.first.x;
      var x2 = intersectionPoints.last.x;
      var y1 = intersectionPoints.first.y;
      var y2 = intersectionPoints.last.y;
      print('$y1, $y2');
      print('${y}');
      // TODO deal with this perfectly
      if (y1 <= position.y || y2 <= position.y) {
        movementDirection.y = -movementDirection.y;
      } else if ((x1 - x2).abs() > 2) {
        isGrounded = true;
      } else if (x1 <= position.x ||
          x2 <= position.x ||
          x1 >= position.x + size.x ||
          x2 >= position.x + size.x) {
        movementDirection.x = -movementDirection.x;
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    // fraction
    if (other is Ground) {
      if (movementDirection.x > other.fraction ||
          movementDirection.x < -other.fraction) {
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
