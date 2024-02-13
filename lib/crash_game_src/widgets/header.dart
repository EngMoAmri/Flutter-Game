import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_game/crash_game_src/components/item.dart';
import 'package:flutter_game/crash_game_src/widgets/stars_widgets.dart';

class Header extends StatefulWidget {
  const Header({
    super.key,
    required this.goul,
    required this.moves,
    required this.points,
    required this.externalGouls,
    required this.screenSize,
  });

  final ValueNotifier<int> goul;
  final ValueNotifier<int> moves;
  final ValueNotifier<int> points;
  final ValueNotifier<Map<GoulItem, int>> externalGouls;
  final Size screenSize;
  // TODO reset these on new game
  static bool star1Played = false;
  static bool star2Played = false;
  static bool star3Played = false;

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  Map<String, Map<String, Image>> itemsImagesMap = {};
  @override
  void initState() {
    itemsImagesMap.addAll({
      'can': {
        'none': Image.asset(
          'assets/images/items/can.png',
          width: 36,
        ),
        'col': Image.asset(
          'assets/images/items/can-col.png',
          width: 36,
        ),
        'row': Image.asset(
          'assets/images/items/can-row.png',
          width: 36,
        ),
        'square': Image.asset(
          'assets/images/items/can-square.png',
          width: 36,
        ),
      },
      'carton': {
        'none': Image.asset(
          'assets/images/items/carton.png',
          width: 36,
        ),
        'col': Image.asset(
          'assets/images/items/carton-col.png',
          width: 36,
        ),
        'row': Image.asset(
          'assets/images/carton-row.png',
          width: 36,
        ),
        'square': Image.asset(
          'assets/images/items/carton-square.png',
          width: 36,
        ),
      },
      'glass': {
        'none': Image.asset(
          'assets/images/items/glass.png',
          width: 36,
        ),
        'col': Image.asset(
          'assets/images/items/glass-col.png',
          width: 36,
        ),
        'row': Image.asset(
          'assets/images/items/glass-row.png',
          width: 36,
        ),
        'square': Image.asset(
          'assets/images/items/glass-square.png',
          width: 36,
        ),
      },
      'pan': {
        'none': Image.asset(
          'assets/images/items/pan.png',
          width: 36,
        ),
        'col': Image.asset(
          'assets/images/items/pan-col.png',
          width: 36,
        ),
        'row': Image.asset(
          'assets/images/items/pan-row.png',
          width: 36,
        ),
        'square': Image.asset(
          'assets/images/items/pan-square.png',
          width: 36,
        ),
      },
      'bottle': {
        'none': Image.asset(
          'assets/images/items/bottle.png',
          width: 36,
        ),
        'col': Image.asset(
          'assets/images/items/bottle-col.png',
          width: 36,
        ),
        'row': Image.asset(
          'assets/images/items/bottle-row.png',
          width: 36,
        ),
        'square': Image.asset(
          'assets/images/items/bottle-square.png',
          width: 36,
        ),
      },
      'superType': {
        'superType': Image.asset(
          'assets/images/items/grenade.png',
          width: 36,
        ),
      },
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 50,
          child: Row(
            children: [
              const SizedBox(
                width: 24,
              ),
              Image.asset('assets/images/items/rope.png'),
              Expanded(child: Container()),
              Image.asset('assets/images/items/rope.png'),
              const SizedBox(
                width: 24,
              ),
            ],
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Card(
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
              child: SizedBox(
                height: 180,
                child: ValueListenableBuilder<int>(
                  valueListenable: widget.moves,
                  builder: (context, moves, child) {
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '$moves',
                          style: TextStyle(
                            fontSize: widget.screenSize.width * 0.07,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown[600],
                            shadows: <Shadow>[
                              Shadow(
                                offset: const Offset(1.0, 1.2),
                                blurRadius: 1.0,
                                color: Colors.brown[200]!,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ]),
        Padding(
          padding: const EdgeInsets.only(top: 40, left: 4, right: 4),
          child: Card(
            // color: Colors.white70,
            elevation: 20,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0))),
            margin: EdgeInsets.zero,
            child: SizedBox(
              height: 100.0,
              child: Stack(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.asset(
                            'assets/images/backgrounds/wood-2.jpg',
                            fit: BoxFit.cover),
                      )),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
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
                                                Future.delayed(const Duration(
                                                        seconds: 1))
                                                    .then((value) {
                                                  Header.star1Played = true;
                                                  setState(() {});
                                                });

                                                return StarGifWidget(
                                                    screenSize:
                                                        widget.screenSize);
                                              } else if ((widget.points.value /
                                                          widget.goul.value) >=
                                                      0.33 &&
                                                  Header.star1Played) {
                                                return StarOnWidget(
                                                    screenSize:
                                                        widget.screenSize);
                                              } else {
                                                return StarOffWidget(
                                                    screenSize:
                                                        widget.screenSize);
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
                                                Future.delayed(const Duration(
                                                        seconds: 1))
                                                    .then((value) {
                                                  Header.star2Played = true;
                                                  setState(() {});
                                                });

                                                return StarGifWidget(
                                                    screenSize:
                                                        widget.screenSize);
                                              } else if ((widget.points.value /
                                                          widget.goul.value) >=
                                                      0.66 &&
                                                  Header.star2Played) {
                                                return StarOnWidget(
                                                    screenSize:
                                                        widget.screenSize);
                                              } else {
                                                return StarOffWidget(
                                                    screenSize:
                                                        widget.screenSize);
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
                                                Future.delayed(const Duration(
                                                        seconds: 1))
                                                    .then((value) {
                                                  Header.star3Played = true;
                                                  setState(() {});
                                                });

                                                return StarGifWidget(
                                                    screenSize:
                                                        widget.screenSize);
                                              } else if ((widget.points.value /
                                                          widget.goul.value) >=
                                                      1 &&
                                                  Header.star3Played) {
                                                return StarOnWidget(
                                                    screenSize:
                                                        widget.screenSize);
                                              } else {
                                                return StarOffWidget(
                                                    screenSize:
                                                        widget.screenSize);
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
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
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
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                              child: LinearProgressIndicator(
                                                value: points / goul,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        Colors.blue[500]!),
                                                backgroundColor:
                                                    Colors.transparent,
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Text(
                                              '$points',
                                              style: const TextStyle(
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
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: const EdgeInsets.all(16.0),
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
                          child: ValueListenableBuilder<Map<GoulItem, int>>(
                            valueListenable: widget.externalGouls,
                            builder: (context, externalGouls, child) {
                              return Padding(
                                padding: const EdgeInsets.all(8),
                                child: SizedBox(
                                    height: 35,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: externalGouls.keys
                                          .toList()
                                          .map((goulItem) => Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  itemsImagesMap[
                                                          goulItem.type.name]![
                                                      goulItem.powerType.name]!,
                                                  Text(
                                                    '${externalGouls[goulItem]}',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  )
                                                ],
                                              ))
                                          .toList(),
                                    )),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
