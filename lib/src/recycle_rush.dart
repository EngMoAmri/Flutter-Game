import 'dart:async';
import 'dart:math' as math;

import 'package:flame/cache.dart';
import 'package:flame/extensions.dart' as ext;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/components.dart';
import 'config.dart';

enum PlayState { welcome, playing, gameOver, won } // Add this enumeration

class RecycleRush extends FlameGame {
  // Modify this line
  RecycleRush()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        );

  final ValueNotifier<int> score = ValueNotifier(0); // Add this line
  final rand = math.Random();
  double get width => size.x;
  double get height => size.y;
  // late double spacingX;
  // late double spacingY;

  late PlayState _playState; // Add from here...
  PlayState get playState => _playState;
  List<ext.Image> itemsIcons = [];
  List<ItemType> itemsTypes = [];
  List<List<Node?>> board = [];
  set playState(PlayState playState) {
    _playState = playState;
    switch (playState) {
      case PlayState.welcome:
      case PlayState.gameOver:
      case PlayState.won:
        overlays.add(playState.name);
      case PlayState.playing:
        overlays.remove(PlayState.welcome.name);
        overlays.remove(PlayState.gameOver.name);
        overlays.remove(PlayState.won.name);
    }
  } // To here.

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(PlayArea());

    playState = PlayState.welcome;
    final imagesLoader = Images();

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
    // initialize the board
    for (var x = 0; x < verticalItemsCount; x++) {
      List<Node?> rowNodes = [];
      for (var y = 0; y < horizontalItemsCount; y++) {
        rowNodes.add(null);
      }
      board.add(rowNodes);
    }
    startGame();
  }

  void startGame() {
    if (playState == PlayState.playing) return;

    score.value = 0;
    List<Node> nodes = [];
    // spacingX = (horizontalItemsCount - 1) / 2;
    // spacingY = (verticalItemsCount - 1) / 2;

    for (var x = 0; x < verticalItemsCount; x++) {
      for (var y = 0; y < horizontalItemsCount; y++) {
        // Vector2 position = Vector2(x - spacingX, y - spacingY);
        Vector2 position = Vector2(
          (y + 0.5) * itemSize + (y + 1) * itemGutter,
          (x + 2.0) * itemSize + x * itemGutter,
        );
        int randomItemIndex = rand.nextInt(itemsTypes.length);
        var node = Node(
            isUsable: true,
            item: Item(
                image: itemsIcons[randomItemIndex],
                type: itemsTypes[randomItemIndex],
                xPos: x,
                yPos: y,
                currentPosition: position));

        nodes.add(node);
        // set the node on the board list
        board[x][y] = node;
      }
    }

    if (checkBoard()) {
      // we have matches call again
      startGame();
      return;
    }
    world.removeAll(world.children.query<Node>());
    world.addAll(nodes);
    playState = PlayState.playing; // To here.
  } // Drop the debugMode

  bool checkBoard() {
    bool hasMatch = false;
    List<Item> itemsToRemove = [];
    for (var x = 0; x < verticalItemsCount; x++) {
      for (var y = 0; y < horizontalItemsCount; y++) {
        if (board[x][y]!.isUsable) {
          Item item = board[x][y]!.item!;

          // ensure its met matched
          if (!item.isMatch) {
            MatchResult connectedItemResult = isConnected(item);
            if (connectedItemResult.connectedItems.length >= 3) {
              itemsToRemove.addAll(connectedItemResult.connectedItems);
              for (var connectedItem in connectedItemResult.connectedItems) {
                connectedItem.isMatch = true;
              }
              hasMatch = true;
            }
          }
        }
      }
    }

    return hasMatch;
  }

  MatchResult isConnected(Item item) {
    List<Item> connectedItems = [];
    ItemType itemType = item.type;

    connectedItems.add(item);
    //check right
    checkDirection(item, 1, 0, connectedItems);
    //check left
    checkDirection(item, -1, 0, connectedItems);

    //have we make a 3 match horizontal
    if (connectedItems.length == 3) {
      print('3 match horrizontally ${itemType.name}');
      return MatchResult(connectedItems, MatchDirection.Horizontal);
    }
    //check more than 3 (long horizontal)
    if (connectedItems.length > 3) {
      print('more 3 match horrizontally ${itemType.name}');
      return MatchResult(connectedItems, MatchDirection.LongHorizontal);
    }

    // clear not connected items
    connectedItems.clear();
    // readd initial item
    connectedItems.add(item);
    //check up
    checkDirection(item, 0, 1, connectedItems);

    //check down
    checkDirection(item, 0, -1, connectedItems);

    //have we make a 3 match vertical
    if (connectedItems.length == 3) {
      print('3 match vertically ${itemType.name}');
      return MatchResult(connectedItems, MatchDirection.Vertical);
    }

    //check more than 3 (long vertical)
    if (connectedItems.length > 3) {
      print('more than 3 match vertically ${itemType.name}');
      return MatchResult(connectedItems, MatchDirection.LongVertical);
    }
    return MatchResult(connectedItems, MatchDirection.None);
  }

  checkDirection(Item item, int xDir, int yDir, List<Item> connectedItems) {
    ItemType itemType = item.type;
    int x = item.xPos + xDir;
    int y = item.yPos + yDir;

    // check we within thhe boudries
    while (y >= 0 &&
        y < horizontalItemsCount &&
        x >= 0 &&
        x < verticalItemsCount) {
      if (board[x][y]!.isUsable) {
        Item neighborItem = board[x][y]!.item!;

        // does the type is match and not matched
        if (!neighborItem.isMatch && neighborItem.type == itemType) {
          connectedItems.add(neighborItem);
          x += xDir;
          y += yDir;
        } else {
          break;
        }
      }
    }
  }

  /// Swapping item
  Item? selectedItem;
  bool isProcessingMove = false;
  // Select item
  void selectItem(Item item) {
    // if we don't have an item selected set the new one
    if (selectedItem == null) {
      selectedItem = item;
    }
    // if we select the  same item twice set null
    else if (selectedItem == item) {
      selectedItem = null;
    }
    // if selectedItem != null and current item is different attempt a swap
    else if (selectedItem != item) {
      swapItem(selectedItem!, item);
      // selecteditem back null
      selectedItem = null;
    }
  }

  // swap item logic
  void swapItem(Item currentItem, Item targetItem) async {
    // if not adjacent don't swap
    if (!_isAdjacent(currentItem, targetItem)) {
      return;
    }
    // do swap
    isProcessingMove = true;
    await _doSwap(currentItem, targetItem);
    // this loop to make sure the items has been move
    while (currentItem.isMoving || targetItem.isMoving) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    bool hasMatch = checkBoard();
    if (!hasMatch) {
      await _doSwap(currentItem, targetItem);

      // this loop to make sure the items has been move
      while (currentItem.isMoving || targetItem.isMoving) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    isProcessingMove = false;
  }

  // do swap
  Future<void> _doSwap(Item currentItem, Item targetItem) async {
    Item temp = board[currentItem.xPos][currentItem.yPos]!.item!;
    board[currentItem.xPos][currentItem.yPos]!.item =
        board[targetItem.xPos][targetItem.yPos]!.item;
    board[targetItem.xPos][targetItem.yPos]!.item = temp;

    // update positions
    int tempXPos = currentItem.xPos;
    int tempYPos = currentItem.yPos;
    currentItem.xPos = targetItem.xPos;
    currentItem.yPos = targetItem.yPos;
    targetItem.xPos = tempXPos;
    targetItem.yPos = tempYPos;

    await currentItem.moveToTarget(targetItem.position);
    await targetItem.moveToTarget(currentItem.position);
  }

  // is adjacent
  bool _isAdjacent(Item currentItem, Item targetItem) {
    return ((currentItem.xPos - targetItem.xPos) +
                (currentItem.yPos - targetItem.yPos))
            .abs() ==
        1;
  }
  // process Matches
}

class MatchResult {
  MatchResult(this.connectedItems, this.direction);
  List<Item> connectedItems;
  MatchDirection direction;
}

enum MatchDirection {
  Vertical,
  Horizontal,
  LongVertical,
  LongHorizontal,
  Super,
  None
}
