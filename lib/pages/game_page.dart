import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_game/src/config.dart';
// import 'package:google_fonts/google_fonts.dart';

import '../src/recycle_rush.dart';
import '../src/widgets/helps_widget.dart';
import '../src/widgets/overlay_screen.dart'; // Add this import
import '../src/widgets/header.dart'; // And this one too

class GamePage extends StatefulWidget {
  // Modify this line
  const GamePage({super.key});

  @override // Add from here...
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final RecycleRush game;
  final player = AudioPlayer();
  @override
  void initState() {
    super.initState();
    player.play(
      AssetSource('sounds/background_music.mp3'),
    );
    player.setReleaseMode(ReleaseMode.loop);

    game = RecycleRush();
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
    itemSize = (horizontalItemsCount > verticalItemsCount)
        ? (gameWidth - (itemGutter * verticalItemsCount)) / horizontalItemsCount
        : (gameWidth - (itemGutter * horizontalItemsCount)) /
            verticalItemsCount;

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
                      'assets/images/background-1.jpg',
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
