import 'package:audioplayers/audioplayers.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/src/config.dart';
// import 'package:google_fonts/google_fonts.dart';

import '../recycle_rush.dart';
import 'overlay_screen.dart'; // Add this import
import 'header.dart'; // And this one too

class GameApp extends StatefulWidget {
  // Modify this line
  const GameApp({super.key});

  @override // Add from here...
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late final RecycleRush game;

  @override
  void initState() {
    super.initState();
    AudioPlayer().play(AssetSource('sounds/background_music.mp3'));

    game = RecycleRush();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    if (size.width < 532) {
      gameWidth = size.width - 32; // 32 is the padding
    } else {
      gameWidth = maxLength;
    }
    if (size.height < 532) {
      gameHeight = size.height - 32; // 32 is the padding
    } else {
      gameHeight = maxLength;
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
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    'assets/images/background.jpg',
                  ))),
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              Header(
                goul: game.goul,
                moves: game.moves,
                points: game.points,
                screenSize: size,
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: gameWidth,
                      height: gameHeight,
                      child: GameWidget(
                        game: game,
                        overlayBuilderMap: {
                          PlayState.loading.name: (context, RecycleRush game) =>
                              Center(
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
                                          game.startGame();
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
                                      game.startGame();
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
