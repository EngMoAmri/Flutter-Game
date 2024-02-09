import 'package:audioplayers/audioplayers.dart';
import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/painting.dart';
import 'package:flutter_game/aim_game_src/aim_game.dart';

import 'components.dart';

class Recycler extends CircleComponent
    with CollisionCallbacks, HasGameRef<AimGame> {
  Recycler(Vector2 currentPos)
      : super(
          position: currentPos,
          paint: material.Paint()..color = material.Colors.transparent,
          anchor: Anchor.center,
        );

  final successSound = AssetSource('sounds/better.mp3');

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(140, 140);
    add(SpriteComponent(
        size: Vector2(100, 100),
        position: size / 2,
        anchor: Anchor.center,
        sprite: Sprite(
          await Images().load('recycler.png'),
        )));
    final paint = Paint()..color = material.Colors.orange;

    add(
      CircleComponent(
        radius: size.y / 6,
        position: size / 2,
        anchor: Anchor.center,
        paint: paint,
      )..add(
          GlowEffect(
            15.0,
            EffectController(
              reverseDuration: 3,
              duration: 3,
              infinite: true,
            ),
          ),
        ),
    );
    add(CircleHitbox(
      radius: radius - 2,
    ));
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    if (other is Item) {
      AudioPlayer().play(successSound);
      await add(
        ParticleSystemComponent(
          priority: other.priority + 1, // to be displayed above the item
          position: size / 2,
          particle: SpriteAnimationParticle(
              size: Vector2.all(80),
              animation: SpriteSheet(
                image: game.itemExplosionImage,
                srcSize: Vector2.all(500.0),
              ).createAnimation(row: 0, stepTime: 0.5)),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 250));
      game.world.remove(other);
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
