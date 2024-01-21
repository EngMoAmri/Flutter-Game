import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/src/config.dart';
import 'package:google_fonts/google_fonts.dart';

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
  } // To here.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.pressStart2pTextTheme().apply(
          bodyColor: const Color(0xff184e77),
          displayColor: const Color(0xff184e77),
        ),
      ),
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xffa9d6e5),
                Color(0xfff2e8cf),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Header(
                    goul: game.goul,
                    moves: game.moves,
                    points: game.points,
                  ),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: gameWidth,
                        height: gameWidth,
                        child: GameWidget(
                          game: game,
                          overlayBuilderMap: {
                            PlayState.welcome.name:
                                (context, RecycleRush game) => GestureDetector(
                                      onTap: () {
                                        game.startGame();
                                      },
                                      child: const OverlayScreen(
                                        title: 'TAP TO PLAY',
                                        subtitle: '',
                                      ),
                                    ),
                            PlayState.gameOver.name:
                                (context, RecycleRush game) => GestureDetector(
                                      onTap: () {
                                        game.startGame();
                                      },
                                      child: const OverlayScreen(
                                        title: 'G A M E   O V E R',
                                        subtitle: 'Tap to Play Again',
                                      ),
                                    ),
                            PlayState.won.name: (context, RecycleRush game) =>
                                GestureDetector(
                                  onTap: () {
                                    game.startGame();
                                  },
                                  child: const OverlayScreen(
                                    title: 'Y O U   W O N ! ! !',
                                    subtitle: 'Tap to Play Again',
                                  ),
                                ),
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ), // To here.
            ),
          ),
        ),
      ),
    );
  }
}
