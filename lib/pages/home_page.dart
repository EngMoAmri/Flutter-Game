import 'dart:io';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_game/game_src/config.dart';
import 'package:flutter_game/utlis/path_line.dart';

class HomePage extends StatefulWidget {
  // Modify this line
  const HomePage({super.key});

  @override // Add from here...
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final player = AudioPlayer();
  final scrollController = ScrollController();
  List<Widget> levels = [];
  @override
  void initState() {
    super.initState();
    player.play(
      AssetSource('sounds/background_music.mp3'),
    );
    player.setReleaseMode(ReleaseMode.loop);
  }

  Path drawPath(double width, bool left) {
    Size size = Size((width / 2), 200);
    Path path = Path();
    if (left) {
      path.moveTo(10, -100);
      path.quadraticBezierTo(-size.width / 2, 0, 0, 100);
    } else {
      path.moveTo(-10, -100);
      path.quadraticBezierTo(size.width / 2, 0, 0, 100);
    }
    return path;
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
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                // SizedBox(
                //   height: size.height / 2,
                // ),
                Expanded(
                  child: RotatedBox(
                    quarterTurns: 2,
                    child: ListWheelScrollView(
                        scrollBehavior: MyCustomScrollBehavior()
                          ..copyWith(scrollbars: false), //TODO
                        itemExtent: 200,
                        squeeze: 1.1,

                        // clipBehavior: Clip.antiAlias,
                        // offAxisFraction: 1.05,
                        children: List.generate(
                          100,
                          (index) => Container(
                            color:
                                (index % 2 == 0) ? Colors.green : Colors.yellow,
                            height: 200,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CustomPaint(
                                        painter: PathLine(drawPath(
                                            size.width, index % 2 == 0)),
                                      ),
                                      Positioned(
                                        // left: (index % 2 == 0) ? null : 100,
                                        // right: (index % 2 == 0) ? 100 : null,
                                        child: SizedBox(
                                          width: 80,
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: Card(
                                              elevation: 5.0,
                                              shape: RoundedRectangleBorder(
                                                  side: const BorderSide(
                                                      color: Colors.green,
                                                      width: 1.0),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0)),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                child: Center(
                                                  child: Text('1'),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}
