import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter_game/src/config.dart';
import 'package:flutter_game/src/recycle_rush.dart';

enum ItemType { can, cartoon, glass, paper, plastic }

class Item extends SpriteComponent with HasGameRef<RecycleRush> {
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
  Vector2? targetPosition;
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
}
