import 'dart:async';
import 'dart:math' as math;

import 'package:flame/cache.dart';
import 'package:flame/extensions.dart' as ext;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/components.dart';

enum PlayState { loading, playing, gameOver, won } // Add this enumeration

class Game2 extends FlameGame {
  /// the [key] is for the type name
  /// the [list] is for all related icons
  List<ext.Image> itemsIcons = [];
  List<ItemType> itemsTypes = [];
  // List<Item> itemsToRemove = [];
  Item? selectedItem;
  bool isProcessingMove = false;

  @override
  ext.Color backgroundColor() {
    // remove background black color
    return Colors.black;
  }

  final rand = math.Random();

  late PlayState _playState; // Add from here...
  PlayState get playState => _playState;

  set playState(PlayState playState) {
    _playState = playState;
    // switch (playState) {
    //   case PlayState.loading:
    //   case PlayState.gameOver:
    //   case PlayState.won:
    //   // overlays.add(playState.name);
    //   case PlayState.playing:
    //     overlays.remove(PlayState.loading.name);
    //     overlays.remove(PlayState.gameOver.name);
    //     overlays.remove(PlayState.won.name);
    // }
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    playState = PlayState.loading;
    camera.viewfinder.anchor = Anchor.topLeft;
    final imagesLoader = Images();

    itemsIcons.addAll([
      await imagesLoader.load('items/can.png'),
      await imagesLoader.load('items/carton.png'),
      await imagesLoader.load('items/glass.png'),
      await imagesLoader.load('items/pan.png'),
      await imagesLoader.load('items/bottle.png'),
    ]);
    itemsTypes.addAll([
      ItemType.can,
      ItemType.carton,
      ItemType.glass,
      ItemType.pan,
      ItemType.bottle,
    ]);

    world.add(Item(
        image: itemsIcons[0], type: itemsTypes[0], itemPosition: size / 2));
  }

  // @override
  // void onGameResize(ext.Vector2 size) {
  //   gameWidth = size.x;
  //   gameHeight = size.y;
  //   super.onGameResize(Vector2(gameWidth, gameHeight));
  // }
}
