import 'dart:io';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_game/game_src/config.dart';
import 'package:flutter_game/utlis/path_line.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:zwidget/zwidget.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  // Modify this line
  const HomePage({super.key});

  @override // Add from here...
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final player = AudioPlayer();
  final LinkedScrollControllerGroup controllers = LinkedScrollControllerGroup();

  late ScrollController scrollControllerRoute = controllers.addAndGet();
  late ScrollController scrollController3D = controllers.addAndGet();
  List<Widget> levels = [];
  @override
  void initState() {
    player.play(
      AssetSource('sounds/background_music.mp3'),
    );
    player.setReleaseMode(ReleaseMode.loop);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollControllerRoute
          .jumpTo(scrollControllerRoute.position.maxScrollExtent);
      scrollController3D.jumpTo(scrollController3D.position.maxScrollExtent);
    });
    super.initState();
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
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/sky.jpg'),
                    fit: BoxFit.cover)),
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: SizedBox(
                          height: size.height * 2 - 150,
                          child: ListWheelScrollView(
                              controller: scrollControllerRoute,
                              clipBehavior: Clip.hardEdge,
                              scrollBehavior: MyCustomScrollBehavior()
                                ..copyWith(scrollbars: false), //TODO
                              itemExtent: 200,
                              squeeze: 1.1,

                              // clipBehavior: Clip.antiAlias,
                              // offAxisFraction: 1.05,
                              children: List.generate(
                                100,
                                (index) => Container(
                                  decoration: const BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/asphalt.jpg'),
                                          fit: BoxFit.cover)),
                                  height: 200,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          alignment: Alignment.centerRight,
                                          children: [
                                            Center(
                                              child: CustomPaint(
                                                painter: PathLine(drawPath(
                                                    size.width,
                                                    index % 2 == 0)),
                                              ),
                                            ),
                                            SizedBox(
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
                                                      child: Text(
                                                          '${100 - index}'),
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
                      ),
                      SingleChildScrollView(
                        child: SizedBox(
                          height: size.height * 2 - 150,
                          child: ListWheelScrollView(
                            controller: scrollController3D,
                            clipBehavior: Clip.hardEdge,
                            scrollBehavior: MyCustomScrollBehavior()
                              ..copyWith(scrollbars: false), //TODO
                            itemExtent: 200,
                            squeeze: 1.1,
                            // perspective: 0.008,
                            // clipBehavior: Clip.antiAlias,
                            // offAxisFraction: 1.05,
                            children: List.generate(
                              100,
                              (index) => Row(
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/rocks.jpg'),
                                            fit: BoxFit.cover)),
                                    child: RotatedBox(
                                      quarterTurns: 2,
                                      child: Transform(
                                        transform: zMatrix4(
                                            xTilt:
                                                (math.pi / 2) - (math.pi / 6),
                                            yTilt: 0,
                                            zTranslation: 0,
                                            perspective: 0),
                                        child: RotatedBox(
                                          quarterTurns: 2,
                                          child: Image.asset(
                                              'assets/images/tree.png'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Container()),
                                  Container(
                                    decoration: const BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/rocks.jpg'),
                                            fit: BoxFit.cover)),
                                    child: RotatedBox(
                                      quarterTurns: 2,
                                      child: Transform(
                                        transform: zMatrix4(
                                            xTilt:
                                                (math.pi / 2) - (math.pi / 6),
                                            yTilt: 0,
                                            zTranslation: 0,
                                            perspective: 0),
                                        child: RotatedBox(
                                          quarterTurns: 2,
                                          child: Image.asset(
                                              'assets/images/tree.png'),
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
                    ],
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
