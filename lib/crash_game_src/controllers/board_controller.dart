import 'package:flame/game.dart';
import 'package:flutter_game/crash_game_src/components/components.dart';
import 'package:flutter_game/crash_game_src/config.dart';
import 'package:flutter_game/crash_game_src/match_result.dart';
import 'package:flutter_game/crash_game_src/recycle_rush.dart';

class BoardController {
  BoardController(this.recycleRush);
  final RecycleRush recycleRush;

  /// start game function
  /// this function will be called at the begining of the game and if the game has been over and the player wants to play again
  void startGame() async {
    if (recycleRush.playState == PlayState.playing) return;
    recycleRush.points.value = 0;
    recycleRush.moves.value = recycleRush.levelCatelog.moves;
    List<Node> nodes = [];
    List<Item> items = [];
    for (var row = 0;
        row < recycleRush.levelCatelog.verticalItemsCount;
        row++) {
      for (var col = 0;
          col < recycleRush.levelCatelog.horizontalItemsCount;
          col++) {
        Vector2 position = Vector2(
          (col + 0.5) * itemSize + col * itemGutter,
          (row + 0.5) * itemSize + row * itemGutter,
        );

        int randomItemIndex =
            recycleRush.rand.nextInt(recycleRush.itemsTypes.length - 1);

        var item = Item(
          itemPosition: position,
          image: recycleRush.itemsIcons[
              recycleRush.itemsIcons.keys.toList()[randomItemIndex]]!['none']!,
          type: recycleRush.itemsTypes[randomItemIndex],
          powerType: PowerType.none,
          row: row,
          col: col,
        );
        item.priority = 100;
        var node = Node(position, isUsable: true, item: item);

        items.add(item);
        nodes.add(node);
        // set the node on the board list
        recycleRush.board[row][col] = node;
      }
    }

    if ((await checkBoard(null, null)).isNotEmpty) {
      // we have matches call again
      startGame();
      return;
    }
    recycleRush.playState = PlayState.playing;
    recycleRush.world.removeAll(recycleRush.world.children.query<Node>());
    recycleRush.world.removeAll(recycleRush.world.children.query<Item>());
    await recycleRush.world.addAll(nodes);
    await recycleRush.world.addAll(items);
  }

  /// this function is to check if there a future match or not, if not we need to make shuffle to the items
  Future<bool> checkBoardForNextMove() async {
    if (recycleRush.playState == PlayState.gameOver ||
        // playState == PlayState.welcome ||
        recycleRush.playState == PlayState.won) {
      return false;
    }
    for (var row = 0;
        row < recycleRush.levelCatelog.verticalItemsCount;
        row++) {
      for (var col = 0;
          col < recycleRush.levelCatelog.horizontalItemsCount;
          col++) {
        if (recycleRush.board[row][col]?.isUsable ?? false) {
          Item item = recycleRush.board[row][col]!.item!;
          try {
            // checking with below item
            Item? neighborItem = recycleRush.board[row + 1][col]?.item;
            if (neighborItem != null) {
              // do a test swap to check if there is a match
              recycleRush.processController.doSwap(item, neighborItem, false);
              var matchDirections = await checkBoard(null, null);
              recycleRush.processController.doSwap(item, neighborItem, false);
              if (matchDirections.isNotEmpty) {
                return true;
              }
            }
          } catch (_) {}

          try {
            // checking with top item
            Item? neighborItem = recycleRush.board[row - 1][col]?.item;
            if (neighborItem != null) {
              // do a test swap to check if there is a match
              recycleRush.processController.doSwap(item, neighborItem, false);
              var matchDirections = await checkBoard(null, null);
              recycleRush.processController.doSwap(item, neighborItem, false);
              if (matchDirections.isNotEmpty) {
                return true;
              }
            }
          } catch (_) {}
          try {
            // checking with right item
            Item? neighborItem = recycleRush.board[row][col + 1]?.item;
            if (neighborItem != null) {
              // do a test swap to check if there is a match
              recycleRush.processController.doSwap(item, neighborItem, false);
              var matchDirections = await checkBoard(null, null);
              recycleRush.processController.doSwap(item, neighborItem, false);
              if (matchDirections.isNotEmpty) {
                return true;
              }
            }
          } catch (_) {}

          try {
            // checking with left item
            Item? neighborItem = recycleRush.board[row][col - 1]?.item;
            if (neighborItem != null) {
              // do a test swap to check if there is a match
              recycleRush.processController.doSwap(item, neighborItem, false);
              var matchDirections = await checkBoard(null, null);
              recycleRush.processController.doSwap(item, neighborItem, false);
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
    if (recycleRush.playState == PlayState.gameOver ||
        // playState == PlayState.welcome ||
        recycleRush.playState == PlayState.won) {
      return [];
    }
    List<MatchResult> matchResults = [];
    // itemsToRemove.clear();
    // clear matches
    for (var nodeRow in recycleRush.board) {
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
    for (var row = 0;
        row < recycleRush.levelCatelog.verticalItemsCount;
        row++) {
      for (var col = 0;
          col < recycleRush.levelCatelog.horizontalItemsCount;
          col++) {
        if (recycleRush.board[row][col]?.isUsable ?? false) {
          Item item = recycleRush.board[row][col]!.item!;

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
    for (var row = 0;
        row < recycleRush.levelCatelog.verticalItemsCount;
        row++) {
      for (var col = 0;
          col < recycleRush.levelCatelog.horizontalItemsCount;
          col++) {
        if (recycleRush.board[row][col]?.isUsable ?? false) {
          items.add(recycleRush.board[row][col]!.item!);
        }
      }
    }
    items.shuffle();
    int itemIndex = 0;
    for (var row = 0;
        row < recycleRush.levelCatelog.verticalItemsCount;
        row++) {
      for (var col = 0;
          col < recycleRush.levelCatelog.horizontalItemsCount;
          col++) {
        if (recycleRush.board[row][col]?.isUsable ?? false) {
          items[itemIndex].row = row;
          items[itemIndex].col = col;
          recycleRush.board[row][col]!.item = items[itemIndex++];
        }
      }
    }
    // the shuffle did'nt work so do it again
    if ((await checkBoard(null, null)).isNotEmpty) {
      return await shuffleItems();
    }
    // move to target
    itemIndex = 0;

    for (var row = 0;
        row < recycleRush.levelCatelog.verticalItemsCount;
        row++) {
      for (var col = 0;
          col < recycleRush.levelCatelog.horizontalItemsCount;
          col++) {
        if (recycleRush.board[row][col]?.isUsable ?? false) {
          (items[itemIndex++])
              .moveToTarget(recycleRush.board[row][col]!.position, 0.4);
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
        col < recycleRush.levelCatelog.horizontalItemsCount &&
        row >= 0 &&
        row < recycleRush.levelCatelog.verticalItemsCount) {
      if (recycleRush.board[row][col]?.isUsable ?? false) {
        Item neighborItem = recycleRush.board[row][col]!.item!;
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
}
