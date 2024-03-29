import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_game/crash_game_src/config.dart';
import 'package:flutter_game/utlis/levels.dart';

import '../crash_game_src/recycle_rush.dart';
import '../crash_game_src/widgets/helps_widget.dart';
import '../crash_game_src/widgets/overlay_screen.dart'; // Add this import
import '../crash_game_src/widgets/header.dart'; // And this one too

class CrashGamePage extends StatefulWidget {
  // Modify this line
  const CrashGamePage({super.key, required this.level});
  final int level;
  @override // Add from here...
  State<CrashGamePage> createState() => _CrashGamePageState();
}

class _CrashGamePageState extends State<CrashGamePage> {
  late final RecycleRush game;
  final player = AudioPlayer();
  @override
  void initState() {
    super.initState();
    player.play(
      AssetSource('sounds/background_music.mp3'),
    );
    player.setReleaseMode(ReleaseMode.loop);
    game = RecycleRush(levelCatelog: levels[widget.level - 1]);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows || kIsWeb) {
      if (size.width > 550) {
        size = Size(550, size.height);
      }
    }

    if (size.width < 508) {
      gameWidth = size.width - 8; // 8 is the padding
    } else {
      gameWidth = maxLength;
    }
    if (size.height < 708) {
      gameHeight = size.height - 308; // 8 is the padding
    } else {
      gameHeight = maxLength;
    }
    // make it square
    if (gameHeight > gameWidth) {
      gameHeight = gameWidth;
    } else {
      gameWidth = gameHeight;
    }
    itemGutter = gameWidth * itemGutterRatio;
    itemSize = (game.levelCatelog.horizontalItemsCount >
            game.levelCatelog.verticalItemsCount)
        ? (gameWidth - (itemGutter * game.levelCatelog.verticalItemsCount)) /
            game.levelCatelog.horizontalItemsCount
        : (gameWidth - (itemGutter * game.levelCatelog.horizontalItemsCount)) /
            game.levelCatelog.verticalItemsCount;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(
                      'assets/images/backgrounds/background.png',
                    ))),
            margin: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: size.width,
                  child: Column(
                    children: [
                      Header(
                        goul: game.goulPoints,
                        moves: game.moves,
                        points: game.points,
                        externalGouls: game.externalGouls,
                        screenSize: size,
                      ),
                      Expanded(flex: 2, child: Container()),
                      SizedBox(
                        width: gameWidth,
                        height: gameHeight,
                        child: GameWidget(
                          game: game,
                          overlayBuilderMap: {
                            PlayState.loading.name:
                                (context, RecycleRush game) => Center(
                                      child: SizedBox(
                                        width: gameWidth,
                                        height: gameHeight,
                                        child: const OverlayScreen(
                                          title: 'Loading',
                                          subtitle: '',
                                        ),
                                      ),
                                    ),
                            PlayState.gameOver.name:
                                (context, RecycleRush game) => Center(
                                      child: SizedBox(
                                        width: gameWidth,
                                        height: gameHeight,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {});
                                            game.boardController.startGame();
                                          },
                                          child: const OverlayScreen(
                                            title: 'G A M E   O V E R',
                                            subtitle: 'Tap to Play Again',
                                          ),
                                        ),
                                      ),
                                    ),
                            PlayState.won.name: (context, RecycleRush game) =>
                                Center(
                                  child: SizedBox(
                                    width: gameWidth,
                                    height: gameHeight,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {});
                                        game.boardController.startGame();
                                      },
                                      child: const OverlayScreen(
                                        title: 'Y O U   W O N ! ! !',
                                        subtitle: 'Tap to Play Again',
                                      ),
                                    ),
                                  ),
                                ),
                          },
                        ),
                      ),
                      Expanded(flex: 3, child: Container()),
                      HelpsWidget(
                        screenSize: size,
                      ),
                      // Expanded(child: Container()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
