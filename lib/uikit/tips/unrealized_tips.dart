import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

class UnrealizedTips extends StatelessWidget {
  const UnrealizedTips({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Text(
          '$name功能\n暂未实现',
          style: 16.spts.shade700(context).bold,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
