import 'dart:async';
import 'dart:math' as math;

import 'package:flame/cache.dart';
import 'package:flame/extensions.dart' as ext;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/components.dart';
import 'config.dart';

enum PlayState { welcome, playing, gameOver, won } // Add this enumeration

class RecycleRush extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  // Modify this line
  RecycleRush()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        );

  final ValueNotifier<int> score = ValueNotifier(0); // Add this line
  final rand = math.Random();
  double get width => size.x;
  double get height => size.y;
  late double spacingX;
  late double spacingY;

  late PlayState _playState; // Add from here...
  PlayState get playState => _playState;
  List<ext.Image> itemsIcons = [];
  List<ItemType> itemsTypes = [];

  set playState(PlayState playState) {
    _playState = playState;
    switch (playState) {
      case PlayState.welcome:
      case PlayState.gameOver:
      case PlayState.won:
        overlays.add(playState.name);
      case PlayState.playing:
        overlays.remove(PlayState.welcome.name);
        overlays.remove(PlayState.gameOver.name);
        overlays.remove(PlayState.won.name);
    }
  } // To here.

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(PlayArea());

    playState = PlayState.welcome; // TODO change htis
    final imagesLoader = Images();

    itemsIcons.addAll([
      await imagesLoader.load('can.png'),
      await imagesLoader.load('cartoon.png'),
      await imagesLoader.load('glass.png'),
      await imagesLoader.load('paper.png'),
      await imagesLoader.load('plastic.png'),
    ]);
    itemsTypes.addAll([
      ItemType.can,
      ItemType.cartoon,
      ItemType.glass,
      ItemType.paper,
      ItemType.plastic,
    ]);
    startGame();
  }

  void startGame() {
    if (playState == PlayState.playing) return;

    world.removeAll(world.children.query<Item>());

    playState = PlayState.playing; // To here.
    score.value = 0;
    List<Item> items = [];
    spacingX = (4 /* TODO make this as variable */ - 1) / 2;
    spacingY = (5 /* TODO make this as variable */ - 1) / 2;

    for (var y = 0; y < 5; y++) {
      for (var x = 0; x <= 4; x++) {
        // Vector2 position = Vector2(x - spacingX, y - spacingY);
        Vector2 position = Vector2(
          (x + 0.5) * itemSize + (x + 1) * itemGutter,
          (y + 2.0) * itemSize + y * itemGutter,
        );

        int randomItemIndex = rand.nextInt(itemsTypes.length);
        items.add(Item(
            image: itemsIcons[randomItemIndex],
            type: itemsTypes[randomItemIndex],
            xPos: x,
            yPos: y,
            currentPosition: position));
      }
    }

    world.addAll(items);
  } // Drop the debugMode

  // @override // Add from here...
  // void onTap() {
  //   super.onTap();
  //   startGame();
  // } // To here.

  // @override
  // KeyEventResult onKeyEvent(
  //     RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
  //   super.onKeyEvent(event, keysPressed);
  //   switch (event.logicalKey) {
  //     case LogicalKeyboardKey.arrowLeft:
  //       world.children.query<Bat>().first.moveBy(-batStep);
  //     case LogicalKeyboardKey.arrowRight:
  //       world.children.query<Bat>().first.moveBy(batStep);
  //     case LogicalKeyboardKey.space: // Add from here...
  //     case LogicalKeyboardKey.enter:
  //       startGame(); // To here.
  //   }
  //   return KeyEventResult.handled;
  // }
  // @override
  // Color backgroundColor() => const Color(0xfff2e8cf); // Add this override
}
