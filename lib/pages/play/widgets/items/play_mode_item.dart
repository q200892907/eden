import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

class PlayModeItem extends StatelessWidget {
  const PlayModeItem({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap.call();
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        constraints: BoxConstraints.expand(width: 166.w, height: 140.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.w),
          color: context.theme.primary,
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: 24.spts.white,
            ),
          ],
        ),
      ),
    );
  }
}
