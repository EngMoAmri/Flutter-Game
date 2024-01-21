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
    game = RecycleRush();
  }

  // TODO fit height
  @override
  Widget build(BuildContext context) {
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
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: gameWidth,
                      height: gameWidth,
                      child: GameWidget(
                        game: game,
                        overlayBuilderMap: {
                          PlayState.welcome.name: (context, RecycleRush game) =>
                              Center(
                                child: SizedBox(
                                  width: gameWidth,
                                  height: gameWidth,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {});
                                      game.startGame();
                                    },
                                    child: const OverlayScreen(
                                      title: 'TAP TO PLAY',
                                      subtitle: '',
                                    ),
                                  ),
                                ),
                              ),
                          PlayState.gameOver.name:
                              (context, RecycleRush game) => Center(
                                    child: SizedBox(
                                      width: gameWidth,
                                      height: gameWidth,
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
                                  height: gameWidth,
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
