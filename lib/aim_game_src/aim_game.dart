import 'dart:async';
// import 'dart:math' as math;

import 'package:flame/cache.dart';
import 'package:flame/camera.dart';
import 'package:flame/extensions.dart' as ext;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_game/aim_game_src/config.dart';

import 'components/components.dart';

enum PlayState { loading, playing, gameOver, won } // Add this enumeration

class AimGame extends FlameGame with HasCollisionDetection {
  late TiledComponent homeMap;
  List<ext.Image> itemsIcons = [];
  List<ItemType> itemsTypes = [];
  Item? testItem;
  Slingshot slingshot = Slingshot(
    Vector2(200, gameHeight - 50),
  );

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    // debugMode = true;
    // camera.world = world;
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
    homeMap = await TiledComponent.load('throwing-map-1.tmx', Vector2.all(32));

    await world.add(homeMap);
    final obstacleGroup = homeMap.tileMap.getLayer<ObjectGroup>('ground');
    for (var obj in obstacleGroup!.objects) {
      await world.add(Ground(
          fraction: 10,
          size: Vector2(obj.width, obj.height),
          position: Vector2(obj.x, obj.y)));
    }
    testItem = Item(Vector2(80, gameHeight - 100),
        image: itemsIcons[0], type: itemsTypes[0]);
    testItem!.radius = (itemSize / 2) - 8;
    await world.add(testItem!);
    await world.add(slingshot);
    slingshot.setSelectedItem(testItem!);
  }

  // TODO delete this
  void setSelectedItemForTest() {
    slingshot.setSelectedItem(testItem!);
  }

  @override
  void onGameResize(ext.Vector2 size) {
    gameWidth = size.x;
    gameHeight = size.y;
    camera.viewport =
        FixedResolutionViewport(resolution: Vector2(gameWidth, gameHeight));
    slingshot.position = Vector2(200, gameHeight - 50);
    // if (testItem != null) {
    //   camera.follow(testItem!, horizontalOnly: true);
    // }
    // testItem?.size = Vector2(itemSize, itemSize);
    // testItem?.radius = (itemSize / 2) - 8;
    super.onGameResize(Vector2(gameWidth, gameHeight));
  }
}
