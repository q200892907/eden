import 'package:eden_uikit/theme/eden_splash_factory.dart';
import 'package:eden_uikit/theme/eden_theme.dart';
import 'package:flutter/material.dart';

/// 主题拓展
extension ThemeContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  Color themeColor(Color lightColor, [Color? darkColor]) {
    return EdenThemeBuilder.isDark
        ? (darkColor ?? lightColor.invert)
        : lightColor;
  }
}

extension ThemeDataExtension on ThemeData {
  /// 关闭水波纹
  ThemeData get closeSplash => copyWith(
        splashColor: Colors.transparent, //关闭按钮类水波纹
        highlightColor: Colors.transparent, //关闭按钮类水波纹
        splashFactory: EdenSplashFactory(), //修改列表水波纹颜色
      );
}
