import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 用于顶部安全区域控件
class EdenTopSafeArea extends StatelessWidget {
  final Widget child;
  final Color? color;

  const EdenTopSafeArea({super.key, this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
      child: child,
    );
  }
}
