import 'dart:math';

import 'package:flutter/material.dart';

class RotatedContainer extends StatelessWidget {
  const RotatedContainer({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -8 * pi / 180,
      child: Container(
        margin: EdgeInsets.only(bottom: height * 0.04),
        padding: EdgeInsets.symmetric(
            vertical: height * 0.005, horizontal: width * 0.1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.deepOrange.shade900,
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black26,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          "Loading...",
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontSize: 50,
            fontFamily: "Anton",
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
