import 'dart:io';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_game/src/config.dart';

class HomePage extends StatefulWidget {
  // Modify this line
  const HomePage({super.key});

  @override // Add from here...
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final player = AudioPlayer();
  @override
  void initState() {
    super.initState();
    player.play(
      AssetSource('sounds/background_music.mp3'),
    );
    player.setReleaseMode(ReleaseMode.loop);
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
            decoration: BoxDecoration(
              color: Colors.red[200]!,
              // image: DecorationImage(
              //     fit: BoxFit.cover,
              //     image: AssetImage(
              //       'assets/images/background-1.jpg',
              //     )),
            ),
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                Expanded(
                    child: ListWheelScrollView(
                        scrollBehavior: MyCustomScrollBehavior()
                          ..copyWith(scrollbars: false), //TODO
                        itemExtent: 250,
                        squeeze: 1.1,

                        // clipBehavior: Clip.antiAlias,
                        // offAxisFraction: 1.05,
                        children: List.generate(
                          100,
                          (index) => SizedBox(
                            height: 200,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                ),
                                Image.asset('assets/images/rope.png'),
                                Expanded(child: Container()),
                                Image.asset('assets/images/rope.png'),
                                const SizedBox(
                                  width: 20,
                                ),
                              ],
                            ),
                          ),
                        )))
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
