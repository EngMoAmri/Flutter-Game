import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/cache.dart';
import 'package:flame/extensions.dart' as ext;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import 'components/components.dart';
import 'config.dart';
import 'match_result.dart';

enum PlayState { loading, playing, gameOver, won } // Add this enumeration

class RecycleRush extends FlameGame {
  /// the [key] is for the type name
  /// the [list] is for all related icons
  Map<String, List<ext.Image>> itemsIcons = {};
  List<ItemType> itemsTypes = [];
  List<List<Node?>> board = [];
  // List<Item> itemsToRemove = [];
  Item? selectedItem;
  bool isProcessingMove = false;

  late ext.Image itemExplosionImage;
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

  late PlayState _playState; // Add from here...
  PlayState get playState => _playState;

  set playState(PlayState playState) {
    _playState = playState;
    switch (playState) {
      case PlayState.loading:
      case PlayState.gameOver:
      case PlayState.won:
        overlays.add(playState.name);
      case PlayState.playing:
        overlays.remove(PlayState.loading.name);
        overlays.remove(PlayState.gameOver.name);
        overlays.remove(PlayState.won.name);
    }
  }

  // for responsive widgets
  @override
  void onGameResize(ext.Vector2 size) {
    if (size.x > maxLength) {
      gameWidth = maxLength;
    } else {
      gameWidth = size.x;
    }
    if (size.y > maxLength) {
      gameHeight = maxLength;
    } else {
      gameHeight = size.x;
    }
    itemGutter = gameWidth * itemGutterRatio;
    itemSize = (horizontalItemsCount > verticalItemsCount)
        ? (gameWidth - (itemGutter * verticalItemsCount)) / horizontalItemsCount
        : (gameWidth - (itemGutter * horizontalItemsCount)) /
            verticalItemsCount;

    for (var node in world.children.query<Node>()) {
      node.size = Vector2(itemSize, itemSize);
      for (var row = 0; row < verticalItemsCount; row++) {
        var founded = false;
        for (var col = 0; col < horizontalItemsCount; col++) {
          Vector2 position = Vector2(
            (col + 0.5) * itemSize +
                col * itemGutter +
                itemSize * ((maxItemInRowAndCol - horizontalItemsCount) / 2),
            (row + 0.5) * itemSize +
                row * itemGutter +
                itemSize * ((maxItemInRowAndCol - verticalItemsCount) / 2),
          );
          if (board[row][col] == node) {
            node.position = position;
            founded = true;
            break;
          }
        }
        if (founded) break;
      }
    }
    for (var item in world.children.query<Item>()) {
      item.size = Vector2(itemSize, itemSize);
      for (var row = 0; row < verticalItemsCount; row++) {
        var founded = false;
        for (var col = 0; col < horizontalItemsCount; col++) {
          if (!(board[row][col]!.isUsable)) continue;
          Vector2 position = Vector2(
            (col + 0.5) * itemSize +
                col * itemGutter +
                itemSize * ((maxItemInRowAndCol - horizontalItemsCount) / 2),
            (row + 0.5) * itemSize +
                row * itemGutter +
                itemSize * ((maxItemInRowAndCol - verticalItemsCount) / 2),
          );
          if (board[row][col]!.item == item) {
            item.position = position;
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
    playState = PlayState.loading;
    camera.viewfinder.anchor = Anchor.topLeft;
    final imagesLoader = Images();

    itemsIcons.addAll({
      'can': [
        await imagesLoader.load('can.png'),
        await imagesLoader.load('can-col.png'),
        await imagesLoader.load('can-row.png'),
        await imagesLoader.load('can-square.png'),
      ],
      'carton': [
        await imagesLoader.load('carton.png'),
        await imagesLoader.load('carton-col.png'),
        await imagesLoader.load('carton-row.png'),
        await imagesLoader.load('carton-square.png'),
      ],
      'glass': [
        await imagesLoader.load('glass.png'),
        await imagesLoader.load('glass-row.png'),
        await imagesLoader.load('glass-row.png'),
        await imagesLoader.load('glass-square.png'),
      ],
      'pan': [
        await imagesLoader.load('pan.png'),
        await imagesLoader.load('pan-col.png'),
        await imagesLoader.load('pan-row.png'),
        await imagesLoader.load('pan-square.png'),
      ],
      'bottle': [
        await imagesLoader.load('bottle.png'),
        await imagesLoader.load('bottle-col.png'),
        await imagesLoader.load('bottle-row.png'),
        await imagesLoader.load('bottle-square.png'),
      ],
      'super': [
        await imagesLoader.load('grenade.png'),
      ],
    });
    itemsTypes.addAll([
      ItemType.can,
      ItemType.carton,
      ItemType.glass,
      ItemType.pan,
      ItemType.bottle,
    ]);
    // initialize the board
    for (var row = 0; row < verticalItemsCount; row++) {
      List<Node?> rowNodes = [];
      for (var col = 0; col < horizontalItemsCount; col++) {
        rowNodes.add(null);
      }
      board.add(rowNodes);
    }
    itemExplosionImage = await imagesLoader.load('smoke.png');
    startGame();
  }

  /// start game function
  /// this function will be called at the begining of the game and if the game has been over and the player wants to play again
  void startGame() async {
    if (playState == PlayState.playing) return;
    points.value = 0;
    moves.value = 100; // TODO foreach level
    List<Node> nodes = [];
    List<Item> items = [];
    for (var row = 0; row < verticalItemsCount; row++) {
      for (var col = 0; col < horizontalItemsCount; col++) {
        // if (!(board[row][col]!.isUsable)) continue;
        Vector2 position = Vector2(
          (col + 0.5) * itemSize +
              col * itemGutter +
              itemSize * ((maxItemInRowAndCol - horizontalItemsCount) / 2),
          (row + 0.5) * itemSize +
              row * itemGutter +
              itemSize * ((maxItemInRowAndCol - verticalItemsCount) / 2),
        );
        int randomItemIndex = rand.nextInt(itemsTypes.length - 1);
        // THis just for testing
        // // TODO remove
        if (row == 0 && col == 2 ||
            row == 1 && col == 2 ||
            row == 2 && col == 1 ||
            row == 2 && col == 3 ||
            row == 2 && col == 4) {
          randomItemIndex = 0;
        }
        if (row == 0 && col == 1 ||
            row == 1 && col == 1 ||
            row == 2 && col == 2 ||
            row == 3 && col == 1) {
          randomItemIndex = 1;
        }

        var item = Item(
          itemPosition: position,
          image: itemsIcons[itemsIcons.keys.toList()[randomItemIndex]]![0],
          type: itemsTypes[randomItemIndex],
          powerType: PowerType.none,
          row: row,
          col: col,
        );
        item.priority = 100;
        var node = Node(position, isUsable: true, item: item);

        items.add(item);
        nodes.add(node);
        // set the node on the board list
        board[row][col] = node;
      }
    }

    if ((await checkBoard(null, null)).isNotEmpty) {
      // we have matches call again
      startGame();
      return;
    }
    playState = PlayState.playing;
    world.removeAll(world.children.query<Node>());
    world.removeAll(world.children.query<Item>());
    await world.addAll(nodes);
    await world.addAll(items);
  }

  /// this function is to check if there a future match or not, if not we need to make shuffle to the items
  Future<bool> checkBoardForNextMove() async {
    if (playState == PlayState.gameOver ||
        // playState == PlayState.welcome ||
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
              var matchDirections = await checkBoard(null, null);
              _doSwap(item, neighborItem, false);
              if (matchDirections.isNotEmpty) {
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
              var matchDirections = await checkBoard(null, null);
              _doSwap(item, neighborItem, false);
              if (matchDirections.isNotEmpty) {
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
              var matchDirections = await checkBoard(null, null);
              _doSwap(item, neighborItem, false);
              if (matchDirections.isNotEmpty) {
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
              var matchDirections = await checkBoard(null, null);
              _doSwap(item, neighborItem, false);
              if (matchDirections.isNotEmpty) {
                return true;
              }
            }
          } catch (_) {}
        }
      }
    }
    return false;
  }

  /// this function to check for matches, it will return the match direction
  Future<List<MatchResult>> checkBoard(
      Item? selectedItem, Item? targetItem) async {
    if (playState == PlayState.gameOver ||
        // playState == PlayState.welcome ||
        playState == PlayState.won) {
      return [];
    }
    List<MatchResult> matchResults = [];
    // itemsToRemove.clear();
    // clear matches
    for (var nodeRow in board) {
      for (var node in nodeRow) {
        node?.item?.isMatch = false;
      }
    }
    // first check the items just moved
    if (selectedItem != null) {
      var connectionResult = isConnected(selectedItem);
      if (connectionResult.connectedItems.length >= 3) {
        // complex matching
        var complexMatchResult = complexMatch(connectionResult);
        for (var connectedItem in complexMatchResult.connectedItems) {
          connectedItem.isMatch = true;
        }
        matchResults.add(complexMatchResult);
      }
    }
    if (targetItem != null) {
      var connectionResult = isConnected(targetItem);
      if (connectionResult.connectedItems.length >= 3) {
        // complex matching
        var complexMatchResult = complexMatch(connectionResult);
        // itemsToRemove.addAll(superMatchResult.connectedItems);
        for (var connectedItem in complexMatchResult.connectedItems) {
          connectedItem.isMatch = true;
        }
        matchResults.add(complexMatchResult);
      }
    }
    for (var row = 0; row < verticalItemsCount; row++) {
      for (var col = 0; col < horizontalItemsCount; col++) {
        if (board[row][col]!.isUsable) {
          Item item = board[row][col]!.item!;

          // ensure its met matched
          if (!item.isMatch) {
            var connectionResult = isConnected(item);
            if (connectionResult.direction == MatchDirection.None) continue;
            if (connectionResult.connectedItems.length >= 3) {
              // complex matching
              var complexMatchResult = complexMatch(connectionResult);
              // itemsToRemove.addAll(superMatchResult.connectedItems);
              for (var connectedItem in complexMatchResult.connectedItems) {
                connectedItem.isMatch = true;
              }
              matchResults.add(complexMatchResult);
            }
          }
        }
      }
    }
    return matchResults;
  }

  /// this will shuffle the items, this method will be called until the next match be existed
  Future<void> shuffleItems() async {
    // put all items in one list to shuffle the list
    List<Item> items = [];
    for (var row = 0; row < verticalItemsCount; row++) {
      for (var col = 0; col < horizontalItemsCount; col++) {
        if (board[row][col]!.isUsable) {
          items.add(board[row][col]!.item!);
        }
      }
    }
    items.shuffle();
    int itemIndex = 0;
    for (var row = 0; row < verticalItemsCount; row++) {
      for (var col = 0; col < horizontalItemsCount; col++) {
        if (board[row][col]!.isUsable) {
          items[itemIndex].row = row;
          items[itemIndex].col = col;
          board[row][col]!.item = items[itemIndex++];
        }
      }
    }
    // the shuffle did'nt work so do it again
    if ((await checkBoard(null, null)).isNotEmpty) {
      return await shuffleItems();
    }
    // move to target
    itemIndex = 0;

    for (var row = 0; row < verticalItemsCount; row++) {
      for (var col = 0; col < horizontalItemsCount; col++) {
        if (board[row][col]!.isUsable) {
          (items[itemIndex++]).moveToTarget(board[row][col]!.position, 0.4);
        }
      }
    }
    // wait for the animation to end
    await Future.delayed(const Duration(milliseconds: 400));
  }

  /// this method will return the connected items connected to one
  MatchResult isConnected(Item item) {
    List<Item> horizontalConnectedItems = [];

    horizontalConnectedItems.add(item);
    //check right
    checkDirection(item, 1, 0, horizontalConnectedItems);
    //check left
    checkDirection(item, -1, 0, horizontalConnectedItems);

    List<Item> verticalConnectedItems = [];

    // clear not connected items
    verticalConnectedItems.clear();
    // readd initial item
    verticalConnectedItems.add(item);
    //check up
    checkDirection(item, 0, 1, verticalConnectedItems);

    //check down
    checkDirection(item, 0, -1, verticalConnectedItems);

    if (horizontalConnectedItems.length > verticalConnectedItems.length) {
      //have we make a 3 match horizontal
      if (horizontalConnectedItems.length == 3) {
        return MatchResult(
            horizontalConnectedItems, item, MatchDirection.Horizontal);
      }
      //check if 4 (long horizontal)
      if (horizontalConnectedItems.length == 4) {
        return MatchResult(
            horizontalConnectedItems, item, MatchDirection.LongHorizontal);
      }
      //check if 5 or more (super)
      if (horizontalConnectedItems.length >= 5) {
        return MatchResult(
            horizontalConnectedItems, item, MatchDirection.Super);
      }
    } else {
//have we make a 3 match vertical
      if (verticalConnectedItems.length == 3) {
        return MatchResult(
            verticalConnectedItems, item, MatchDirection.Vertical);
      }

      //check if 4 (long vertical)
      if (verticalConnectedItems.length == 4) {
        return MatchResult(
            verticalConnectedItems, item, MatchDirection.LongVertical);
      }
      //check if 5 or more (super)
      if (verticalConnectedItems.length >= 5) {
        return MatchResult(verticalConnectedItems, item, MatchDirection.Super);
      }
    }
    return MatchResult(verticalConnectedItems, item, MatchDirection.None);
  }

  /// complex match method checker
  MatchResult complexMatch(MatchResult matchResult) {
    // if we met the super match there is no need to make a square match check
    if (matchResult.direction == MatchDirection.Super) {
      // there will be extra in the middle only
      // which will be in the first place at connected items list
      var item = matchResult.connectedItems.first;

      List<Item> extraConnectedItems = [];
      checkDirection(item, 0, 1, extraConnectedItems);
      checkDirection(item, 0, -1, extraConnectedItems);
      checkDirection(item, 1, 0, extraConnectedItems);
      checkDirection(item, -1, 0, extraConnectedItems);
      if (extraConnectedItems.length >= 2) {
        // we have a super horizontal match
        extraConnectedItems.addAll(matchResult.connectedItems);
        return MatchResult(
            extraConnectedItems, matchResult.swappedItem, MatchDirection.Super);
      }

      return matchResult;
    }
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
          return MatchResult(extraConnectedItems, matchResult.swappedItem,
              MatchDirection.Square);
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
          return MatchResult(extraConnectedItems, matchResult.swappedItem,
              MatchDirection.Square);
        }
      }
      return matchResult;
    }
    return matchResult;
  }

