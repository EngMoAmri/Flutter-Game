import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
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
  Vector2 velocity = Vector2(0, 0);
  Vector2? dragStartPosition;
  Vector2? dragEndPosition;
  bool isGrounded = false;
  bool isAiming = false;

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
      velocity.y += gravity;
      // print(velocity);
      position += velocity * dt;
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Ground) {
      isGrounded = true;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is Ground) {
      isGrounded = false;

      print('off the ground');
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
    // velocity = aimDirection * shootForce;
    // print(velocity);
    // y -= 10;

    isAiming = false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (isAiming) {
      var aimAngle = dragStartPosition!.angleToSigned(dragEndPosition!);
      // drawRotatedObject(
      //   canvas: canvas,
      //   center: Offset(size.x / 2, size.y / 2),
      //   angle: aimAngle,
      //   drawFunction: () => canvas.drawPath(aimPath, aimPainter),
      // );
      // var aimPosition = size / 2;
      dragStartPosition ??= Vector2(0, 0);
      // final path = Path()
      //   ..moveTo(dragStartPosition!.x, dragStartPosition!.y)
      //   ..lineTo(dragStartPosition!.x + 100, dragStartPosition!.y + 100);
      final arc = Rect.fromPoints(
          Offset(dragStartPosition!.x, dragStartPosition!.y),
          Offset(dragStartPosition!.x + 100, dragStartPosition!.y + 100));
      canvas.drawArc(arc, 0.0, -(2 * math.pi * 50) / 100, false, aimPainter);
    }
  }

  // void drawRotatedObject({
  //   required Canvas canvas,
  //   required Offset center,
  //   required double angle,
  //   required VoidCallback drawFunction,
  // }) {
  //   canvas.save();
  //   // canvas.translate(center.dx, center.dy);
  //   // canvas.rotate(angle);
  //   // canvas.translate(-center.dx, -center.dy);
  //   drawFunction();
  //   canvas.restore();
  // }
}
