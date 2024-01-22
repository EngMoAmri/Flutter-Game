import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_game/src/widgets/stars_widgets.dart';

class Header extends StatefulWidget {
  const Header({
    super.key,
    required this.goul,
    required this.moves,
    required this.points,
    required this.screenSize,
  });

  final ValueNotifier<int> goul;
  final ValueNotifier<int> moves;
  final ValueNotifier<int> points;
  final Size screenSize;
  // TODO reset these on new game
  static bool star1Played = false;
  static bool star2Played = false;
  static bool star3Played = false;

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          color: Colors.white70,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20)),
          ),
          margin: EdgeInsets.zero,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: Container()),
                          ValueListenableBuilder<int>(
                              valueListenable: widget.goul,
                              builder: (context, goul, child) {
                                return ValueListenableBuilder<int>(
                                    valueListenable: widget.points,
                                    builder: (context, points, child) {
                                      // TODO different ratio for different level
                                      if ((widget.points.value /
                                                  widget.goul.value) >=
                                              0.33 &&
                                          !Header.star1Played) {
                                        Future.delayed(
                                                const Duration(seconds: 1))
                                            .then((value) {
                                          Header.star1Played = true;
                                          setState(() {});
                                        });

                                        return StarGifWidget(
                                            screenSize: widget.screenSize);
                                      } else if ((widget.points.value /
                                                  widget.goul.value) >=
                                              0.33 &&
                                          Header.star1Played) {
                                        return StarOnWidget(
                                            screenSize: widget.screenSize);
                                      } else {
                                        return StarOffWidget(
                                            screenSize: widget.screenSize);
                                      }
                                    });
                              }),
                          Expanded(child: Container()),
                          ValueListenableBuilder<int>(
                              valueListenable: widget.goul,
                              builder: (context, goul, child) {
                                return ValueListenableBuilder<int>(
                                    valueListenable: widget.points,
                                    builder: (context, points, child) {
                                      // TODO different ratio for different level
                                      if ((widget.points.value /
                                                  widget.goul.value) >=
                                              0.66 &&
                                          !Header.star2Played) {
                                        Future.delayed(
                                                const Duration(seconds: 1))
                                            .then((value) {
                                          Header.star2Played = true;
                                          setState(() {});
                                        });

                                        return StarGifWidget(
                                            screenSize: widget.screenSize);
                                      } else if ((widget.points.value /
                                                  widget.goul.value) >=
                                              0.66 &&
                                          Header.star2Played) {
                                        return StarOnWidget(
                                            screenSize: widget.screenSize);
                                      } else {
                                        return StarOffWidget(
                                            screenSize: widget.screenSize);
                                      }
                                    });
                              }),
                          Expanded(child: Container()),
                          ValueListenableBuilder<int>(
                              valueListenable: widget.goul,
                              builder: (context, goul, child) {
                                return ValueListenableBuilder<int>(
                                    valueListenable: widget.points,
                                    builder: (context, points, child) {
                                      // TODO different ratio for different level
                                      if ((widget.points.value /
                                                  widget.goul.value) >=
                                              1 &&
                                          !Header.star3Played) {
                                        Future.delayed(
                                                const Duration(seconds: 1))
                                            .then((value) {
                                          Header.star3Played = true;
                                          setState(() {});
                                        });

                                        return StarGifWidget(
                                            screenSize: widget.screenSize);
                                      } else if ((widget.points.value /
                                                  widget.goul.value) >=
                                              1 &&
                                          Header.star3Played) {
                                        return StarOnWidget(
                                            screenSize: widget.screenSize);
                                      } else {
                                        return StarOffWidget(
                                            screenSize: widget.screenSize);
                                      }
                                    });
                              }),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ValueListenableBuilder<int>(
                        valueListenable: widget.goul,
                        builder: (context, goul, child) {
                          return ValueListenableBuilder<int>(
                            valueListenable: widget.points,
                            builder: (context, points, child) {
                              return Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  Container(
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black38,
                                        ),
                                        BoxShadow(
                                          color: Colors.brown,
                                          spreadRadius: -12.0,
                                          blurRadius: 12.0,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      child: LinearProgressIndicator(
                                        value: points / goul,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.blue[500]!),
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      '$points',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  )
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: Container()),
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38,
                      ),
                      BoxShadow(
                        color: Colors.brown,
                        spreadRadius: -16.0,
                        blurRadius: 40.0,
                      ),
                    ],
                  ),
                  child: ValueListenableBuilder<int>(
                    valueListenable: widget.points,
                    builder: (context, points, child) {
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: SingleChildScrollView(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/can.png',
                                width: 36,
                              ),
                              Text(
                                '5',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(children: [
          Expanded(
            flex: 2,
            child: Container(),
          ),
          Expanded(
            child: Card(
              elevation: 10,
              color: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
              ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: ValueListenableBuilder<int>(
                  valueListenable: widget.moves,
                  builder: (context, moves, child) {
                    return SizedBox(
                      height: 85,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            '$moves',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(1.0, 1.2),
                                  blurRadius: 1.0,
                                  color: Colors.brown[800]!,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(),
          ),
        ])
      ],
    );
  }
}
