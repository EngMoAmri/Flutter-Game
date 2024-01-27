import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flutter_game/game1_src/config.dart';
import 'package:flutter_game/game1_src/recycle_rush.dart';

enum ItemType {
  can,
  carton,
  glass,
  pan,
  bottle,
  superType,
}

class Item extends SpriteComponent with DragCallbacks, HasGameRef<RecycleRush> {
  Item({required this.image, required this.type, required this.itemPosition})
      : super(
          position: itemPosition,
          anchor: Anchor.center,
        );
  Image image;
  ItemType type; // this is not final coz it maight  change

  bool isMoving = false;
  Vector2 itemPosition;
  Vector2? dragStartPosition;
  Vector2? dragEndPosition;
  Item? targetItem;

  @override
  Future<void> onLoad() async {
    size = Vector2(itemSize, itemSize);
    sprite = Sprite(
      image,
    );
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
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    dragEndPosition = event.localEndPosition;
  }

  @override
  void onDragEnd(DragEndEvent event) async {
    super.onDragEnd(event);
  }
}
