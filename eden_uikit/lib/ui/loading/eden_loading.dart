import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

import 'flutter_easyloading/flutter_easyloading.dart';

class EdenLoading {
  static initialize() {
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorColor = EdenThemeBuilder.theme.toast.text
      ..indicatorType = EasyLoadingIndicatorType.circle
      ..indicatorSize = 20.w
      ..contentPadding = EdgeInsets.symmetric(vertical: 16.w, horizontal: 24.w)
      ..textPadding = EdgeInsets.only(right: 5.w)
      ..backgroundColor = EdenThemeBuilder.theme.toast.background
      ..radius = 8.w
      ..textColor = EdenThemeBuilder.theme.toast.text
      ..fontSize = 17.sp
      ..progressColor = EdenThemeBuilder.theme.primary
      ..progressWidth = 1.5.w
      ..boxShadow = [
        BoxShadow(
          blurRadius: 8.w,
          offset: Offset(0, 2.w),
          color:
              EdenThemeBuilder.theme.toast.background.invert.withOpacity(0.2),
        ),
      ]
      ..maskType = EasyLoadingMaskType.none
      ..userInteractions = false;
  }

  static TransitionBuilder init({
    TransitionBuilder? builder,
  }) {
    return (BuildContext context, Widget? child) {
      if (builder != null) {
        return builder(context, FlutterEasyLoading(child: child));
      } else {
        return FlutterEasyLoading(child: child);
      }
    };
  }

  static Future<void> show({
    String? msg,
    Widget? indicator,
    bool? dismissOnTap,
  }) {
    return EasyLoading.show(
      status: msg,
      indicator: indicator,
      dismissOnTap: dismissOnTap,
    );
  }

  static Future<void> showProgress(
    double value, {
    String? msg,
  }) async {
    EasyLoading.showProgress(
      value,
      status: msg,
    );
  }

  static Future<void> dismiss({
    bool animation = true,
  }) {
    return EasyLoading.dismiss(animation: animation);
  }
}
