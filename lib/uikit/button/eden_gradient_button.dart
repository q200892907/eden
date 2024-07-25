import 'package:eden/uikit/theme/eden_theme_extension.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

class EdenGradientButton extends StatelessWidget {
  const EdenGradientButton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.onTap,
    this.child,
    this.title,
  });

  final double? width; // 按钮 宽
  final double? height; // 按钮 高
  final BorderRadius? borderRadius; // 按钮 圆角

  final GestureTapCallback? onTap;

  final Widget? child; // 子组件
  final String? title; // 按钮文本 二选一

  @override
  Widget build(BuildContext context) {
    bool disable = onTap == null;
    double height = this.height ?? 44.w;
    BorderRadius borderRadius =
        this.borderRadius ?? BorderRadius.circular(height / 2);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: context.theme.buttonLinearGradient,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: disable ? Colors.grey.withOpacity(0.4) : Colors.transparent,
        ),
        child: Material(
          type: MaterialType.transparency, // 透明材质 用于绘制墨水飞溅和高光
          child: InkWell(
            onTap: onTap,
            splashColor: context.theme.primary,
            borderRadius: borderRadius,
            enableFeedback: !disable,
            // 是否给予操作反馈
            highlightColor: Colors.transparent,
            child: ConstrainedBox(
              constraints:
                  BoxConstraints.tightFor(width: width, height: height),
              child: Center(
                child: DefaultTextStyle(
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  child: title != null
                      ? Text(title!,
                          style: 16.sp.ts.bold.copyWith(
                              color: Colors.white
                                  .withOpacity(disable ? 0.6 : 1.0)))
                      : child ?? EdenEmpty.ui,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
