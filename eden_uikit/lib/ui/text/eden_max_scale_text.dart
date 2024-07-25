import 'package:flutter/material.dart';

/// 控制字体缩放
class EdenMaxScaleText extends StatelessWidget {
  const EdenMaxScaleText({
    super.key,
    this.max = 1,
    required this.child,
  });

  final double max;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData data = MediaQuery.of(context);
    return MediaQuery(
      data: data.copyWith(textScaler: TextScaler.linear(max)),
      child: child,
    );
  }
}
