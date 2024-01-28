import 'dart:async';
import 'dart:math' as math;

import 'package:flame/cache.dart';
import 'package:flame/extensions.dart' as ext;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';

import 'components/components.dart';
import 'components/ground.dart';

enum PlayState { loading, playing, gameOver, won } // Add this enumeration

class AimGame extends FlameGame with HasCollisionDetection {
  late TiledComponent homeMap;
  List<ext.Image> itemsIcons = [];
  List<ItemType> itemsTypes = [];
  // List<Item> itemsToRemove = [];
  Item? selectedItem;
  bool isProcessingMove = false;

  @override
  ext.Color backgroundColor() {
    // remove background black color
    return Colors.transparent;
  }

  final rand = math.Random();

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
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
    homeMap = await TiledComponent.load('map.tmx', Vector2.all(32));
    add(homeMap);
    final obstacleGroup = homeMap.tileMap.getLayer<ObjectGroup>('ground');
    for (var obj in obstacleGroup!.objects) {
      add(Ground(
          size: Vector2(obj.width, obj.height),
          position: Vector2(obj.x, obj.y)));
    }
    // double mapWidth = 32.0 * homeMap.tileMap.map.width;
    // double mapHeight = 32.0 * homeMap.tileMap.map.height;
    // camera.viewport =
    //     FixedResolutionViewport(resolution: Vector2(mapWidth, mapHeight));
    world.add(Item(Vector2(350, 0), image: itemsIcons[0], type: itemsTypes[0]));
  }

  // @override
  // void onGameResize(ext.Vector2 size) {
  //   gameWidth = size.x;
  //   gameHeight = size.y;
  //   super.onGameResize(Vector2(gameWidth, gameHeight));
  // }
}
