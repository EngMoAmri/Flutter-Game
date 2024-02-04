import 'dart:async';
// import 'dart:math' as math;

import 'package:flame/cache.dart';
import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart' as ext;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_game/aim_game_src/config.dart';

import 'components/components.dart';

enum PlayState { loading, playing, gameOver, won } // Add this enumeration

class AimGame extends FlameGame
    with ScrollDetector, HasCollisionDetection {
  TiledComponent? homeMap;
  List<ext.Image> itemsIcons = [];
  late ext.Image bubble; // the items will be inside bubbles
  List<ItemType> itemsTypes = [];
  Item? testItem;
  Slingshot? slingshot;

  @override
  void onScroll(PointerScrollInfo info) {
    if (homeMap == null) return;
    // // make the game minimum zoom in
    // if (camera.viewfinder.zoom <= 1.5) {
    //   if (
    //       // make the game maximum zoom out
    //       camera.viewfinder.zoom +
    //               (info.scrollDelta.global.y.sign * zoomPerScrollUnit) >=
    //           (screenHeight / homeMap!.height)) {
    //     camera.viewfinder.zoom +=
    //         info.scrollDelta.global.y.sign * zoomPerScrollUnit;
    //     clampZoom();
    //   }
    // }else{
    //   camera.viewfinder.zoom = 1.5;
    // }
    // camera.moveTo(Vector2(
    //       camera.viewport.position.x, homeMap!.height - screenHeight / camera.viewfinder.zoom));
    }

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
    bubble = await imagesLoader.load('bubble.png');
    itemsTypes.addAll([
      ItemType.can,
      ItemType.carton,
      ItemType.glass,
      ItemType.pan,
      ItemType.bottle,
    ]);
    homeMap = await TiledComponent.load('throwing-map-1.tmx', Vector2.all(32));
    minZoom = screenHeight / homeMap!.height;
    await world.add(homeMap!);
    final obstacleGroup = homeMap!.tileMap.getLayer<ObjectGroup>('ground');
    for (var obj in obstacleGroup?.objects ?? []) {
      await world.add(Ground(
          fraction: 10,
          size: Vector2(obj.width, obj.height),
          position: Vector2(obj.x, obj.y)));
    }
    testItem = Item(Vector2(80, screenHeight - 100),
        image: itemsIcons[0], type: itemsTypes[0]);
    testItem!.radius = (itemSize / 2) - 8;
    await world.add(testItem!);
    slingshot = Slingshot(
      Vector2(200, homeMap!.height - 105),
    );
    await world.add(slingshot!);
    slingshot!.setSelectedItem(testItem!);
    // if (homeMap!.height > screenHeight) {
    //   camera.moveTo(Vector2(
    //       camera.viewport.position.x, homeMap!.height - screenHeight / camera.viewfinder.zoom));
    // }
  }

  // TODO delete this
  void setSelectedItemForTest() {
    slingshot!.setSelectedItem(testItem!);
  }

  @override
  void onGameResize(ext.Vector2 size) {
    screenWidth = size.x;
    screenHeight = size.y;
    if ((homeMap?.height ?? 0.0) > screenHeight) {
      camera.moveTo(Vector2(
          camera.viewport.position.x, homeMap!.height - screenHeight / camera.viewfinder.zoom));
    }
    camera.viewport =
        FixedResolutionViewport(resolution: Vector2(screenWidth, screenHeight));
    if (slingshot != null) {
      slingshot!.position = Vector2(200, homeMap!.height - 105);
    }
    // if (testItem != null) {
    //   camera.follow(testItem!, horizontalOnly: true);
    // }
    // testItem?.size = Vector2(itemSize, itemSize);
    // testItem?.radius = (itemSize / 2) - 8;
    super.onGameResize(Vector2(screenWidth, screenHeight));
  }
}
