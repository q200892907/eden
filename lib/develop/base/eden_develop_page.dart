import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

import '../eden_develop_tools.dart';

class EdenDevelopPage extends StatelessWidget {
  final EdenDevelopTool tool;

  const EdenDevelopPage({super.key, required this.tool});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: SafeArea(
        maintainBottomViewPadding: false,
        child: Scaffold(
          backgroundColor: context.theme.background,
          appBar: tool.title.isEmptyOrNull || !tool.isAppBar
              ? null
              : AppBar(
                  title: Text(tool.title), centerTitle: true, elevation: 1.w),
          body: EdenBottomSafeArea(child: tool.child ?? EdenEmpty.ui),
        ),
      ),
    );
  }
}
