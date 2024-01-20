import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flutter_game/src/config.dart';
import 'package:flutter_game/src/recycle_rush.dart';

import 'dart:math' as math;

enum ItemType { can, cartoon, glass, paper, plastic }

class Item extends SpriteComponent
    with TapCallbacks, DragCallbacks, HasGameRef<RecycleRush> {
  Item(
      {required this.image,
      required this.type,
      required this.xPos,
      required this.yPos,
      required this.currentPosition})
      : super(
          position: currentPosition,
          anchor: Anchor.center,
          // children: [RectangleHitbox()],
        );
  final Image image;
  final ItemType type;
  int xPos;
  int yPos;
  bool isMatch = false;
  bool isMoving = false;
  Vector2 currentPosition;
  Vector2? dragEndPosition;
  Item? targetItem;
  void setPosition(int xPos, int yPos) {
    this.xPos = xPos;
    this.yPos = yPos;
  }

  @override
  Future<void> onLoad() async {
    // final background = await Flame.images.load("background.jpg");
    // size = gameRef.size;
    size = Vector2(itemSize, itemSize);
    sprite = Sprite(
      image,
      // srcPosition: currentPosition,
      // srcSize: Vector2(256.0, 256.0),
    );
  }

  // moveToTarget
  Future<void> moveToTarget(Vector2 targetPos) async {
    isMoving = true;
    await add(MoveToEffect(targetPos, EffectController(duration: 0.2),
        onComplete: () {
      isMoving = false;
    }));
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (game.isProcessingMove) return;
    game.selectItem(this);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (game.isProcessingMove) return;
    game.selectedItem = this;
    print('selected : $xPos $yPos');
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    dragEndPosition = event.localEndPosition;
  }

  @override
  void onDragEnd(DragEndEvent event) async {
    super.onDragEnd(event);
    if (dragEndPosition == null) return;
    var angle = (position.angleToSigned(dragEndPosition!) * 180 / math.pi);
    print(angle);
    if (angle > -45 && angle <= 45) {
      // down
      print('down');

      // get item below
      if (xPos < verticalItemsCount - 1) {
        // there is item bellow
        if (game.board[xPos + 1][yPos]!.isUsable) {
          targetItem = game.board[xPos + 1][yPos]!.item;
        }
      }
    } else if (angle > 45 && angle <= 135) {
      // left
      print('left');

      // get item
      if (yPos > 0) {
        // there is item
        if (game.board[xPos][yPos - 1]!.isUsable) {
          targetItem = game.board[xPos][yPos - 1]!.item;
        }
      }
    } else if (angle > 135 && angle <= -135) {
      // top
      print('top');
      // get item below
      if (xPos > 0) {
        // there is item bellow
        if (game.board[xPos - 1][yPos]!.isUsable) {
          targetItem = game.board[xPos - 1][yPos]!.item;
        }
      }
    } else {
      // right
      print('right');
      // get item
      if (yPos < horizontalItemsCount - 1) {
        // there is item
        if (game.board[xPos][yPos + 1]!.isUsable) {
          targetItem = game.board[xPos][yPos + 1]!.item;
        }
      }
    }

    if (game.selectedItem == this) {
      if (targetItem == null) return;
      game.swapItem(this, targetItem!);
    }
  }
}
