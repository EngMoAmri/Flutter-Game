import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flutter_game/game_src/config.dart';
import 'package:flutter_game/game_src/recycle_rush.dart';

enum ItemType {
  can,
  carton,
  glass,
  pan,
  bottle,
  superType,
}

/// destroy type
enum PowerType {
  row,
  col,
  square,
  superType,
  none,
}

class GoulItem {
  GoulItem({
    required this.type,
    required this.powerType,
  });
  final ItemType type;
  PowerType powerType;
}

class Item extends SpriteComponent with DragCallbacks, HasGameRef<RecycleRush> {
  Item(
      {required this.image,
      required this.type,
      required this.powerType,
      required this.row,
      required this.col,
      required this.itemPosition})
      : super(
          position: itemPosition,
          anchor: Anchor.center,
        );
  Image image;
  ItemType type; // this is not final coz it maight  change
  PowerType powerType;
  int row;
  int col;
  bool isMatch = false;
  bool isMoving = false;
  Vector2 itemPosition;
  Vector2? dragStartPosition;
  Vector2? dragEndPosition;
  Item? targetItem;
  void setPosition(int row, int col) {
    this.row = row;
    this.col = col;
  }

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
    if (game.isProcessingMove) return;
    game.selectedItem = this;
    dragStartPosition = event.localPosition;
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
    if (dragStartPosition == null) return;
    var xD = (dragStartPosition!.x - dragEndPosition!.x).abs();
    var yD = (dragStartPosition!.y - dragEndPosition!.y).abs();

    if (dragStartPosition!.x < dragEndPosition!.x) {
      // to right side
      if (dragStartPosition!.y < dragEndPosition!.y) {
        // to down side
        if (xD > yD) {
          // move right
          _moveRight();
        } else {
          // move down
          _moveDown();
        }
      } else {
        // to up side
        if (xD > yD) {
          // move right
          _moveRight();
        } else {
          // move up
          _moveUp();
        }
      }
    } else {
      // to left side
      if (dragStartPosition!.y < dragEndPosition!.y) {
        // to down side
        if (xD > yD) {
          // move left
          _moveLeft();
        } else {
          // move down
          _moveDown();
        }
      } else {
        // to up side
        if (xD > yD) {
          // move lef
          _moveLeft();
        } else {
          // move up
          _moveUp();
        }
      }
    }

    if (game.selectedItem == this) {
      if (targetItem == null) return;
      game.processController.swapItem(this, targetItem!);
    }
  }

  void _moveDown() {
    // get item below
    if (row < verticalItemsCount - 1) {
      // there is item bellow
      if (game.board[row + 1][col]!.isUsable) {
        targetItem = game.board[row + 1][col]!.item;
      }
    }
  }

  void _moveUp() {
    // get item above
    if (row > 0) {
      // there is item bellow
      if (game.board[row - 1][col]!.isUsable) {
        targetItem = game.board[row - 1][col]!.item;
      }
    }
  }

  void _moveRight() {
    // get item
    if (col < horizontalItemsCount - 1) {
      // there is item
      if (game.board[row][col + 1]!.isUsable) {
        targetItem = game.board[row][col + 1]!.item;
      }
    }
  }

  void _moveLeft() {
    // get item
    if (col > 0) {
      // there is item
      if (game.board[row][col - 1]!.isUsable) {
        targetItem = game.board[row][col - 1]!.item;
      }
    }
  }
}
