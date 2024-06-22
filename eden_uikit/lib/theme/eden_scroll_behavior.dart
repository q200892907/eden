import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 关闭列表水波纹
class EdenScrollBehavior extends ScrollBehavior {
  final List<PointerDeviceKind> customDragDevices;

  factory EdenScrollBehavior.system() {
    return const EdenScrollBehavior(customDragDevices: []);
  }

  const EdenScrollBehavior({
    this.customDragDevices = const [
      PointerDeviceKind.mouse,
      PointerDeviceKind.touch,
    ],
  });

  @override
  Set<PointerDeviceKind> get dragDevices => {
        ...super.dragDevices,
        ...customDragDevices,
      };

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return Scrollbar(
      controller: details.controller,
      child: child,
    );
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    switch (getPlatform(context)) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return GlowingOverscrollIndicator(
          showLeading: false,
          //不显示尾部水波纹
          showTrailing: false,
          axisDirection: details.direction,
          color: Theme.of(context).background.withOpacity(0.01),
          child: child,
        );
      default:
        return super.buildOverscrollIndicator(context, child, details);
    }
  }
}