  /// set items connected to item
  checkDirection(Item item, int xDir, int yDir, List<Item> connectedItems) {
    ItemType itemType = item.type;
    int row = item.row + yDir;
    int col = item.col + xDir;

    // check we within thhe boudries
    while (col >= 0 &&
        col < horizontalItemsCount &&
        row >= 0 &&
        row < verticalItemsCount) {
      if (board[row][col]!.isUsable) {
        Item neighborItem = board[row][col]!.item!;
        // does the type is match and not matched before
        if (!neighborItem.isMatch && neighborItem.type == itemType) {
          connectedItems.add(neighborItem);
          row += yDir;
          col += xDir;
        } else {
          break;
        }
      }
    }
  }

  /// Select item by first place the drag started
  void selectItem(Item item) {
    // prevent change the selected item if there is movement
    if (isProcessingMove) return;
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

  /// swap item logic
  void swapItem(Item currentItem, Item targetItem) async {
    // to ensure all items are in there places
    for (var row = 0; row < verticalItemsCount; row++) {
      for (var col = 0; col < horizontalItemsCount; col++) {
        if (board[row][col]!.isUsable) {
          if (board[row][col]!.item!.isMoving) {
            return;
          }
        }
      }
    }
    // if not adjacent don't swap
    if (!_isAdjacent(currentItem, targetItem)) {
      return;
    }
    // do swap
    isProcessingMove = true;
    await _doSwap(currentItem, targetItem, true);
    // this loop to make sure the items has been move
    while (currentItem.isMoving || targetItem.isMoving) {
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (currentItem.powerType == PowerType.superType) {
      // remove all similar items to the target item
      processSuperWithNormalBoard(true, currentItem, targetItem);
    } else if (currentItem.powerType != PowerType.none &&
        targetItem.powerType != PowerType.none) {
      // two powered items swapped
      if ((currentItem.powerType != PowerType.col &&
              targetItem.powerType == PowerType.col) ||
          (currentItem.powerType == PowerType.row &&
              targetItem.powerType == PowerType.row) ||
          (currentItem.powerType == PowerType.col &&
              targetItem.powerType == PowerType.row) ||
          (currentItem.powerType == PowerType.row &&
              targetItem.powerType == PowerType.col)) {
        // remove target position row and column
        processRowColBoard(selectedItem!, targetItem);
        print('wow1');
      } else if ((currentItem.powerType == PowerType.col &&
              targetItem.powerType == PowerType.square) ||
          (currentItem.powerType == PowerType.row &&
              targetItem.powerType == PowerType.square) ||
          (currentItem.powerType == PowerType.square &&
              targetItem.powerType == PowerType.row) ||
          (currentItem.powerType == PowerType.square &&
              targetItem.powerType == PowerType.col)) {
        // remove target position 3 row and 3 column
        processRowOrColWithSquareBoard(selectedItem!, targetItem);
        print('wow2');
      }
    } else {
      // normal swapped
      List<MatchResult> matchResults =
          await checkBoard(currentItem, targetItem);
      if (matchResults.isEmpty) {
        await _doSwap(currentItem, targetItem, true);

        // this loop to make sure the items has been move
        while (currentItem.isMoving || targetItem.isMoving) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      } else {
        // we have a match
        await processNormalMatchBoard(matchResults, true, selectedItem);
      }
      // wait some time before resetting variables
      await Future.delayed(const Duration(milliseconds: 200));
    }

    isProcessingMove = false;
    selectedItem = null;
  }

  /// do swap  changing items places
  /// [moveItems] if true will play the animtaion of movement or the swap is just for testing
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
    currentItem.moveToTarget(targetItem.position, 0.2);
    await targetItem.moveToTarget(currentItem.position, 0.2);
  }

  /// check if two items are adjacent
  bool _isAdjacent(Item currentItem, Item targetItem) {
    return ((currentItem.row - targetItem.row) +
                (currentItem.col - targetItem.col))
            .abs() ==
        1;
  }

  /// this function to deal with super match
  Future<void> processSuperWithNormalBoard(
      bool subtractMoves, Item selectedItem, Item targetItem) async {
    Item normalItem = (selectedItem.powerType == PowerType.superType)
        ? targetItem
        : selectedItem;
    // TODO sound relateed to crush
    AudioPlayer().play(AssetSource('sounds/super.mp3'));
    // I think there is no need to the direction of the matchresult coz we will destroy all similar elements
    // the swapped item is null coz we dont want to add process to add new power to the item
    MatchResult matchResult =
        MatchResult([selectedItem, targetItem], null, MatchDirection.None);
    for (int row = 0; row < verticalItemsCount; row++) {
      for (int col = 0; col < horizontalItemsCount; col++) {
        if (!board[row][col]!.isUsable) continue;
        if (board[row][col]!.item == null) continue;
        if (board[row][col]!.item!.type == normalItem.type) {
          matchResult.connectedItems.add(board[row][col]!.item!);
        }
      }
    }
    // removeAndRefill
    await removeAndRefill([matchResult]);
    processTurn(1, subtractMoves); //TODO other things
    await Future.delayed(const Duration(milliseconds: 400));
    var newMatchDirections = await checkBoard(null, null);
    if (newMatchDirections.isNotEmpty) {
      await processNormalMatchBoard(
          newMatchDirections, false, null); // here there is no select item
    }
    var hasNextMatch = await checkBoardForNextMove();
    if (!hasNextMatch) {
      // we need to shuffle the existing items
      await shuffleItems();
    }
  }

  /// this function to deal with row and col matches
  Future<void> processRowColBoard(Item selectedItem, Item targetItem) async {
    // TODO sound relateed to crush
    AudioPlayer().play(AssetSource('sounds/better.mp3'));
    // I think there is no need to the direction of the matchresult coz we will destroy all similar elements
    // the swapped item is null coz we dont want to add process to add new power to the item
    MatchResult matchResult =
        MatchResult([selectedItem, targetItem], null, MatchDirection.None);
    for (int row = 0; row < verticalItemsCount; row++) {
      if (!board[row][selectedItem.col]!.isUsable) continue;
      if (board[row][selectedItem.col]!.item == null) continue;
      matchResult.connectedItems.add(board[row][selectedItem.col]!.item!);
    }
    for (int col = 0; col < horizontalItemsCount; col++) {
      if (!board[selectedItem.row][col]!.isUsable) continue;
      if (board[selectedItem.row][col]!.item == null) continue;
      matchResult.connectedItems.add(board[selectedItem.row][col]!.item!);
    }
    // removeAndRefill
    await removeAndRefill([matchResult]);
    processTurn(1, true);
    await Future.delayed(const Duration(milliseconds: 400));
    var newMatchDirections = await checkBoard(null, null);
    if (newMatchDirections.isNotEmpty) {
      await processNormalMatchBoard(
          newMatchDirections, false, null); // here there is no select item
    }
    var hasNextMatch = await checkBoardForNextMove();
    if (!hasNextMatch) {
      // we need to shuffle the existing items
      await shuffleItems();
    }
  }

  /// this function to deal with row and col matches
  Future<void> processRowOrColWithSquareBoard(
      Item selectedItem, Item targetItem) async {
    // TODO sound relateed to crush
    print('wow');
    AudioPlayer().play(AssetSource('sounds/better.mp3'));
    // I think there is no need to the direction of the matchresult coz we will destroy all similar elements
    // the swapped item is null coz we dont want to add process to add new power to the item

    MatchResult matchResult =
        MatchResult([selectedItem, targetItem], null, MatchDirection.None);
    for (int row = 0; row < verticalItemsCount; row++) {
      if (!board[row][selectedItem.col]!.isUsable) continue;
      if (board[row][selectedItem.col]!.item == null) continue;
      matchResult.connectedItems.add(board[row][selectedItem.col]!.item!);
    }
    if (selectedItem.col + 1 < horizontalItemsCount) {
      for (int row = 0; row < verticalItemsCount; row++) {
        if (!board[row][selectedItem.col + 1]!.isUsable) continue;
        if (board[row][selectedItem.col + 1]!.item == null) continue;
        matchResult.connectedItems.add(board[row][selectedItem.col + 1]!.item!);
      }
    }
    if (selectedItem.col - 1 >= 0) {
      for (int row = 0; row < verticalItemsCount; row++) {
        if (!board[row][selectedItem.col - 1]!.isUsable) continue;
        if (board[row][selectedItem.col - 1]!.item == null) continue;
        matchResult.connectedItems.add(board[row][selectedItem.col - 1]!.item!);
      }
    }
    for (int col = 0; col < horizontalItemsCount; col++) {
      if (!board[selectedItem.row][col]!.isUsable) continue;
      if (board[selectedItem.row][col]!.item == null) continue;
      matchResult.connectedItems.add(board[selectedItem.row][col]!.item!);
    }
    if (selectedItem.row + 1 < verticalItemsCount) {
      for (int col = 0; col < horizontalItemsCount; col++) {
        if (!board[selectedItem.row + 1][col]!.isUsable) continue;
        if (board[selectedItem.row + 1][col]!.item == null) continue;
        matchResult.connectedItems.add(board[selectedItem.row + 1][col]!.item!);
      }
    }
    if (selectedItem.row - 1 >= 0) {
      for (int col = 0; col < horizontalItemsCount; col++) {
        if (!board[selectedItem.row - 1][col]!.isUsable) continue;
        if (board[selectedItem.row - 1][col]!.item == null) continue;
        matchResult.connectedItems.add(board[selectedItem.row - 1][col]!.item!);
      }
    }

    // removeAndRefill
    await removeAndRefill([matchResult]);
    processTurn(1, true);
    await Future.delayed(const Duration(milliseconds: 400));
    var newMatchDirections = await checkBoard(null, null);
    if (newMatchDirections.isNotEmpty) {
      await processNormalMatchBoard(
          newMatchDirections, false, null); // here there is no select item
    }
    var hasNextMatch = await checkBoardForNextMove();
    if (!hasNextMatch) {
      // we need to shuffle the existing items
      await shuffleItems();
    }
  }

  /// this function to deal with matches
  Future<void> processNormalMatchBoard(List<MatchResult> matchResults,
      bool subtractMoves, Item? selectedItem) async {
    for (var matchResult in matchResults) {
      if (matchResult.direction == MatchDirection.Horizontal ||
          matchResult.direction == MatchDirection.Vertical) {
        AudioPlayer().play(AssetSource('sounds/good.mp3'));
      } else if (matchResult.direction == MatchDirection.LongHorizontal ||
          matchResult.direction == MatchDirection.LongVertical) {
        AudioPlayer().play(AssetSource('sounds/better.mp3'));
      } else {
        AudioPlayer().play(AssetSource('sounds/super.mp3'));
        // TODO sound for square
      }
    }
    // removeAndRefill
    await removeAndRefill(matchResults);
    processTurn(1, subtractMoves); //TODO other things
    await Future.delayed(const Duration(milliseconds: 400));
    var newMatchDirections = await checkBoard(null, null);
    if (newMatchDirections.isNotEmpty) {
      await processNormalMatchBoard(
          newMatchDirections, false, null); // here there is no select item
    }
    var hasNextMatch = await checkBoardForNextMove();
    if (!hasNextMatch) {
      // we need to shuffle the existing items
      await shuffleItems();
    }
  }

  /// cascading items
  /// remove and refill(List of items)
  Future<void> removeAndRefill(List<MatchResult> matchResults) async {
    List<Item> itemsToRemove = [];
    // removing the items amd clearing the board at that location
    // first we add all particles to a list to show them at the same time
    List<ParticleSystemComponent> explosionsParticles = [];
    for (var matchResult in matchResults) {
      for (var item in matchResult.connectedItems) {
        addDestroyParticle(item, explosionsParticles);
      }
      itemsToRemove.addAll(matchResult.connectedItems);

      if (matchResult.swappedItem == null) {
        for (var item in itemsToRemove) {
          board[item.row][item.col]!.item = null;
        }
        continue;
      }
      // TODO below is not correct first if selected item is null random place the new item or find a better solution
      // change the selected Item if there is long match or super
      if (matchResult.direction == MatchDirection.LongHorizontal) {
        // don't remove the selected item
        itemsToRemove.remove(matchResult.swappedItem);
        // instead change its type of power
        matchResult.swappedItem!.powerType = PowerType.col;
        matchResult.swappedItem!.sprite =
            Sprite(itemsIcons[matchResult.swappedItem!.type.name]![1]);
      } else if (matchResult.direction == MatchDirection.LongVertical) {
        // don't remove the selected item
        itemsToRemove.remove(matchResult.swappedItem);
        // instead change its type of power
        matchResult.swappedItem!.powerType = PowerType.row;
        matchResult.swappedItem!.sprite =
            Sprite(itemsIcons[matchResult.swappedItem!.type.name]![2]);
      } else if (matchResult.direction == MatchDirection.Square) {
        // don't remove the selected item
        itemsToRemove.remove(matchResult.swappedItem!);
        // instead change its type of power
        matchResult.swappedItem!.powerType = PowerType.square;
        // TODO square icons
        matchResult.swappedItem!.sprite =
            Sprite(itemsIcons[matchResult.swappedItem!.type.name]![3]);
      } else if (matchResult.direction == MatchDirection.Super) {
        // don't remove the selected item
        itemsToRemove.remove(matchResult.swappedItem!);
        // instead change its type of power
        matchResult.swappedItem!.powerType = PowerType.superType;
        // TODO super icons
        matchResult.swappedItem!.sprite = Sprite(itemsIcons['super']![0]);
      }
      List<Item> previousItemsToRemove = [];
      previousItemsToRemove.addAll(itemsToRemove);
      // check if there is item with power then process its power
      for (var item in previousItemsToRemove) {
        if (item.powerType == PowerType.col) {
          // remove the entire column
          for (int row = 0; row < verticalItemsCount; row++) {
            if (!(board[row][item.col]?.isUsable ?? false)) continue;
            if ((board[row][item.col]!.item != null) &&
                !itemsToRemove.contains(board[row][item.col]!.item)) {
              // add the particle
              addDestroyParticle(
                  board[row][item.col]!.item!, explosionsParticles);

              // add to remove list
              itemsToRemove.add(board[row][item.col]!.item!);
              board[row][item.col]!.item = null;
            }
          }
          addColDestroyParticle(item, explosionsParticles);
        } else if (item.powerType == PowerType.row) {
          // remove the entire row
          for (int col = 0; col < horizontalItemsCount; col++) {
            if (!(board[item.row][col]?.isUsable ?? false)) continue;
            if ((board[item.row][col]!.item != null) &&
                !itemsToRemove.contains(board[item.row][col]!.item)) {
              // add the particle
              addDestroyParticle(
                  board[item.row][col]!.item!, explosionsParticles);

              // add to remove list
              itemsToRemove.add(board[item.row][col]!.item!);
              board[item.row][col]!.item = null;
            }
          }
          addRowDestroyParticle(item, explosionsParticles);
        } else if (item.powerType == PowerType.square) {
          // remove square area
          addSquareNeighborsToRemove(item, itemsToRemove, explosionsParticles);
        } else if (item.powerType == PowerType.superType) {
          // remove related items
          // TODO connection
          addSuperMatchedItemsToRemove(
              item, itemsToRemove, explosionsParticles);
        }
        board[item.row][item.col]!.item = null;
      }
    }

    // add explosions
    await world.addAll(explosionsParticles);
    // wait to the explosions for some time
    await Future.delayed(const Duration(milliseconds: 300));
    // remove the explosions
    world.removeAll(explosionsParticles);
    // remove the items
    world.removeAll(itemsToRemove);
    // this is my idea to start from bottom
    for (var row = verticalItemsCount - 1; row >= 0; row--) {
      for (var col = horizontalItemsCount - 1; col >= 0; col--) {
        if (board[row][col]!.item == null) {
          await refillItem(row, col);
        }
      }
    }
  }

  /// set square area to remove its items
  void addSuperMatchedItemsToRemove(Item item, List<Item> itemsToRemove,
      List<ParticleSystemComponent> explosionsParticles) {
    for (var row = 0; row < verticalItemsCount; row++) {
      for (var col = 0; col < horizontalItemsCount; col++) {
        try {
          if ((board[row][col]?.isUsable ?? false)) {
            if (!itemsToRemove.contains(board[row][col]?.item) &&
                board[row][col]?.item?.type == item.type) {
              // add the particle
              addDestroyParticle(board[row][col]!.item!, explosionsParticles);

              // add to remove list
              itemsToRemove.add(board[row][col]!.item!);
              board[row][col]!.item = null;
            }
          }
        } catch (_) {
          // index not match error
        }
      }
    }
  }

  /// set square area to remove its items
  void addSquareNeighborsToRemove(Item item, List<Item> itemsToRemove,
      List<ParticleSystemComponent> explosionsParticles) {
    for (var row = item.row - 1; row <= item.row + 1; row++) {
      for (var col = item.col - 1; col <= item.col + 1; col++) {
        try {
          if ((board[row][col]?.isUsable ?? false)) {
            if (!itemsToRemove.contains(board[row][col]?.item)) {
              // add the particle
              addDestroyParticle(board[row][col]!.item!, explosionsParticles);

              // add to remove list
              itemsToRemove.add(board[row][col]!.item!);
              board[row][col]!.item = null;
            }
          }
        } catch (_) {
          // index not match error
        }
      }
    }
  }

  /// add item destroy particle method
  void addDestroyParticle(
      Item item, List<ParticleSystemComponent> explosionsParticles) {
    explosionsParticles.add(ParticleSystemComponent(
        priority: item.priority + 1, // to be displayed above the item
        position: item.position,
        particle: SpriteAnimationParticle(
            size: Vector2.all(80),
            animation: SpriteSheet(
              image: itemExplosionImage,
              srcSize: Vector2.all(500.0),
            ).createAnimation(row: 0, stepTime: 0.1))));
  }

  Vector2 randomVector2() =>
      (Vector2.random(rand) - Vector2.random(rand)) * 100;

  /// add col destory particle method
  void addColDestroyParticle(
      Item item, List<ParticleSystemComponent> explosionsParticles) {
    explosionsParticles.add(
      ParticleSystemComponent(
        priority: item.priority + 1, // to be displayed above the item
        position: item.position,
        particle: AcceleratedParticle(
          speed: Vector2(0, 800),
          child: SpriteAnimationParticle(
              size: Vector2.all(80),
              animation: SpriteSheet(
                image: itemExplosionImage,
                srcSize: Vector2.all(500.0),
              ).createAnimation(row: 0, stepTime: 0.5)),
        ),
      ),
    );
    explosionsParticles.add(
      ParticleSystemComponent(
        priority: item.priority + 1, // to be displayed above the item
        position: item.position,
        particle: AcceleratedParticle(
          speed: Vector2(0, -800),
          child: SpriteAnimationParticle(
              size: Vector2.all(80),
              animation: SpriteSheet(
                image: itemExplosionImage,
                srcSize: Vector2.all(500.0),
              ).createAnimation(row: 0, stepTime: 0.5)),
        ),
      ),
    );
  }

  /// add row destory particle method
  void addRowDestroyParticle(
      Item item, List<ParticleSystemComponent> explosionsParticles) {
    explosionsParticles.add(
      ParticleSystemComponent(
        priority: item.priority + 1, // to be displayed above the item
        position: item.position,
        particle: AcceleratedParticle(
          speed: Vector2(800, 0),
          child: SpriteAnimationParticle(
              size: Vector2.all(80),
              animation: SpriteSheet(
                image: itemExplosionImage,
                srcSize: Vector2.all(500.0),
              ).createAnimation(row: 0, stepTime: 0.5)),
        ),
      ),
    );
    explosionsParticles.add(
      ParticleSystemComponent(
        priority: item.priority + 1, // to be displayed above the item
        position: item.position,
        particle: AcceleratedParticle(
          speed: Vector2(-800, 0),
          child: SpriteAnimationParticle(
              size: Vector2.all(80),
              animation: SpriteSheet(
                image: itemExplosionImage,
                srcSize: Vector2.all(500.0),
              ).createAnimation(row: 0, stepTime: 0.5)),
        ),
      ),
    );
  }

  /// Refill Items
  Future<void> refillItem(int row, int col) async {
    // y offset
    int yOffset = 1;
    // while the cell above our current cell is null and we're below the height of the board
    while (row - yOffset >= 0 && board[row - yOffset][col]!.item == null) {
      // increament y offset
      yOffset++;
    }
    // we either hit the top of board or found an item
    if (row - yOffset >= 0 && board[row - yOffset][col]!.item != null) {
      // we've found an item

      Item aboveItem = board[row - yOffset][col]!.item!;
      // set previous node item to null
      board[row - yOffset][col]!.item = null;

      aboveItem.moveToTarget(board[row][col]!.position, 0.2);

      board[row][col]!.item = aboveItem;

      // update position
      aboveItem.setPosition(row, col);
      // update board
    }
    // if we have hit the top of the board
    if (row - yOffset < 0) {
      spawnItemAtTop(col);
      // wait to the item to move to spawn new one
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  /// spawn new item at top
  Future<void> spawnItemAtTop(int col) async {
    int nullRow = findLowestNullRow(col);
    int randomItemIndex = rand.nextInt(itemsTypes.length);
    var targetPosition = board[nullRow][col]!.position;
    var item = Item(
      itemPosition: Vector2(targetPosition.x, -60),
      image: itemsIcons[itemsIcons.keys.toList()[randomItemIndex]]![0],
      type: itemsTypes[randomItemIndex],
      powerType: PowerType.none,
      row: nullRow,
      col: col,
    );
    item.moveToTarget(targetPosition, 0.2);
    world.add(item);
    board[nullRow][col]!.item = item;
  }

  /// find the index of lowest null to move items to
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

  /// do game calculations like moves, points,...
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
