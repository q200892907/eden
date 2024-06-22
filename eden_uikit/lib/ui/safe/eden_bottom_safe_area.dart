import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

export 'eden_top_safe_area.dart';

/// 用于底部安全区域控件
class EdenBottomSafeArea extends StatelessWidget {
  final Widget child;
  final Color? color;

  const EdenBottomSafeArea({super.key, this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: EdgeInsets.only(bottom: ScreenUtil().bottomBarHeight),
      child: child,
    );
  }
}
