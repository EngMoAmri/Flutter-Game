import 'dart:async';
import 'dart:math' as math;

import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart' as ext;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';

import 'components/components.dart';
import 'components/ground.dart';
import 'components/slingshot.dart';

enum PlayState { loading, playing, gameOver, won } // Add this enumeration

class AimGame extends FlameGame with HasCollisionDetection {
  late TiledComponent homeMap;
  List<ext.Image> itemsIcons = [];
  List<ItemType> itemsTypes = [];
  // List<Item> itemsToRemove = [];
  Item? selectedItem;
  bool isProcessingMove = false;
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
          fraction: 10,
          size: Vector2(obj.width, obj.height),
          position: Vector2(obj.x, obj.y)));
    }
    final wallGroup = homeMap.tileMap.getLayer<ObjectGroup>('wall');
    for (var obj in wallGroup!.objects) {
      add(PositionComponent(
          size: Vector2(obj.width, obj.height),
          position: Vector2(obj.x, obj.y),
          children: [RectangleHitbox()]));
    }
    var testItem = Item(Vector2(80, size.y - 100),
        image: itemsIcons[0], type: itemsTypes[0]);
    var slingshot = Slingshot(
      Vector2(150, size.y - 50),
    );
    await world.add(testItem);
    await world.add(slingshot);
    slingshot.setSelectedItem(testItem);
  }

  // @override
  // void onGameResize(ext.Vector2 size) {
  //   gameWidth = size.x;
  //   gameHeight = size.y;
  //   super.onGameResize(Vector2(gameWidth, gameHeight));
  // }
}
