import 'package:flutter/material.dart';

class HelpsWidget extends StatefulWidget {
  const HelpsWidget({
    super.key,
    required this.screenSize,
  });
  final Size screenSize;

  @override
  State<HelpsWidget> createState() => _HelpsWidgetState();
}

// TODO
class _HelpsWidgetState extends State<HelpsWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 4, right: 4),
      child: Card(
        elevation: 20,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        margin: EdgeInsets.zero,
        child: SizedBox(
          height: 80.0,
          child: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                      child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.asset('assets/images/wood-1.jpg',
                        fit: BoxFit.cover),
                  )),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Card(
                              elevation: 5.0,
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: Colors.green, width: 1.0),
                                  borderRadius: BorderRadius.circular(100.0)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: Center(
                                    child: Image.asset(
                                        'assets/images/grenade.png')),
                              ),
                            ),
                          ),
                          AspectRatio(
                            aspectRatio: 1,
                            child: Card(
                              elevation: 5.0,
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: Colors.green, width: 1.0),
                                  borderRadius: BorderRadius.circular(100.0)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: Center(
                                    child: Image.asset(
                                        'assets/images/destroy-hammer.png')),
                              ),
                            ),
                          ),
                          AspectRatio(
                            aspectRatio: 1,
                            child: Card(
                              elevation: 5.0,
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: Colors.green, width: 1.0),
                                  borderRadius: BorderRadius.circular(100.0)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: Center(
                                    child: Image.asset(
                                        'assets/images/move-hand.png')),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
