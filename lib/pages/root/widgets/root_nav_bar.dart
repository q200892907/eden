import 'package:flutter/material.dart';

class FloatingButtonCustomLocation extends FloatingActionButtonLocation {
  FloatingActionButtonLocation location;
  final double offsetX; // X方向的偏移量
  final double offsetY; // Y方向的偏移量
  FloatingButtonCustomLocation(this.location,
      {this.offsetX = 0, this.offsetY = 0});

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    Offset offset = location.getOffset(scaffoldGeometry);
    return Offset(offset.dx + offsetX, offset.dy + offsetY);
  }
}

class FloatingActionButtonCustomAnimator extends FloatingActionButtonAnimator {
  const FloatingActionButtonCustomAnimator();

  @override
  Offset getOffset(
      {required Offset begin, required Offset end, required double progress}) {
    if (progress < 0.5) {
      return begin;
    } else {
      return end;
    }
  }

  @override
  Animation<double> getScaleAnimation({required Animation<double> parent}) {
    return Tween<double>(begin: 1, end: 1).animate(parent);
  }

  @override
  Animation<double> getRotationAnimation({required Animation<double> parent}) {
    return Tween<double>(begin: 1, end: 1).animate(parent);
  }
}
