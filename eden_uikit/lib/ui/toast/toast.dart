import 'dart:io';

import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

///
/// Toast基类
///
abstract class ToastBaseWidget extends StatelessWidget {
  const ToastBaseWidget({
    super.key,
    required this.msg,
    required this.radius,
    this.backgroundColor,
    required this.fontSize,
    this.textColor,
  });

  static final double kRadius = 8.w;
  static final double kFontSize = 13.sp;
  static final double kHorizontalMargin = 60.w;

  final String msg;
  final double? radius;
  final Color? backgroundColor;
  final double? fontSize;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final double r = radius ?? kRadius;
    final Color bgColor =
        backgroundColor ?? EdenThemeBuilder.theme.toast.background;
    final double fs = fontSize ?? kFontSize;
    final Color color = textColor ?? EdenThemeBuilder.theme.toast.text;
    final double fontHeight = Platform.isIOS ? 1.5 : 1.3;
    return buildToastWidget(
      radius: r,
      backgroundColor: bgColor,
      fontSize: fs,
      textColor: color,
      fontHeight: fontHeight,
    );
  }

  /// 构建Toast样式
  Widget buildToastWidget({
    required double radius,
    required Color backgroundColor,
    required double fontSize,
    required Color textColor,
    required double fontHeight,
  });
}
