import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

class EdenIconAction extends StatelessWidget {
  const EdenIconAction({
    super.key,
    required this.icon,
    this.onTap,
    this.margin,
  });

  final Widget icon;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.translucent,
        child: Container(
          padding: margin ?? EdgeInsets.zero,
          alignment: Alignment.center,
          child: SizedBox(
            width: 32.w,
            height: 32.w,
            child: Center(
              child: IconTheme(
                data: IconThemeData(
                  size: 24.w,
                  color: context.theme.text.shade700,
                ),
                child: icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
