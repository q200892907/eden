import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

class EdenOutlinedButton extends StatelessWidget {
  const EdenOutlinedButton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.onTap,
    this.child,
    this.title,
    this.textStyle,
    this.border,
  });

  final double? width; // 按钮 宽
  final double? height; // 按钮 高
  final BorderRadius? borderRadius; // 按钮 圆角
  final GestureTapCallback? onTap;

  final Widget? child; // 子组件
  final String? title; // 按钮文本 二选一
  final TextStyle? textStyle; //文本字符串
  final Border? border;

  @override
  Widget build(BuildContext context) {
    double height = this.height ?? 44.w;
    BorderRadius borderRadius =
        this.borderRadius ?? BorderRadius.circular(height / 2);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.transparent,
        border: border ?? Border.all(color: context.theme.primary, width: 1.w),
      ),
      child: Material(
        type: MaterialType.transparency, // 透明材质 用于绘制墨水飞溅和高光
        child: InkWell(
          onTap: onTap,
          splashColor: context.theme.primary.withOpacity(0.2),
          borderRadius: borderRadius,
          highlightColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: width, height: height),
            child: Center(
              child: title != null
                  ? Text(
                      title!,
                      style: textStyle ??
                          16
                              .sp
                              .ts
                              .bold
                              .copyWith(color: context.theme.text.shade700),
                    )
                  : child ?? EdenEmpty.ui,
            ),
          ),
        ),
      ),
    );
  }
}
