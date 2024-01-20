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
    for (var row = 0; row < verticalItemsCount; row++) {
      List<Node?> rowNodes = [];
      for (var col = 0; col < horizontalItemsCount; col++) {
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

    for (var row = 0; row < verticalItemsCount; row++) {
      for (var col = 0; col < horizontalItemsCount; col++) {
        // Vector2 position = Vector2(x - spacingX, y - spacingY);
        Vector2 position = Vector2(
          (col + 0.5) * itemSize + (col + 1) * itemGutter,
          (row + 2.0) * itemSize + row * itemGutter,
        );
        int randomItemIndex = rand.nextInt(itemsTypes.length);
        var node = Node(
            isUsable: true,
            item: Item(
                image: itemsIcons[randomItemIndex],
                type: itemsTypes[randomItemIndex],
                row: row,
                col: col,
                currentPosition: position));

        nodes.add(node);
        // set the node on the board list
        board[row][col] = node;
      }
    }

    if (checkBoard(true)) {
      // we have matches call again
      startGame();
      return;
    }
    world.removeAll(world.children.query<Node>());
    world.addAll(nodes);
    playState = PlayState.playing; // To here.
  } // Drop the debugMode

  bool checkBoard(bool takeAction) {
    bool hasMatched = false;
    List<Item> itemsToRemove = [];
    for (var row = 0; row < verticalItemsCount; row++) {
      for (var col = 0; col < horizontalItemsCount; col++) {
        if (board[row][col]!.isUsable) {
          Item item = board[row][col]!.item!;

          // ensure its met matched
          if (!item.isMatch) {
            MatchResult connectedItemResult = isConnected(item);
            if (connectedItemResult.connectedItems.length >= 3) {
              // complex matching
              MatchResult superMatchResult = superMatch(connectedItemResult);
              itemsToRemove.addAll(superMatchResult.connectedItems);
              for (var connectedItem in superMatchResult.connectedItems) {
                connectedItem.isMatch = true;
              }
              hasMatched = true;
            }
          }
        }
      }
    }
    if (takeAction) {
      // removeAndRefill
      removeAndRefill(itemsToRemove);
    }
    return hasMatched;
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

  MatchResult superMatch(MatchResult matchResult) {
    // TODO test
    // if we have a horizontal or long horizontal match
    if (matchResult.direction == MatchDirection.Horizontal ||
        matchResult.direction == MatchDirection.LongHorizontal) {
      for (var item in matchResult.connectedItems) {
        List<Item> extraConnectedItems = [];
        checkDirection(item, 0, 1, extraConnectedItems);
        checkDirection(item, 0, -1, extraConnectedItems);
        if (extraConnectedItems.length >= 2) {
          // we have a super horizontal match
          extraConnectedItems.addAll(matchResult.connectedItems);
          return MatchResult(extraConnectedItems, MatchDirection.Super);
        }
      }
      return matchResult;
    }
    // if we have a veritcal or long vertical match
    if (matchResult.direction == MatchDirection.Vertical ||
        matchResult.direction == MatchDirection.LongVertical) {
      for (var item in matchResult.connectedItems) {
        List<Item> extraConnectedItems = [];
        checkDirection(item, 1, 0, extraConnectedItems);
        checkDirection(item, -1, 0, extraConnectedItems);
        if (extraConnectedItems.length >= 2) {
          // we have a super vertical match
          extraConnectedItems.addAll(matchResult.connectedItems);
          return MatchResult(extraConnectedItems, MatchDirection.Super);
        }
      }
      return matchResult;
    }
    return matchResult;
  }

  checkDirection(Item item, int xDir, int yDir, List<Item> connectedItems) {
    ItemType itemType = item.type;
    int row = item.row + xDir;
    int col = item.col + yDir;

    // check we within thhe boudries
    while (col >= 0 &&
        col < horizontalItemsCount &&
        row >= 0 &&
        row < verticalItemsCount) {
      if (board[row][col]!.isUsable) {
        Item neighborItem = board[row][col]!.item!;

        // does the type is match and not matched
        if (!neighborItem.isMatch && neighborItem.type == itemType) {
          connectedItems.add(neighborItem);
          row += xDir;
          col += yDir;
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
    bool hasMatch = checkBoard(true);
    if (!hasMatch) {
      await _doSwap(currentItem, targetItem);

      // this loop to make sure the items has been move
      while (currentItem.isMoving || targetItem.isMoving) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    isProcessingMove = false;
    selectedItem = null;
  }

  // do swap
  Future<void> _doSwap(Item currentItem, Item targetItem) async {
    Item temp = board[currentItem.row][currentItem.col]!.item!;
    board[currentItem.row][currentItem.col]!.item =
        board[targetItem.row][targetItem.col]!.item;
    board[targetItem.row][targetItem.col]!.item = temp;

    // update positions
    int tempXPos = currentItem.row;
    int tempYPos = currentItem.col;
    currentItem.row = targetItem.row;
    currentItem.col = targetItem.col;
    targetItem.row = tempXPos;
    targetItem.col = tempYPos;

    await currentItem.moveToTarget(targetItem.position, 0.2);
    await targetItem.moveToTarget(currentItem.position, 0.2);
  }

  // is adjacent
  bool _isAdjacent(Item currentItem, Item targetItem) {
    return ((currentItem.row - targetItem.row) +
                (currentItem.col - targetItem.col))
            .abs() ==
        1;
  }

  /// cascading items
  // remove and refill(List of items)
  void removeAndRefill(List<Item> itemsToRemove) {
    // removing the items amd clearing the board at that location
    for (var item in itemsToRemove) {
      // getting it's x and y poses and storing them
      int row = item.row;
      int col = item.col;

      // remove the item
      remove(item);
      // create a blank node
      board[row][col] = Node(isUsable: true, item: null);
    }
    // this is my idea to start from bottom
    for (var row = verticalItemsCount - 1; row >= 0; row--) {
      for (var col = horizontalItemsCount - 1; col >= 0; col--) {
        if (board[row][col]!.item == null) {
          print('the location row: $row col: $col is Empty');
          refillItem(row, col);
        }
      }
    }
    // for (var row = 0; row < verticalItemsCount; row++) {
    //   for (var col = 0; col < horizontalItemsCount; col++) {
    //     if (board[row][col]!.item == null) {
    //       print('the location row: $row col: $col is Empty');
    //       refillItem(row, col);
    //     }
    //   }
    // }
  }

  // RefillItems
  void refillItem(int row, int col) {
    // y offset
    int yOffset = 1;
    // while the cell above our current cell is null and we're below the height of the board
    while (row - yOffset > 0 && board[row - yOffset][col]!.item == null) {
      // increament y offset
      print('the item above current cell is empty');
      yOffset++;
    }
    // we either hit the top of board or found an item
    if (row - yOffset > 0 && board[row - yOffset][col]!.item != null) {
      // we've found an item
      Item aboveItem = board[row - yOffset][col]!.item!;
      // move it to correct location
      Vector2 targetPos = Vector2(
        (col + 0.5) * itemSize + (col + 1) * itemGutter,
        (row + 2.0) * itemSize + row * itemGutter,
      );
      aboveItem.moveToTarget(targetPos, 1);
      print(
          'move item at: row: ${row - yOffset}, col: $col moved to : row: $row, col: $col');
      // update position
      aboveItem.setPosition(row, col);
      // update board
      board[row][col] = board[row - yOffset][col];
      // set old position to null
      board[row - yOffset][col] = Node(isUsable: true, item: null);
    }
    // if we have hit the top of the board
    if (row - yOffset == 0) {
      print('reached the top');
      spawnItemAtTop(col);
    }
  }

  // spawn item at top
  void spawnItemAtTop(int col) {
    throw "Complete";
  }
  // find the index of lowest null

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
