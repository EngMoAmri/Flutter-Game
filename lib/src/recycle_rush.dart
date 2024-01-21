import 'dart:async';
import 'dart:math' as math;

import 'package:flame/cache.dart';
import 'package:flame/extensions.dart' as ext;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/components.dart';
import 'config.dart';
import 'match_result.dart';

enum PlayState { welcome, playing, gameOver, won } // Add this enumeration

class RecycleRush extends FlameGame {
  @override
  ext.Color backgroundColor() {
    // remove background black color
    return Colors.transparent;
  }

  // TODO foreach level
  final ValueNotifier<int> goul = ValueNotifier(100); // amount of points to win
  final ValueNotifier<int> moves = ValueNotifier(100); // amount of moves
  final ValueNotifier<int> points = ValueNotifier(0); // amount of points earned
  final rand = math.Random();
  double get width => size.x;
  double get height => size.y;
  double maxWidth = 500;

  late PlayState _playState; // Add from here...
  PlayState get playState => _playState;
  List<ext.Image> itemsIcons = [];
  List<ItemType> itemsTypes = [];
  List<List<Node?>> board = [];
  List<Item> itemsToRemove = [];

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
  void onGameResize(ext.Vector2 size) {
    if (size.x > maxWidth) {
      gameWidth = maxWidth;
      gameHeight = maxWidth;
    } else {
      gameWidth = size.x;
      gameHeight = size.x;
    }
    for (var playArea in world.children.query<PlayArea>()) {
      playArea.size = Vector2(gameWidth, gameHeight);
    }
    itemGutter = gameWidth * 0.015;
    itemSize =
        (gameWidth - (itemGutter * verticalItemsCount)) / horizontalItemsCount;

    for (var node in world.children.query<Node>()) {
      node.size = Vector2(itemSize, itemSize);
      node.item?.size = Vector2(itemSize, itemSize);
      for (var row = 0; row < verticalItemsCount; row++) {
        var founded = false;
        for (var col = 0; col < horizontalItemsCount; col++) {
          Vector2 position = Vector2(
            (col + 0.5) * itemSize + (col + 1) * itemGutter,
            (row + 0.5) * itemSize + row * itemGutter,
          );
          if (board[row][col] == node) {
            // node.item?.position = position;
            node.position = position;
            founded = true;
            break;
          }
        }
        if (founded) break;
      }
    }
    super.onGameResize(Vector2(gameWidth, gameHeight));
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;
    var playArea = PlayArea();
    world.add(playArea);
    // playArea.position = size / 2;
    playState = PlayState.welcome;
    final imagesLoader = Images();

    itemsIcons.addAll([
      await imagesLoader.load('can.png'),
      await imagesLoader.load('carton.png'),
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
  }

  void startGame() async {
    playState = PlayState.playing; // To here.
    points.value = 0;
    moves.value = 100; // TODO foreach level
    List<Node> nodes = [];
    List<Item> items = [];

    for (var row = 0; row < verticalItemsCount; row++) {
      for (var col = 0; col < horizontalItemsCount; col++) {
        Vector2 position = Vector2(
          (col + 0.5) * itemSize + (col + 1) * itemGutter,
          (row + 0.5) * itemSize + row * itemGutter,
        );
        int randomItemIndex = rand.nextInt(itemsTypes.length);
        var item = Item(
          itemPosition: position,
          image: itemsIcons[randomItemIndex],
          type: itemsTypes[randomItemIndex],
          row: row,
          col: col,
        );
        item.priority = 100;
        var node = Node(nodePosition: position, isUsable: true, item: item);

        items.add(item);
        nodes.add(node);
        // set the node on the board list
        board[row][col] = node;
      }
    }

    if (await checkBoard()) {
      // we have matches call again
      startGame();
      return;
    }
    world.removeAll(world.children.query<Node>());
    world.removeAll(world.children.query<Item>());
    await world.addAll(nodes);
    await world.addAll(items);
  } // Drop the debugMode

  Future<bool> checkBoardForNextMove() async {
    if (playState == PlayState.gameOver ||
        playState == PlayState.welcome ||
        playState == PlayState.won) {
      return false;
    }
    for (var row = 0; row < verticalItemsCount; row++) {
      for (var col = 0; col < horizontalItemsCount; col++) {
        if (board[row][col]!.isUsable) {
          Item item = board[row][col]!.item!;
          try {
            // checking with below item
            Item? neighborItem = board[row + 1][col]?.item;
            if (neighborItem != null) {
              // do a test swap to check if there is a match
              _doSwap(item, neighborItem, false);
              var hasMatches = await checkBoard();
              _doSwap(item, neighborItem, false);
              if (hasMatches) {
                return true;
              }
            }
          } catch (_) {}

          try {
            // checking with top item
            Item? neighborItem = board[row - 1][col]?.item;
            if (neighborItem != null) {
              // do a test swap to check if there is a match
              _doSwap(item, neighborItem, false);
              var hasMatches = await checkBoard();
              _doSwap(item, neighborItem, false);
              if (hasMatches) {
                return true;
              }
            }
          } catch (_) {}
          try {
            // checking with right item
            Item? neighborItem = board[row][col + 1]?.item;
            if (neighborItem != null) {
              // do a test swap to check if there is a match
              _doSwap(item, neighborItem, false);
              var hasMatches = await checkBoard();
              _doSwap(item, neighborItem, false);
              if (hasMatches) {
                return true;
              }
            }
          } catch (_) {}

          try {
            // checking with left item
            Item? neighborItem = board[row][col - 1]?.item;
            if (neighborItem != null) {
              // do a test swap to check if there is a match
              _doSwap(item, neighborItem, false);
              var hasMatches = await checkBoard();
              _doSwap(item, neighborItem, false);
              if (hasMatches) {
                return true;
              }
            }
          } catch (_) {}
        }
      }
    }
    return false;
  }

  Future<bool> checkBoard() async {
    if (playState == PlayState.gameOver ||
        playState == PlayState.welcome ||
        playState == PlayState.won) {
      return false;
    }
    bool hasMatched = false;
    itemsToRemove.clear();
    // clear matches
    for (var nodeRow in board) {
      for (var node in nodeRow) {
        node?.item?.isMatch = false;
      }
    }
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
    return hasMatched;
  }

  Future<void> processTurnOnMatchBoard(bool subtractMoves) async {
    for (var itemToRemove in itemsToRemove) {
      itemToRemove.isMatch = false;
    }
    // removeAndRefill
    await removeAndRefill(itemsToRemove);
    processTurn(1, subtractMoves);
    await Future.delayed(const Duration(milliseconds: 400));
    if (await checkBoard()) {
      await processTurnOnMatchBoard(false);
    }
    var hasNextMatch = await checkBoardForNextMove();
    if (hasNextMatch) {
      print('+++++++++++++++++++++++++++++');
    } else {
      print('@@                         @@');
    }
  }

  MatchResult isConnected(Item item) {
    List<Item> connectedItems = [];
    // ItemType itemType = item.type;

    connectedItems.add(item);
    //check right
    checkDirection(item, 1, 0, connectedItems);
    //check left
    checkDirection(item, -1, 0, connectedItems);

    //have we make a 3 match horizontal
    if (connectedItems.length == 3) {
      // print('3 match horrizontally ${itemType.name}');
      return MatchResult(connectedItems, MatchDirection.Horizontal);
    }
    //check more than 3 (long horizontal)
    if (connectedItems.length > 3) {
      // print('more 3 match horrizontally ${itemType.name}');
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
      // print('3 match vertically ${itemType.name}');
      return MatchResult(connectedItems, MatchDirection.Vertical);
    }

    //check more than 3 (long vertical)
    if (connectedItems.length > 3) {
      // print('more than 3 match vertically ${itemType.name}');
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
    await _doSwap(currentItem, targetItem, true);
    // this loop to make sure the items has been move
    while (currentItem.isMoving || targetItem.isMoving) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    bool hasMatch = await checkBoard();
    if (!hasMatch) {
      await _doSwap(currentItem, targetItem, true);

      // this loop to make sure the items has been move
      while (currentItem.isMoving || targetItem.isMoving) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } else {
      // we have a match
      await processTurnOnMatchBoard(true);
    }
    isProcessingMove = false;
    selectedItem = null;
  }

  // do swap
  Future<void> _doSwap(
      Item currentItem, Item targetItem, bool moveItems) async {
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
    if (!moveItems) return;
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
  Future<void> removeAndRefill(List<Item> itemsToRemove) async {
    // removing the items amd clearing the board at that location
    for (var item in itemsToRemove) {
      // remove the item
      item.parent!.remove(item);
      board[item.row][item.col]!.item = null;
    }
    // this is my idea to start from bottom
    for (var row = verticalItemsCount - 1; row >= 0; row--) {
      for (var col = horizontalItemsCount - 1; col >= 0; col--) {
        if (board[row][col]!.item == null) {
          // print('the location row: $row col: $col is Empty');
          await refillItem(row, col);
        }
      }
    }
  }

  // RefillItems
  Future<void> refillItem(int row, int col) async {
    // y offset
    int yOffset = 1;
    // while the cell above our current cell is null and we're below the height of the board
    while (row - yOffset >= 0 && board[row - yOffset][col]!.item == null) {
      // increament y offset
      // print('the item above current cell is empty');
      yOffset++;
    }
    // we either hit the top of board or found an item
    if (row - yOffset >= 0 && board[row - yOffset][col]!.item != null) {
      // we've found an item

      Item aboveItem = board[row - yOffset][col]!.item!;
      // set previous node item to null
      board[row - yOffset][col]!.item = null;

      await aboveItem.moveToTarget(board[row][col]!.position, 0.2);

      board[row][col]!.item = aboveItem;

      // update position
      aboveItem.setPosition(row, col);
      // update board
    }
    // if we have hit the top of the board
    if (row - yOffset < 0) {
      // print('reached the top');
      await spawnItemAtTop(col);
    }
  }

  // spawn item at top
  Future<void> spawnItemAtTop(int col) async {
    int nullRow = findLowestNullRow(col);
    int randomItemIndex = rand.nextInt(itemsTypes.length);
    var targetPosition = board[nullRow][col]!.nodePosition;
    var item = Item(
      itemPosition: Vector2(targetPosition.x, -60),
      image: itemsIcons[randomItemIndex],
      type: itemsTypes[randomItemIndex],
      row: nullRow,
      col: col,
    );
    await item.moveToTarget(targetPosition, 0.2);
    world.add(item);
    board[nullRow][col]!.item = item;
    while (item.isMoving) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  // find the index of lowest null
  int findLowestNullRow(int col) {
    int lowestRowNull = 99;
    for (var row = verticalItemsCount - 1; row >= 0; row--) {
      if (board[row][col]!.item == null) {
        lowestRowNull = row;
        break;
      }
    }
    return lowestRowNull;
  }

  void processTurn(int pointsToGain, bool subtractMoves) {
    points.value += pointsToGain;

    if (subtractMoves) {
      // this is actually a move not like when the item fill null places and get another match
      moves.value--;
    }
    // check winning
    if (points.value >= goul.value) {
      playState = PlayState.won;
      return;
    }
    // check lossing
    if (moves.value == 0) {
      playState = PlayState.gameOver;
    }
  }
}
