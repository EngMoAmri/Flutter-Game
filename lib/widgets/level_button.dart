import 'package:flutter/material.dart';

class LevelButton extends StatefulWidget {
  const LevelButton({super.key, required this.index});
  final int index;
  @override
  State<LevelButton> createState() => _LevelButtonState();
}

class _LevelButtonState extends State<LevelButton>
    with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      child: Transform.scale(
        scale: _scale,
        child: _animatedButtonUI,
      ),
    );
  }

  Widget get _animatedButtonUI => Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(100)),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
            ),
            BoxShadow(
              color: Colors.green,
              spreadRadius: -5.0,
              blurRadius: 10.0,
            ),
          ],
        ),
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: Card(
              elevation: 20.0,
              shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.green, width: 1.0),
                  borderRadius: BorderRadius.circular(100.0)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: Center(
                  child: Text('${100 - widget.index}'),
                ),
              ),
            ),
          ),
        ),
      );
}
