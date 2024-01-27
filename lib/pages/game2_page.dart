import 'dart:io';

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_game/game2_src/config.dart';

import '../game2_src/game2.dart';
// Add this import

class Game2Page extends StatefulWidget {
  // Modify this line
  const Game2Page({super.key});

  @override // Add from here...
  State<Game2Page> createState() => _Game2PageState();
}

class _Game2PageState extends State<Game2Page> {
  late final Game2 game;
  @override
  void initState() {
    super.initState();

    game = Game2();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    gameWidth = size.width - 8; // 8 is the padding
    gameHeight = size.height - 8; // 8 is the padding
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
            // decoration: const BoxDecoration(
            //     image: DecorationImage(
            //         fit: BoxFit.cover,
            //         image: AssetImage(
            //           'assets/images/backgrounds/background-1.jpg',
            //         ))),
            margin: EdgeInsets.zero,
            child: SizedBox(
              width: gameWidth,
              height: gameHeight,
              child: GameWidget(
                game: game,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
