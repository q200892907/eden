import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

/// 导航
class EdenGradientAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const EdenGradientAppBar({
    super.key,
    this.title,
    this.titleChild,
    this.onBack,
    this.isBack,
    this.isClose = false,
    this.onClose,
    this.actions,
    this.centerTitle,
    this.leading,
  });

  final String? title;
  final Widget? titleChild;
  final Widget? leading;
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final bool? isBack;
  final bool isClose;
  final List<Widget>? actions;
  final bool? centerTitle;

  @override
  Widget build(BuildContext context) {
    bool isBack = this.isBack ?? Navigator.of(context).canPop();
    Color color = context.theme.text.shade700;
    return AppBar(
      centerTitle: centerTitle ?? true,
      toolbarHeight: preferredSize.height,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      titleSpacing: 0,
      leadingWidth: leading != null
          ? 80.w
          : isBack
              ? isClose
                  ? 90.w
                  : 45.w
              : 12.w,
      leading: leading ??
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (isBack)
                EdenIconAction(
                  onTap: () {
                    if (onBack == null) {
                      Navigator.of(context).maybePop();
                    }
                    onBack?.call();
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 24.w,
                    color: color,
                  ),
                ),
              if (isClose)
                EdenIconAction(
                  onTap: () {
                    if (onClose == null) {
                      Navigator.of(context).maybePop();
                    }
                    onClose?.call();
                  },
                  icon: Icon(
                    Icons.close,
                    color: color,
                    size: 24.w,
                  ),
                ),
            ],
          ),
      elevation: 0,
      scrolledUnderElevation: 0,
      title: DefaultTextStyle(
        style: 16.spts.textColor(color).medium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        child: titleChild ??
            Text(
              title ?? '',
              style: 16.spts.textColor(color).regular,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(45.w);
}
