// The MIT License (MIT)
//
// Copyright (c) 2020 nslogx
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

class EasyLoadingProgress extends StatefulWidget {
  final double value;

  const EasyLoadingProgress({
    super.key,
    required this.value,
  });

  @override
  EasyLoadingProgressState createState() => EasyLoadingProgressState();
}

class EasyLoadingProgressState extends State<EasyLoadingProgress> {
  /// value of progress, should be 0.0~1.0.
  double _value = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateProgress(double value) {
    setState(() {
      _value = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: EasyLoadingTheme.indicatorSize,
      height: EasyLoadingTheme.indicatorSize,
      padding: const EdgeInsets.all(4),
      child: CustomPaint(
        painter: _CirclePainter(
          value: _value,
          color: EasyLoadingTheme.progressColor,
          width: EasyLoadingTheme.progressWidth,
        ),
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final Color color;
  final double value;
  final double width;

  _CirclePainter({
    required this.color,
    required this.value,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Offset.zero & size,
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) => value != oldDelegate.value;
}
