import 'package:eden/config/eden_version.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:eden_utils/eden_utils.dart';
import 'package:flutter/material.dart';

import '../eden_develop_tools.dart';

class EdenMainTool extends StatelessWidget {
  const EdenMainTool({super.key, this.icon});

  final Widget? icon;

  String _timer() {
    String format = 'yyyyMMdd\nHH:mm';
    int compileTime = EdenVersion.publishTime;
    return DateTime.fromMillisecondsSinceEpoch(compileTime)
        .getString(format: format);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        16.vGap,
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 1.5,
                  child: icon ?? EdenEmpty.ui,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text.rich(
                    TextSpan(text: '版本：', children: [
                      const TextSpan(
                        text:
                            '${EdenVersion.versionName}(${EdenVersion.versionCode})',
                        style: TextStyle(fontSize: 16),
                      ),
                      TextSpan(
                        text: '\n${_timer()}',
                      )
                    ]),
                    style: const TextStyle(
                        fontSize: 12, textBaseline: TextBaseline.ideographic),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 16 / 9,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            itemBuilder: (ctx, index) {
              EdenDevelopTool tool = EdenDevelopTools.instance.mainTools[index];
              return GestureDetector(
                onTap: () {
                  if (tool.onTap != null) {
                    tool.onTap?.call(context);
                    EdenDevelopTools.instance.removeTools();
                    return;
                  }
                  Navigator.of(context).pushNamed(tool.routeName);
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: context.theme.border),
                      borderRadius: BorderRadius.circular(5)),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      tool.icon ?? const Icon(Icons.article_outlined),
                      Text(
                        tool.title,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
            itemCount: EdenDevelopTools.instance.mainTools.length,
          ),
        ),
      ],
    );
  }
}
