import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

import 'toast.dart';

class EdenToast {
  static int? _lastToastTime;
  static String? _lastToastText;

  /// 操作注意事项提醒Toast —— 普通Toast
  static void show(
    String? msg, {
    EdenToastType type = EdenToastType.normal,
    EdenToastIconPosition position = EdenToastIconPosition.left, //仅移动端生效
    int duration = 2000,
  }) {
    if (msg == null || msg.isEmpty || msg.trim() == '') {
      return;
    }

    // 如果是重复文案，且旧的toast并未消失，那么，不再显示新的Toast
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (_lastToastText == msg &&
        _lastToastTime != null &&
        now - _lastToastTime! < duration) {
      return;
    }

    _lastToastText = msg;
    _lastToastTime = now;

    final Widget widget = EdenMobileToast(
      msg: msg,
      type: type,
      position: position,
    );

    showToastWidget(
      widget,
      duration: Duration(milliseconds: duration),
      position: ToastPosition.center,
      dismissOtherToast: true,
    );
  }

  /// 成功Toast
  static void success(
    String? msg, {
    EdenToastIconPosition position = EdenToastIconPosition.left,
  }) {
    show(msg, type: EdenToastType.success, position: position);
  }

  /// 失败Toast
  static void failed(
    String? msg, {
    EdenToastIconPosition position = EdenToastIconPosition.left,
  }) {
    show(msg, type: EdenToastType.fail, position: position);
  }

  // 警告Toast
  static void warning(
    String? msg, {
    EdenToastIconPosition position = EdenToastIconPosition.left,
  }) {
    show(msg, type: EdenToastType.warn, position: position);
  }

  static void cancelToast() {
    dismissAllToast();
  }
}

enum EdenToastType {
  normal, //正常，无图
  success, //成功
  fail, //失败
  warn, //警告
}

enum EdenToastIconPosition {
  top,
  left,
}

class EdenMobileToast extends ToastBaseWidget {
  EdenMobileToast({
    super.key,
    required super.msg,
    required this.type,
    this.position = EdenToastIconPosition.top,
  }) : super(
          radius: 8.w,
          fontSize: 17.sp,
        );

  final EdenToastType type;
  final EdenToastIconPosition position;

  @override
  Widget buildToastWidget({
    required double radius,
    required Color backgroundColor,
    required double fontSize,
    required Color textColor,
    required double fontHeight,
  }) {
    Widget text = Text(
      msg,
      textAlign: TextAlign.start,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
        leadingDistribution: TextLeadingDistribution.even,
        height: fontHeight,
      ),
    );
    //todo 是否fail与warn使用normal样式
    if (type == EdenToastType.normal ||
        type == EdenToastType.fail ||
        type == EdenToastType.warn) {
      return Container(
        margin:
            EdgeInsets.symmetric(horizontal: ToastBaseWidget.kHorizontalMargin),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 2.w),
              blurRadius: 8.w,
              color: backgroundColor.invert.withOpacity(0.2),
            ),
          ],
        ),
        child: text,
      );
    }
    // String assets = type == EdenToastType.success
    //     ? R.libAssetsIconsToastSuccessMobile
    //     : type == EdenToastType.fail
    //         ? R.libAssetsIconsToastFail //todo
    //         : R.libAssetsIconsToastWarn; //todo
    if (position == EdenToastIconPosition.left) {
      return Container(
        margin:
            EdgeInsets.symmetric(horizontal: ToastBaseWidget.kHorizontalMargin),
        child: Container(
          constraints: BoxConstraints(minWidth: 183.w, minHeight: 56.w),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: backgroundColor,
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 2.w),
                blurRadius: 8.w,
                color: backgroundColor.invert.withOpacity(0.2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // ZhiyaImage.loadAssetImage(assets,
              //     width: 20.w,
              //     height: 20.w,
              //     package: ZhiyaUikit.package,
              //     color: textColor),
              // SizedBox(width: 5.w),
              Flexible(child: text),
            ],
          ),
        ),
      );
    }
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: ToastBaseWidget.kHorizontalMargin),
      child: Container(
        constraints: BoxConstraints(minWidth: 181.w, minHeight: 136.w),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 2.w),
              blurRadius: 8.w,
              color: backgroundColor.invert.withOpacity(0.2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // ZhiyaImage.loadAssetImage(
            //   assets,
            //   width: 20.w,
            //   height: 20.w,
            //   package: ZhiyaUikit.package,
            //   color: textColor,
            // ),
            // SizedBox(height: 5.w),
            text
          ],
        ),
      ),
    );
  }
}
