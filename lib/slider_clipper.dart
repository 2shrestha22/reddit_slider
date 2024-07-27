import 'package:flutter/material.dart';

class SliderClipper extends CustomClipper<Rect> {
  SliderClipper({required this.position}) : invert = false;
  SliderClipper.inverted({required this.position}) : invert = true;

  final bool invert;
  final double position;

  @override
  Rect getClip(Size size) {
    final position = 1 - this.position;
    if (invert) {
      final dx = position * size.width;
      return Rect.fromLTRB(dx, 0, size.width, size.height);
    } else {
      final dx = position * size.width;
      return Rect.fromLTRB(0, 0, dx, size.height);
    }
  }

  @override
  bool shouldReclip(SliderClipper oldClipper) => true;
}
