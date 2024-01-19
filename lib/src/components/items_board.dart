import 'package:flame/cache.dart';
import 'package:flame/extensions.dart';
import 'package:flutter_game/src/components/item.dart';
import 'package:flutter_game/src/components/node.dart';
import 'dart:math' as math;

class ItemsBoard {
  ItemsBoard();
  // define the size of the board
  int width = 6;
  int height = 8;
  // spacing for the board
  late double spacingX;
  late double spacingY;
  // board nodes
  List<List<Node>> itemsBoard = [];
  final rand = math.Random();
  final imagesLoader = Images();
  List<Image> itemsIcons = [];
  List<ItemType> itemsTypes = [];
  void initializeBoard() async {
    itemsIcons.addAll([
      await imagesLoader.load('can.png'),
      await imagesLoader.load('cartoon.png'),
      await imagesLoader.load('glass.png'),
      await imagesLoader.load('paper.png'),
      await imagesLoader.load('plastic.png'),
    ]);
    itemsTypes.addAll([
      ItemType.can,
      ItemType.cartoon,
      ItemType.glass,
      ItemType.paper,
      ItemType.plastic,
    ]);
    spacingX = (width - 1) / 2;
    spacingY = (height - 1) / 2;
    for (var y = 0; y < height; y++) {
      List<Node> rowItems = [];
      for (var x = 0; x < width; x++) {
        Vector2 position = Vector2(x - spacingX, y - spacingY);
        int randomItemIndex = rand.nextInt(itemsTypes.length);
        Item item = Item(
            image: itemsIcons[randomItemIndex],
            type: itemsTypes[randomItemIndex],
            xPos: x,
            yPos: y,
            currentPosition: position);

        rowItems.add(Node(isUsable: true, item: item));
      }
      itemsBoard.add(rowItems);
    }
  }
}
