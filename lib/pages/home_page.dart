import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_game/pages/crash_game_page.dart';
import 'package:flutter_game/utlis/fancy_button.dart';
import 'package:flutter_game/utlis/levels.dart';
import 'package:flutter_game/utlis/path_line.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

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
  // this coz the trees flips so I added this and stack to avoid this problem
  late ScrollController scrollController3D2 = controllers.addAndGet();
  var horizontalScrollController =
      ScrollController(); // this is to make the whel scroll view width exceed the screen width
  List<Color> levelsColors = [
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.white,
    Colors.brown,
  ];
  List<String> trees = [
    'assets/images/trees/tree-1.png',
    'assets/images/trees/tree-2.png',
    'assets/images/trees/tree-3.png',
    'assets/images/trees/tree-4.png',
    'assets/images/trees/tree-5.png',
    'assets/images/trees/tree-6.png',
    'assets/images/trees/tree-7.png',
    'assets/images/trees/tree-8.png',
  ];
  List<String> trashes = [
    'assets/images/trashes/trash-1.png',
    'assets/images/trashes/trash-2.png',
    'assets/images/trashes/trash-3.png',
    'assets/images/trashes/trash-4.png',
  ];
  var rand = math.Random();
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
      scrollController3D2.jumpTo(scrollController3D2.position.maxScrollExtent);

      // this will scroll to the middle
      horizontalScrollController
          .jumpTo(horizontalScrollController.position.maxScrollExtent / 2);
    });
    super.initState();
  }

  Path drawPath(double width, bool left) {
    Size size = Size((width / 2), 200);
    Path path = Path();
    if (left) {
      path.moveTo(15, -104);
      path.quadraticBezierTo(-size.width / 2, 0, 0, 100);
    } else {
      path.moveTo(-15, -104);
      path.quadraticBezierTo(size.width / 2, 0, 0, 100);
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // this will scroll to the middle
      horizontalScrollController
          .jumpTo(horizontalScrollController.position.maxScrollExtent / 2);
    });

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
                    image:
                        AssetImage('assets/images/backgrounds/background.png'),
                    fit: BoxFit.cover)),
            child: Row(
              children: [
                Expanded(
                    child: Container(
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                              'assets/images/backgrounds/wood-2.jpg'),
                          fit: BoxFit.cover)),
                )),
                SizedBox(
                  width: (size.width > 400) ? 400 : size.width,
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned(
                                top: 10,
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/clouds/cloud-1.png',
                                      width: 200,
                                    ),
                                    Image.asset(
                                      'assets/images/clouds/cloud-2.png',
                                      width: 200,
                                    ),
                                    // TODO animate clouds
                                  ],
                                )),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(),
                              controller: horizontalScrollController,
                              child: Container(
                                margin: EdgeInsets.zero,
                                width: 600,
                                child: SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: Stack(
                                    children: [
                                      SizedBox(
                                        height: size.height * 2 - 150,
                                        child: ListWheelScrollView(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            controller: scrollControllerRoute,
                                            clipBehavior: Clip.hardEdge,
                                            scrollBehavior:
                                                MyCustomScrollBehavior()
                                                  ..copyWith(
                                                      scrollbars: false), //TODO
                                            itemExtent: 200,
                                            squeeze: 1.1,

                                            // clipBehavior: Clip.antiAlias,
                                            // offAxisFraction: 1.05,
                                            children: List.generate(
                                              100,
                                              (index) => Container(
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                    colors: [
                                                      Color(0xFF474747),
                                                      Color(0xFF2f2f2f),
                                                    ],
                                                  ),
                                                ),
                                                height: 200,
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                        width: 180,
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              begin: Alignment
                                                                  .centerLeft,
                                                              end: Alignment
                                                                  .centerRight,
                                                              colors: [
                                                                Color(
                                                                    0xFF474747),
                                                                Color.fromARGB(
                                                                    255,
                                                                    111,
                                                                    173,
                                                                    139),
                                                              ],
                                                            ),
                                                          ),
                                                          height: 200,
                                                        )),
                                                    Column(
                                                      children: [
                                                        Expanded(
                                                          child: Card(
                                                            elevation: 10,
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 4),
                                                            child: Container(
                                                              color:
                                                                  Colors.black,
                                                              width: 10,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Card(
                                                            elevation: 10,
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 4),
                                                            child: Container(
                                                              color:
                                                                  Colors.yellow,
                                                              width: 10,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Center(
                                                        child: CustomPaint(
                                                          painter: PathLine(
                                                              drawPath(
                                                                  400,
                                                                  index % 2 ==
                                                                      0)),
                                                        ),
                                                      ),
                                                    ),
                                                    Column(
                                                      children: [
                                                        Expanded(
                                                          child: Card(
                                                            elevation: 10,
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 4),
                                                            child: Container(
                                                              color:
                                                                  Colors.black,
                                                              width: 10,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Card(
                                                            elevation: 10,
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 4),
                                                            child: Container(
                                                              color:
                                                                  Colors.yellow,
                                                              width: 10,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                        width: 180,
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              begin: Alignment
                                                                  .centerLeft,
                                                              end: Alignment
                                                                  .centerRight,
                                                              colors: [
                                                                Color.fromARGB(
                                                                    255,
                                                                    111,
                                                                    173,
                                                                    139),
                                                                Color(
                                                                    0xFF474747),
                                                              ],
                                                            ),
                                                          ),
                                                          height: 200,
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            )),
                                      ),
                                      SizedBox(
                                          height: size.height * 2 - 150,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: ListWheelScrollView(
                                                  physics:
                                                      const BouncingScrollPhysics(),
                                                  controller:
                                                      scrollController3D,
                                                  clipBehavior: Clip.hardEdge,
                                                  scrollBehavior:
                                                      MyCustomScrollBehavior()
                                                        ..copyWith(
                                                            scrollbars:
                                                                false), //TODO
                                                  itemExtent: 200,
                                                  squeeze: 1.1,
                                                  children: List.generate(100,
                                                      (index) {
                                                    return Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 60,
                                                        ),
                                                        RotatedBox(
                                                          quarterTurns: 2,
                                                          child: Transform(
                                                            transform: Matrix4
                                                                .rotationX((math
                                                                            .pi /
                                                                        2) -
                                                                    (math.pi /
                                                                        6)),
                                                            child: RotatedBox(
                                                              quarterTurns: 2,
                                                              child:
                                                                  Image.asset(
                                                                trees[rand
                                                                    .nextInt(
                                                                        8)],
                                                                width: 130,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                            child: Row(
                                                          mainAxisAlignment: ((index +
                                                                          1) %
                                                                      2 ==
                                                                  0)
                                                              ? MainAxisAlignment
                                                                  .start
                                                              : MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            RotatedBox(
                                                              quarterTurns: 2,
                                                              child: Transform(
                                                                transform: Matrix4
                                                                    .rotationX((math.pi /
                                                                            2) -
                                                                        (math.pi /
                                                                            5)),
                                                                child:
                                                                    RotatedBox(
                                                                  quarterTurns:
                                                                      2,
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            110),
                                                                    child: Image
                                                                        .asset(
                                                                      trashes[rand
                                                                          .nextInt(
                                                                              4)],
                                                                      width:
                                                                          130,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                        RotatedBox(
                                                          quarterTurns: 2,
                                                          child: Transform(
                                                            transform: Matrix4
                                                                .rotationX((math
                                                                            .pi /
                                                                        2) -
                                                                    (math.pi /
                                                                        5)),
                                                            child: RotatedBox(
                                                              quarterTurns: 2,
                                                              child:
                                                                  Image.asset(
                                                                trees[rand
                                                                    .nextInt(
                                                                        8)],
                                                                width: 130,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 60,
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                                ),
                                              )
                                            ],
                                          )),
                                      SizedBox(
                                          height: size.height * 2 - 150,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: ListWheelScrollView(
                                                  physics:
                                                      const BouncingScrollPhysics(),
                                                  controller:
                                                      scrollController3D2,
                                                  clipBehavior: Clip.hardEdge,
                                                  scrollBehavior:
                                                      MyCustomScrollBehavior()
                                                        ..copyWith(
                                                            scrollbars:
                                                                false), //TODO
                                                  itemExtent: 200,
                                                  squeeze: 1.1,
                                                  children: List.generate(100,
                                                      (index) {
                                                    return Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 200,
                                                        ),
                                                        Expanded(
                                                          child: Center(
                                                            child: Padding(
                                                                padding: (index %
                                                                            2 !=
                                                                        0)
                                                                    ? const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            100)
                                                                    : const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            100),
                                                                child: FancyButton(
                                                                    size: 80,
                                                                    color: levelsColors[index % levelsColors.length],
                                                                    onPressed: () {
                                                                      var level =
                                                                          100 -
                                                                              index;
                                                                      if (level <=
                                                                          levels
                                                                              .length) {
                                                                        // TODO aiminng game
                                                                        Get.to(() =>
                                                                            CrashGamePage(
                                                                              level: level,
                                                                            ));
                                                                      } else {
                                                                        Get.snackbar(
                                                                            "Attention",
                                                                            'Level not ready');
                                                                      }
                                                                    },
                                                                    child: Text('${100 - index}'))
                                                                // LevelButton(
                                                                //     index: index),
                                                                ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 200,
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                                ),
                                              )
                                            ],
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                                top: 20,
                                left: 10,
                                child: FancyButton(
                                    size: 25,
                                    color: Colors.redAccent,
                                    onPressed: () {
                                      // TODO mute sound
                                    },
                                    child: const Icon(Icons.audiotrack))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Container(
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                              'assets/images/backgrounds/wood-2.jpg'),
                          fit: BoxFit.cover)),
                )),
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
