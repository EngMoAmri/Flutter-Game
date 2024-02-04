import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_game/aim_game_src/config.dart';

import '../aim_game_src/aim_game.dart';
// Add this import

class AimShootGamePage extends StatefulWidget {
  // Modify this line
  const AimShootGamePage({super.key});

  @override // Add from here...
  State<AimShootGamePage> createState() => _AimShootGamePageState();
}

class _AimShootGamePageState extends State<AimShootGamePage> {
  late final AimGame game;
  double zoom = 1;
  @override
  void initState() {
    super.initState();

    game = AimGame();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    screenWidth = size.width;
    screenHeight = size.height;
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
            //         image: AssetImage('assets/images/backgrounds/BG.png'),
            //         fit: BoxFit.cover)),
            margin: EdgeInsets.zero,
            child: SizedBox(
              width: screenWidth,
              height: screenHeight,
              child: Stack(
                children: [
                  GameWidget(
                    game: game,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 250,
                        width: 40,
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.black45,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16))),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 16,
                              ),
                              const Icon(
                                Icons.zoom_out,
                                color: Colors.white60,
                              ),
                              Expanded(
                                child: RotatedBox(
                                  quarterTurns: 1,
                                  child: Slider(
                                      value: zoom,
                                      activeColor: Colors.white60,
                                      min: minZoom,
                                      max: maxZoom,
                                      onChanged: (value) {
                                        game.camera.viewfinder.zoom = value;
                                        setState(() {
                                          zoom = value;
                                        });
                                      }),
                                ),
                              ),
                              const Icon(
                                Icons.zoom_in,
                                color: Colors.white60,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
