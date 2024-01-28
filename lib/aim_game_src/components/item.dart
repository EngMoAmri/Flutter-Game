import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/painting.dart';
import 'package:flutter_game/aim_game_src/aim_game.dart';
import 'package:flutter_game/aim_game_src/components/ground.dart';
import 'package:flutter_game/crash_game_src/config.dart';
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
    with DragCallbacks, CollisionCallbacks, HasGameRef<AimGame> {
  Item(Vector2 itemPosition,
      {required this.image, required this.type, this.circeRadius = 25})
      : super(
          radius: circeRadius,
          position: itemPosition,
          paint: material.Paint()..color = material.Colors.white24,
          anchor: Anchor.center,
        ) {
    debugMode = true;
  }
  double circeRadius;
  Image image;
  ItemType type; // this is not final coz it maight  change
  double gravity = 5;
  double shootForce = 500;
  double power = 10.0;
  // Vector2? minPower;
  // Vector2? maxPower;
  final aimPainter = Paint()
    ..color = material.Colors.red
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;
  Vector2 aimDirection = Vector2(0, 0);
  Vector2 movementDirection = Vector2(0, 0);
  Vector2? dragStartPosition;
  Vector2? dragEndPosition;
  bool isGrounded = false;
  bool isAiming = false;

  double deltaTime = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(itemSize, itemSize);

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
    if (!isGrounded) {
      movementDirection.y += gravity;
      position += movementDirection * dt;
    }
    if (dt > 0) {
      deltaTime = dt;
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Ground) {
      isGrounded = true;
    } else {
      // TODO remove this , it just to prevent item from going away
      movementDirection = Vector2(0, 0);
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is Ground) {
      isGrounded = false;
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    // event.localPosition
    dragStartPosition = size / 2;
    isAiming = true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    dragEndPosition = event.localEndPosition;
    aimDirection = (dragStartPosition! - dragEndPosition!).normalized();
  }

  @override
  void onDragEnd(DragEndEvent event) async {
    super.onDragEnd(event);
    movementDirection = aimDirection * shootForce;
    y -= 10;

    isAiming = false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (isAiming) {
      var initVelocity = aimDirection * shootForce * 0.1; // TODO
      print(
          'initial velocity x:${initVelocity.x.round()} y:${initVelocity.y.round()}');

      var movementDirection = aimDirection * shootForce;
      // calculating aiming angle
      // I think there is an easy way but ..
      var aimAngle = math.atan((dragStartPosition!.y - movementDirection.y) /
              (dragStartPosition!.x - movementDirection.x)) *
          -1;
      print(aimAngle * 180 / math.pi);

      Path path = Path();
      path.moveTo(dragStartPosition!.x, dragStartPosition!.y);

      // calculate horizontal distance
      var horizontalDistance = 2 *
          initVelocity.length2 *
          math.sin(aimAngle) *
          math.cos(aimAngle) /
          gravity;
      print('horizontal distance ${horizontalDistance.round()}');
      // maximum height
      var maxHeight = math.pow(initVelocity.x, 2) *
          math.pow(math.sin(aimAngle), 2) /
          (2 * gravity);
      path.quadraticBezierTo(
          dragStartPosition!.x + horizontalDistance / 2,
          dragStartPosition!.y - maxHeight,
          dragStartPosition!.x + horizontalDistance,
          dragStartPosition!.y + 200);
      // for (var child in game.children) {
      //   if (child is Ground) {
      //     path.addOval(child);
      //   }
      // }
      canvas.drawPath(path, aimPainter);
    }
  }
}
