import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame/sprite.dart';
import 'package:flutter_game/src/components/components.dart';
import 'package:flutter_game/src/config.dart';
import 'package:flutter_game/src/match_result.dart';
import 'package:flutter_game/src/recycle_rush.dart';

class ProcessController {
  ProcessController(this.recycleRush);
  final RecycleRush recycleRush;
  final goodSound = AssetSource('sounds/good.mp3');
  final betterSound = AssetSource('sounds/better.mp3');
  final superSound = AssetSource('sounds/super.mp3');

  /// Select item by first place the drag started
  void selectItem(Item item) {
    // prevent change the selected item if there is movement
    if (recycleRush.isProcessingMove) return;
    // if we don't have an item selected set the new one
    if (recycleRush.selectedItem == null) {
      recycleRush.selectedItem = item;
    }
    // if we select the  same item twice set null
    else if (recycleRush.selectedItem == item) {
      recycleRush.selectedItem = null;
    }
    // if selectedItem != null and current item is different attempt a swap
    else if (recycleRush.selectedItem != item) {
      swapItem(recycleRush.selectedItem!, item);
      // selecteditem back null
      recycleRush.selectedItem = null;
    }
  }

  /// swap item logic
  void swapItem(Item currentItem, Item targetItem) async {
    // to ensure all items are in there places
    for (var row = 0; row < verticalItemsCount; row++) {
      for (var col = 0; col < horizontalItemsCount; col++) {
        if (recycleRush.board[row][col]!.isUsable) {
          if (recycleRush.board[row][col]!.item!.isMoving) {
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
    recycleRush.isProcessingMove = true;
    await doSwap(currentItem, targetItem, true);
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
        processRowColBoard(recycleRush.selectedItem!, targetItem);
      } else if ((currentItem.powerType == PowerType.col &&
              targetItem.powerType == PowerType.square) ||
          (currentItem.powerType == PowerType.row &&
              targetItem.powerType == PowerType.square) ||
          (currentItem.powerType == PowerType.square &&
              targetItem.powerType == PowerType.row) ||
          (currentItem.powerType == PowerType.square &&
              targetItem.powerType == PowerType.col)) {
        // remove target position 3 row and 3 column
        processRowOrColWithSquareBoard(recycleRush.selectedItem!, targetItem);
      } else if (currentItem.powerType == PowerType.square &&
          targetItem.powerType == PowerType.square) {
        // remove target positions within 5 rows and 5 columns
        processDoubleSquaresBoard(recycleRush.selectedItem!, targetItem);
      }
    } else {
      // normal swapped
      List<MatchResult> matchResults =
          await recycleRush.boardController.checkBoard(currentItem, targetItem);
      if (matchResults.isEmpty) {
        await doSwap(currentItem, targetItem, true);

        // this loop to make sure the items has been move
        while (currentItem.isMoving || targetItem.isMoving) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      } else {
        // we have a match
        await processNormalMatchBoard(
            matchResults, true, recycleRush.selectedItem);
      }
      // wait some time before resetting variables
      await Future.delayed(const Duration(milliseconds: 200));
    }

    recycleRush.isProcessingMove = false;
    recycleRush.selectedItem = null;
  }

  /// do swap  changing items places
  /// [moveItems] if true will play the animtaion of movement or the swap is just for testing
  Future<void> doSwap(Item currentItem, Item targetItem, bool moveItems) async {
    Item temp = recycleRush.board[currentItem.row][currentItem.col]!.item!;
    recycleRush.board[currentItem.row][currentItem.col]!.item =
        recycleRush.board[targetItem.row][targetItem.col]!.item;
    recycleRush.board[targetItem.row][targetItem.col]!.item = temp;

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
    AudioPlayer().play(superSound);
    // I think there is no need to the direction of the matchresult coz we will destroy all similar elements
    // the swapped item is null coz we dont want to add process to add new power to the item
    MatchResult matchResult =
        MatchResult([selectedItem, targetItem], null, MatchDirection.None);
    for (int row = 0; row < verticalItemsCount; row++) {
      for (int col = 0; col < horizontalItemsCount; col++) {
        if (!recycleRush.board[row][col]!.isUsable) continue;
        if (recycleRush.board[row][col]!.item == null) continue;
        if (recycleRush.board[row][col]!.item!.type == normalItem.type) {
          matchResult.connectedItems.add(recycleRush.board[row][col]!.item!);
        }
      }
    }
    // removeAndRefill
    await removeAndRefill([matchResult], true);
  }

  /// this function to deal with row and col matches
  Future<void> processRowColBoard(Item selectedItem, Item targetItem) async {
    // TODO sound relateed to crush
    AudioPlayer().play(betterSound);
    // I think there is no need to the direction of the matchresult coz we will destroy all similar elements
    // the swapped item is null coz we dont want to add process to add new power to the item
    MatchResult matchResult =
        MatchResult([selectedItem, targetItem], null, MatchDirection.None);
    for (int row = 0; row < verticalItemsCount; row++) {
      if (!recycleRush.board[row][selectedItem.col]!.isUsable) continue;
      if (recycleRush.board[row][selectedItem.col]!.item == null) continue;
      matchResult.connectedItems
          .add(recycleRush.board[row][selectedItem.col]!.item!);
    }
    for (int col = 0; col < horizontalItemsCount; col++) {
      if (!recycleRush.board[selectedItem.row][col]!.isUsable) continue;
      if (recycleRush.board[selectedItem.row][col]!.item == null) continue;
      matchResult.connectedItems
          .add(recycleRush.board[selectedItem.row][col]!.item!);
    }
    // removeAndRefill
    await removeAndRefill([matchResult], true);
  }

  /// set square area to remove its items
  void processDoubleSquaresBoard(Item selectedItem, Item targetItem) async {
    // TODO sound relateed to crush
    AudioPlayer().play(betterSound);
    // I think there is no need to the direction of the matchresult coz we will destroy surronded square elements
    // the swapped item is null coz we dont want to add process to add new power to the item
    MatchResult matchResult =
        MatchResult([selectedItem, targetItem], null, MatchDirection.None);

    for (var row = selectedItem.row - 2; row <= selectedItem.row + 2; row++) {
      for (var col = selectedItem.col - 2; col <= selectedItem.col + 2; col++) {
        try {
          if (!recycleRush.board[row][col]!.isUsable) continue;
          if (recycleRush.board[row][col]!.item == null) continue;
          matchResult.connectedItems.add(recycleRush.board[row][col]!.item!);
        } catch (_) {
          // index not match error
        }
      }
    }
    // removeAndRefill
    await removeAndRefill([matchResult], true);
  }

  /// this function to deal with row and col matches
  Future<void> processRowOrColWithSquareBoard(
      Item selectedItem, Item targetItem) async {
    // TODO sound relateed to crush
    AudioPlayer().play(betterSound);
    // I think there is no need to the direction of the matchresult coz we will destroy all similar elements
    // the swapped item is null coz we dont want to add process to add new power to the item
    MatchResult matchResult =
        MatchResult([selectedItem, targetItem], null, MatchDirection.None);
    for (int row = 0; row < verticalItemsCount; row++) {
      if (!recycleRush.board[row][selectedItem.col]!.isUsable) continue;
      if (recycleRush.board[row][selectedItem.col]!.item == null) continue;
      matchResult.connectedItems
          .add(recycleRush.board[row][selectedItem.col]!.item!);
    }
    if (selectedItem.col + 1 < horizontalItemsCount) {
      for (int row = 0; row < verticalItemsCount; row++) {
        if (!recycleRush.board[row][selectedItem.col + 1]!.isUsable) continue;
        if (recycleRush.board[row][selectedItem.col + 1]!.item == null) {
          continue;
        }
        matchResult.connectedItems
            .add(recycleRush.board[row][selectedItem.col + 1]!.item!);
      }
    }
    if (selectedItem.col - 1 >= 0) {
      for (int row = 0; row < verticalItemsCount; row++) {
        if (!recycleRush.board[row][selectedItem.col - 1]!.isUsable) continue;
        if (recycleRush.board[row][selectedItem.col - 1]!.item == null) {
          continue;
        }
        matchResult.connectedItems
            .add(recycleRush.board[row][selectedItem.col - 1]!.item!);
      }
    }
    for (int col = 0; col < horizontalItemsCount; col++) {
      if (!recycleRush.board[selectedItem.row][col]!.isUsable) continue;
      if (recycleRush.board[selectedItem.row][col]!.item == null) continue;
      matchResult.connectedItems
          .add(recycleRush.board[selectedItem.row][col]!.item!);
    }
    if (selectedItem.row + 1 < verticalItemsCount) {
      for (int col = 0; col < horizontalItemsCount; col++) {
        if (!recycleRush.board[selectedItem.row + 1][col]!.isUsable) continue;
        if (recycleRush.board[selectedItem.row + 1][col]!.item == null) {
          continue;
        }
        matchResult.connectedItems
            .add(recycleRush.board[selectedItem.row + 1][col]!.item!);
      }
    }
    if (selectedItem.row - 1 >= 0) {
      for (int col = 0; col < horizontalItemsCount; col++) {
        if (!recycleRush.board[selectedItem.row - 1][col]!.isUsable) continue;
        if (recycleRush.board[selectedItem.row - 1][col]!.item == null) {
          continue;
        }
        matchResult.connectedItems
            .add(recycleRush.board[selectedItem.row - 1][col]!.item!);
      }
    }
    // TODO improve code appearance
    // removeAndRefill
    await removeAndRefill([matchResult], true);
  }

  /// this function to deal with matches
  Future<void> processNormalMatchBoard(List<MatchResult> matchResults,
      bool subtractMoves, Item? selectedItem) async {
    for (var matchResult in matchResults) {
      if (matchResult.direction == MatchDirection.Horizontal ||
          matchResult.direction == MatchDirection.Vertical) {
        AudioPlayer().play(goodSound);
      } else if (matchResult.direction == MatchDirection.LongHorizontal ||
          matchResult.direction == MatchDirection.LongVertical) {
        AudioPlayer().play(betterSound);
      } else {
        AudioPlayer().play(superSound);
        // TODO sound for square
      }
    }
    // removeAndRefill
    await removeAndRefill(matchResults, subtractMoves);
  }

  /// cascading items
  /// remove and refill(List of items)
  Future<void> removeAndRefill(
      List<MatchResult> matchResults, bool subtractMoves) async {
    List<Item> itemsToRemove = [];
    // removing the items amd clearing the board at that location
    // first we add all particles to a list to show them at the same time
    List<ParticleSystemComponent> explosionsParticles = [];
    for (var matchResult in matchResults) {
      for (var item in matchResult.connectedItems) {
        addDestroyParticle(item, explosionsParticles);
      }
      itemsToRemove.addAll(matchResult.connectedItems);

      if (matchResult.direction == MatchDirection.LongHorizontal) {
        // don't remove the selected item
        itemsToRemove.remove(matchResult.swappedItem);
        // instead change its type of power
        matchResult.swappedItem!.powerType = PowerType.col;
        matchResult.swappedItem!.sprite = Sprite(recycleRush
            .itemsIcons[matchResult.swappedItem!.type.name]!['col']!);
      } else if (matchResult.direction == MatchDirection.LongVertical) {
        // don't remove the selected item
        itemsToRemove.remove(matchResult.swappedItem);
        // instead change its type of power
        matchResult.swappedItem!.powerType = PowerType.row;
        matchResult.swappedItem!.sprite = Sprite(recycleRush
            .itemsIcons[matchResult.swappedItem!.type.name]!['row']!);
      } else if (matchResult.direction == MatchDirection.Square) {
        // don't remove the selected item
        itemsToRemove.remove(matchResult.swappedItem!);
        // instead change its type of power
        matchResult.swappedItem!.powerType = PowerType.square;
        // TODO square icons
        matchResult.swappedItem!.sprite = Sprite(recycleRush
            .itemsIcons[matchResult.swappedItem!.type.name]!['square']!);
      } else if (matchResult.direction == MatchDirection.Super) {
        // don't remove the selected item
        itemsToRemove.remove(matchResult.swappedItem!);
        // instead change its type of power
        matchResult.swappedItem!.type = ItemType.superType;
        matchResult.swappedItem!.powerType = PowerType.superType;
        matchResult.swappedItem!.sprite =
            Sprite(recycleRush.itemsIcons['superType']!['superType']!);
      }
      // cannot grow the itemsToRemove list so we create a temp list
      List<Item> previousItemsToRemove = [];
      previousItemsToRemove.addAll(itemsToRemove);
      // check if there is item with power then process its power
      for (var item in previousItemsToRemove) {
        if (item.powerType == PowerType.col) {
          // remove the entire column
          for (int row = 0; row < verticalItemsCount; row++) {
            if (!(recycleRush.board[row][item.col]?.isUsable ?? false)) {
              continue;
            }
            if ((recycleRush.board[row][item.col]!.item != null) &&
                !itemsToRemove
                    .contains(recycleRush.board[row][item.col]!.item)) {
              // add the particle
              addDestroyParticle(
                  recycleRush.board[row][item.col]!.item!, explosionsParticles);

              // add to remove list
              itemsToRemove.add(recycleRush.board[row][item.col]!.item!);
              recycleRush.board[row][item.col]!.item = null;
            }
          }
          addColDestroyParticle(item, explosionsParticles);
        } else if (item.powerType == PowerType.row) {
          // remove the entire row
          for (int col = 0; col < horizontalItemsCount; col++) {
            if (!(recycleRush.board[item.row][col]?.isUsable ?? false))
              continue;
            if ((recycleRush.board[item.row][col]!.item != null) &&
                !itemsToRemove
                    .contains(recycleRush.board[item.row][col]!.item)) {
              // add the particle
              addDestroyParticle(
                  recycleRush.board[item.row][col]!.item!, explosionsParticles);

              // add to remove list
              itemsToRemove.add(recycleRush.board[item.row][col]!.item!);
              recycleRush.board[item.row][col]!.item = null;
            }
          }
          addRowDestroyParticle(item, explosionsParticles);
        } else if (item.powerType == PowerType.square) {
          // remove square area
          addSquareNeighborsToRemove(item, itemsToRemove, explosionsParticles);
        } else if (item.powerType == PowerType.superType) {
          // remove related items
          addSuperMatchedItemsToRemove(
              item, itemsToRemove, explosionsParticles);
        }
        recycleRush.board[item.row][item.col]!.item = null;
      }
    }

    // add explosions
    await recycleRush.world.addAll(explosionsParticles);
    // wait to the explosions for some time
    await Future.delayed(const Duration(milliseconds: 300));
    // remove the explosions
    recycleRush.world.removeAll(explosionsParticles);
    // remove the items
    recycleRush.world.removeAll(itemsToRemove);
    for (var item in itemsToRemove) {
      for (var goulItem in recycleRush.externalGouls.value.keys) {
        if (goulItem.type == item.type &&
            goulItem.powerType == item.powerType) {
          if (recycleRush.externalGouls.value[goulItem] == 0) {
            continue;
          }
          Map<GoulItem, int> oldExternalGouls = {};
          oldExternalGouls.addAll(recycleRush.externalGouls.value);
          oldExternalGouls[goulItem] = oldExternalGouls[goulItem]! - 1;
          recycleRush.externalGouls.value = oldExternalGouls;
        }
      }
    }
    // this is my idea to start from bottom
    for (var row = verticalItemsCount - 1; row >= 0; row--) {
      for (var col = horizontalItemsCount - 1; col >= 0; col--) {
        if (recycleRush.board[row][col]!.item == null) {
          await refillItem(row, col);
        }
      }
    }
    processTurn(1, subtractMoves); //TODO other things
    await Future.delayed(const Duration(milliseconds: 400));
    var newMatchDirections =
        await recycleRush.boardController.checkBoard(null, null);
    if (newMatchDirections.isNotEmpty) {
      await processNormalMatchBoard(
          newMatchDirections, false, null); // here there is no select item
    }
    var hasNextMatch =
        await recycleRush.boardController.checkBoardForNextMove();
    if (!hasNextMatch) {
      // we need to shuffle the existing items
      await recycleRush.boardController.shuffleItems();
    }
  }

  /// set super match to remove its items
  void addSuperMatchedItemsToRemove(Item item, List<Item> itemsToRemove,
      List<ParticleSystemComponent> explosionsParticles) {
    for (var row = 0; row < verticalItemsCount; row++) {
      for (var col = 0; col < horizontalItemsCount; col++) {
        try {
          if ((recycleRush.board[row][col]?.isUsable ?? false)) {
            if (!itemsToRemove.contains(recycleRush.board[row][col]?.item) &&
                recycleRush.board[row][col]?.item?.type == item.type) {
              // add the particle
              addDestroyParticle(
                  recycleRush.board[row][col]!.item!, explosionsParticles);

              // add to remove list
              itemsToRemove.add(recycleRush.board[row][col]!.item!);
              recycleRush.board[row][col]!.item = null;
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
          if ((recycleRush.board[row][col]?.isUsable ?? false)) {
            if (!itemsToRemove.contains(recycleRush.board[row][col]?.item)) {
              // add the particle
              addDestroyParticle(
                  recycleRush.board[row][col]!.item!, explosionsParticles);

              // add to remove list
              itemsToRemove.add(recycleRush.board[row][col]!.item!);
              recycleRush.board[row][col]!.item = null;
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
              image: recycleRush.itemExplosionImage,
              srcSize: Vector2.all(500.0),
            ).createAnimation(row: 0, stepTime: 0.1))));
  }

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
                image: recycleRush.itemExplosionImage,
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
                image: recycleRush.itemExplosionImage,
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
                image: recycleRush.itemExplosionImage,
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
                image: recycleRush.itemExplosionImage,
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
    while (row - yOffset >= 0 &&
        recycleRush.board[row - yOffset][col]!.item == null) {
      // increament y offset
      yOffset++;
    }
    // we either hit the top of board or found an item
    if (row - yOffset >= 0 &&
        recycleRush.board[row - yOffset][col]!.item != null) {
      // we've found an item

      Item aboveItem = recycleRush.board[row - yOffset][col]!.item!;
      // set previous node item to null
      recycleRush.board[row - yOffset][col]!.item = null;

      aboveItem.moveToTarget(recycleRush.board[row][col]!.position, 0.2);

      recycleRush.board[row][col]!.item = aboveItem;

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
    int randomItemIndex =
        recycleRush.rand.nextInt(recycleRush.itemsTypes.length);
    var targetPosition = recycleRush.board[nullRow][col]!.position;
    var item = Item(
      itemPosition: Vector2(targetPosition.x, -60),
      image: recycleRush.itemsIcons[
          recycleRush.itemsIcons.keys.toList()[randomItemIndex]]!['none']!,
      type: recycleRush.itemsTypes[randomItemIndex],
      powerType: PowerType.none,
      row: nullRow,
      col: col,
    );
    item.moveToTarget(targetPosition, 0.2);
    recycleRush.world.add(item);
    recycleRush.board[nullRow][col]!.item = item;
  }

  /// find the index of lowest null to move items to
  int findLowestNullRow(int col) {
    int lowestRowNull = 99;
    for (var row = verticalItemsCount - 1; row >= 0; row--) {
      if (recycleRush.board[row][col]!.item == null) {
        lowestRowNull = row;
        break;
      }
    }
    return lowestRowNull;
  }

  /// do game calculations like moves, points,...
  void processTurn(int pointsToGain, bool subtractMoves) {
    recycleRush.points.value += pointsToGain;

    if (subtractMoves) {
      // this is actually a move not like when the item fill null places and get another match
      recycleRush.moves.value--;
    }
    // check winning
    if (recycleRush.points.value >= recycleRush.goulPoints.value) {
      recycleRush.playState = PlayState.won;
      return;
    }
    // check lossing
    if (recycleRush.moves.value == 0) {
      recycleRush.playState = PlayState.gameOver;
    }
  }
}
