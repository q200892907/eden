import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

export 'package:textstyle_extensions/textstyle_extensions.dart';

export 'num_extension.dart';
export 'route_context_extension.dart';
export 'string_extension.dart';
export 'theme_extension.dart';

/// 空widget
class EdenEmpty {
  /// 普通的空Widget
  static const Widget ui = SizedBox.shrink();

  /// Sliver中的空Widget
  static const Widget sliver = SliverToBoxAdapter(child: ui);
}

/// 间隙
extension GapExtension on num {
  /// 横向间隔
  /// 使用方法为 [1.hGap]
  Widget get hGap => SizedBox(width: w);

  /// 纵向间隔
  /// 使用方法为 [1.vGap]
  Widget get vGap => SizedBox(height: w);
}

/// 分割线
extension NumLineExtension on num {
  /// 横线
  /// [color] 线段颜色
  /// [margin] 线段间距 默认无
  /// [width] 线段宽度
  Widget hLine({
    Color? color,
    EdgeInsets margin = EdgeInsets.zero,
    double? width,
  }) {
    return Builder(builder: (context) {
      return Container(
        margin: margin,
        width: width,
        height: h,
        color: color ?? context.theme.line,
      );
    });
  }

  /// 竖线
  /// [color] 线段颜色
  /// [margin] 线段间距 默认无
  /// [height] 线段高度
  Widget vLine({
    Color? color,
    EdgeInsets margin = EdgeInsets.zero,
    double? height,
  }) {
    return Builder(builder: (context) {
      return Container(
        margin: margin,
        width: w,
        height: height,
        color: color ?? context.theme.line,
      );
    });
  }
}

extension TextStyleExt on TextStyle {
  /// 居中
  TextStyle get center => copyWith(
        leadingDistribution: TextLeadingDistribution.even,
        height: 1,
      );
}

/// textstyle拓展
extension TextStyleNumExtension on num {
  // 获取sp的ts
  TextStyle get spts => TextStyle(fontSize: sp);

  // 根据当前值获取ts
  TextStyle get ts => TextStyle(fontSize: toDouble());
}
