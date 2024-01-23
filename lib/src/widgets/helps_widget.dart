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

class _HelpsWidgetState extends State<HelpsWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange[300],
      // shape: const RoundedRectangleBorder(
      //   borderRadius: BorderRadius.only(
      //       bottomLeft: Radius.circular(20),
      //       bottomRight: Radius.circular(20)),
      // ),
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Hear is the place of help items')],
        ),
      ),
    );
  }
}
