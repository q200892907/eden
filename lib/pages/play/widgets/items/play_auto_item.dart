import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

class PlayAutoItem extends StatelessWidget {
  const PlayAutoItem({
    super.key,
    required this.icon,
    required this.iconSize,
    required this.title,
    required this.checked,
    required this.onTap,
  });

  final String icon;
  final Size iconSize;
  final String title;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap.call();
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        constraints: BoxConstraints.expand(width: 87.w, height: 70.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.w),
          color: checked ? context.theme.primary : const Color(0xfffcf5ff),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            EdenImage.loadAssetImage(
              icon,
              width: iconSize.width,
              height: iconSize.height,
              color: checked ? Colors.white : context.theme.primary,
            ),
            Text(
              title,
              style: 12.spts.copyWith(color: checked ? Colors.white : context.theme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
