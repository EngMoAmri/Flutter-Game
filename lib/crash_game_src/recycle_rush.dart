import 'dart:async';
import 'dart:math' as math;

import 'package:flame/cache.dart';
import 'package:flame/extensions.dart' as ext;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/crash_game_src/controllers/process_controller.dart';
import 'package:flutter_game/utlis/crash_level_catelog.dart';

import 'components/components.dart';
import 'config.dart';
import 'controllers/board_controller.dart';

enum PlayState { loading, playing, gameOver, won } // Add this enumeration

class RecycleRush extends FlameGame {
  final CrashLevelCatelog levelCatelog;

  late ValueNotifier<int> goulPoints; // amount of points to win
  late ValueNotifier<int> moves; // amount of moves
  final ValueNotifier<int> points = ValueNotifier(0); // amount of points earned
  late ValueNotifier<Map<GoulItem, int>> externalGouls;
  RecycleRush({required this.levelCatelog}) {
    goulPoints =
        ValueNotifier(levelCatelog.goulPoints); // amount of points to win
    moves = ValueNotifier(levelCatelog.moves); // amount of moves
    externalGouls = ValueNotifier(levelCatelog.externalGouls);
    itemSize =
        (levelCatelog.horizontalItemsCount > levelCatelog.verticalItemsCount)
            ? (gameWidth - (itemGutter * levelCatelog.verticalItemsCount)) /
                levelCatelog.horizontalItemsCount
            : (gameWidth - (itemGutter * levelCatelog.horizontalItemsCount)) /
                levelCatelog.verticalItemsCount;
  }

  /// the [key] is for the type name
  /// the [list] is for all related icons
  Map<String, Map<String, ext.Image>> itemsIcons = {};
  List<ItemType> itemsTypes = [];
  List<List<Node?>> board = [];

  Item? selectedItem;
  bool isProcessingMove = false;
  late BoardController boardController;
  late ProcessController processController;

  late ext.Image itemExplosionImage;
  @override
  ext.Color backgroundColor() {
    // remove background black color
    return Colors.transparent;
  }

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
    itemSize =
        (levelCatelog.horizontalItemsCount > levelCatelog.verticalItemsCount)
            ? (gameWidth - (itemGutter * levelCatelog.verticalItemsCount)) /
                levelCatelog.horizontalItemsCount
            : (gameWidth - (itemGutter * levelCatelog.horizontalItemsCount)) /
                levelCatelog.verticalItemsCount;

    for (var node in world.children.query<Node>()) {
      node.size = Vector2(itemSize, itemSize);
      for (var row = 0; row < levelCatelog.verticalItemsCount; row++) {
        var founded = false;
        for (var col = 0; col < levelCatelog.horizontalItemsCount; col++) {
          Vector2 position = Vector2(
            (col + 0.5) * itemSize + col * itemGutter,
            (row + 0.5) * itemSize + row * itemGutter,
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
      for (var row = 0; row < levelCatelog.verticalItemsCount; row++) {
        var founded = false;
        for (var col = 0; col < levelCatelog.horizontalItemsCount; col++) {
          if (!(board[row][col]!.isUsable)) continue;
          Vector2 position = Vector2(
            (col + 0.5) * itemSize + col * itemGutter,
            (row + 0.5) * itemSize + row * itemGutter,
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
    boardController = BoardController(this);
    processController = ProcessController(this);
    playState = PlayState.loading;
    camera.viewfinder.anchor = Anchor.topLeft;
    final imagesLoader = Images();

    itemsIcons.addAll({
      'can': {
        'none': await imagesLoader.load('items/can.png'),
        'col': await imagesLoader.load('items/can-col.png'),
        'row': await imagesLoader.load('items/can-row.png'),
        'square': await imagesLoader.load('items/can-square.png'),
      },
      'carton': {
        'none': await imagesLoader.load('items/carton.png'),
        'col': await imagesLoader.load('items/carton-col.png'),
        'row': await imagesLoader.load('items/carton-row.png'),
        'square': await imagesLoader.load('items/carton-square.png'),
      },
      'glass': {
        'none': await imagesLoader.load('items/glass.png'),
        'col': await imagesLoader.load('items/glass-row.png'),
        'row': await imagesLoader.load('items/glass-row.png'),
        'square': await imagesLoader.load('items/glass-square.png'),
      },
      'pan': {
        'none': await imagesLoader.load('items/pan.png'),
        'col': await imagesLoader.load('items/pan-col.png'),
        'row': await imagesLoader.load('items/pan-row.png'),
        'square': await imagesLoader.load('items/pan-square.png'),
      },
      'bottle': {
        'none': await imagesLoader.load('items/bottle.png'),
        'col': await imagesLoader.load('items/bottle-col.png'),
        'row': await imagesLoader.load('items/bottle-row.png'),
        'square': await imagesLoader.load('items/bottle-square.png'),
      },
      'superType': {
        'superType': await imagesLoader.load('items/grenade.png'),
      },
    });
    itemsTypes.addAll([
      ItemType.can,
      ItemType.carton,
      ItemType.glass,
      ItemType.pan,
      ItemType.bottle,
    ]);
    // initialize the board
    for (var row = 0; row < levelCatelog.verticalItemsCount; row++) {
      List<Node?> rowNodes = [];
      for (var col = 0; col < levelCatelog.horizontalItemsCount; col++) {
        rowNodes.add(null);
      }
      board.add(rowNodes);
    }
    itemExplosionImage = await imagesLoader.load('smoke.png');
    boardController.startGame();
  }
}
