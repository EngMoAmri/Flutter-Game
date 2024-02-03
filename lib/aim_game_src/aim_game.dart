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
    with ScrollDetector, ScaleDetector, HasCollisionDetection {
  TiledComponent? homeMap;
  List<ext.Image> itemsIcons = [];
  late ext.Image bubble; // the items will be inside bubbles
  List<ItemType> itemsTypes = [];
  Item? testItem;
  Slingshot? slingshot;
  void clampZoom() {
    camera.viewfinder.zoom = camera.viewfinder.zoom.clamp(0.05, 3.0);
  }

  static const zoomPerScrollUnit = 0.02;

  @override
  void onScroll(PointerScrollInfo info) {
    if (homeMap == null) return;
    var zoomDiff = (camera.viewfinder.zoom +
        info.scrollDelta.global.y.sign * zoomPerScrollUnit -
        (screenHeight / homeMap!.height));
    // make the game minimum zoom in
    if (zoomDiff < 0.65) {
      if (
          // make the game maximum zoom out
          camera.viewfinder.zoom +
                  (info.scrollDelta.global.y.sign * zoomPerScrollUnit) >=
              (screenHeight / homeMap!.height)) {
        camera.viewfinder.zoom +=
            info.scrollDelta.global.y.sign * zoomPerScrollUnit;
        clampZoom();
      }
    }
    // this is approximate calculation to move the camera to the bottom
    var cameraYOffset = 32 * zoomDiff / 0.07;
    // print(camera.viewfinder.zoom - (screenHeight / homeMap!.height));
    camera.moveTo(Vector2(camera.viewport.position.x, cameraYOffset));
  }

  late double startZoom;

  @override
  void onScaleStart(info) {
    startZoom = camera.viewfinder.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final currentScale = info.scale.global;
    if (homeMap == null) return;
    var zoomDiff =
        (startZoom * currentScale.y - (screenHeight / homeMap!.height));
    if (currentScale.isIdentity()) {
      final delta = info.delta.global;
      zoomDiff = (camera.viewfinder.zoom +
          delta.y.sign * zoomPerScrollUnit -
          (screenHeight / homeMap!.height));
    }
    // make the game minimum zoom in
    if (zoomDiff < 0.65) {
      if (!currentScale.isIdentity()) {
        if (startZoom * currentScale.y >= (screenHeight / homeMap!.height)) {
          camera.viewfinder.zoom = startZoom * currentScale.y;
          clampZoom();
        }
      } else {
        final delta = info.delta.global;
        // this is my solution to laptop touchpad and it's working
        if (camera.viewfinder.zoom + (delta.y.sign * zoomPerScrollUnit) >=
            (screenHeight / homeMap!.height)) {
          camera.viewfinder.zoom += delta.y.sign * zoomPerScrollUnit;
          clampZoom();
        }
      }
    }
    // this is approximate calculation to move the camera to the bottom
    // TODO exact
    var cameraYOffset = 32 * zoomDiff / 0.07;
    // print(camera.viewfinder.zoom - (screenHeight / homeMap!.height));
    camera.moveTo(Vector2(camera.viewport.position.x, cameraYOffset));
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
    camera.viewfinder.zoom = (screenHeight / homeMap!.height);

    await world.add(homeMap!);
    final obstacleGroup = homeMap!.tileMap.getLayer<ObjectGroup>('ground');
    for (var obj in obstacleGroup?.objects ?? []) {
      await world.add(Ground(
          fraction: 10,
          size: Vector2(obj.width, obj.height),
          position: Vector2(obj.x, obj.y)));
    }
    // testItem = Item(Vector2(80, gameHeight - 100),
    //     image: itemsIcons[0], type: itemsTypes[0]);
    // testItem!.radius = (itemSize / 2) - 8;
    // await world.add(testItem!);
    // slingshot = Slingshot(
    //   Vector2(200, homeMap!.height - 105),
    // );
    // await world.add(slingshot!);
    // slingshot!.setSelectedItem(testItem!);
    // if (homeMap!.height > gameHeight) {
    //   camera.moveTo(
    //       Vector2(camera.viewport.position.x, homeMap!.height - gameHeight));
    // }
  }

  // TODO delete this
  void setSelectedItemForTest() {
    slingshot!.setSelectedItem(testItem!);
  }

  @override
  void onGameResize(ext.Vector2 size) {
    // print('${homeMap!.height}, ${gameHeight}');
    screenWidth = size.x;
    screenHeight = size.y;
    if ((homeMap?.height ?? 0.0) > screenHeight) {
      camera.viewfinder.zoom = (screenHeight / homeMap!.height);

      // camera.moveTo(
      //     Vector2(camera.viewport.position.x, homeMap!.height - gameHeight));
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
