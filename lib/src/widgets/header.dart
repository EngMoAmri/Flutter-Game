import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.goul,
    required this.moves,
    required this.points,
  });

  final ValueNotifier<int> goul;
  final ValueNotifier<int> moves;
  final ValueNotifier<int> points;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          color: Colors.green[400],
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
                          Image.asset('assets/icons/star_off.png', width: 36),
                          Expanded(child: Container()),
                          Image.asset('assets/icons/star_on.png', width: 36),
                          Expanded(child: Container()),
                          Image.asset('assets/icons/star.gif', width: 36),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ValueListenableBuilder<int>(
                        valueListenable: goul,
                        builder: (context, goul, child) {
                          return ValueListenableBuilder<int>(
                            valueListenable: points,
                            builder: (context, points, child) {
                              return Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  Container(
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black38,
                                        ),
                                        BoxShadow(
                                          color: Colors.greenAccent,
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
                                                Colors.blue),
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
                        color: Colors.greenAccent,
                        spreadRadius: -16.0,
                        blurRadius: 40.0,
                      ),
                    ],
                  ),
                  child: ValueListenableBuilder<int>(
                    valueListenable: points,
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
              color: Colors.green[300],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(60)),
              ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: ValueListenableBuilder<int>(
                  valueListenable: moves,
                  builder: (context, moves, child) {
                    return SizedBox(
                      height: 95,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Text(
                            '$moves',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900]),
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
