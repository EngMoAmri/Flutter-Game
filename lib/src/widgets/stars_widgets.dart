import 'package:flutter/material.dart';

class StarOffWidget extends StatelessWidget {
  const StarOffWidget({super.key, required this.screenSize});
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/star.png',
      color: Colors.black54,
      opacity: const AlwaysStoppedAnimation(0.6),
      width: (screenSize.width > 480) ? 32 : screenSize.width * 0.067,
    );
  }
}

class StarGifWidget extends StatelessWidget {
  const StarGifWidget({super.key, required this.screenSize});
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/star.gif',
      width: (screenSize.width > 480) ? 32 : screenSize.width * 0.067,
    );
  }
}

class StarOnWidget extends StatelessWidget {
  const StarOnWidget({super.key, required this.screenSize});
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/star.png',
      width: (screenSize.width > 480) ? 32 : screenSize.width * 0.067,
    );
  }
}
