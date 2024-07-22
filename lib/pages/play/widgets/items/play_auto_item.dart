import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

class PlayAutoItem extends StatelessWidget {
  const PlayAutoItem({
    super.key,
    required this.icon,
    required this.title,
    required this.checked,
    required this.onTap,
  });

  final String icon;
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
        // width: 87.w,
        // height: 70.w,
        constraints: BoxConstraints.expand(width: 87.w, height: 70.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.w),
          color: checked ? context.theme.primary : const Color(0xfffcf5ff),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.circle,
              color: context.theme.primary,
              size: 24.w,
            ),
            Text(
              title,
              style: 12.spts.primary(context),
            ),
          ],
        ),
      ),
    );
  }
}
