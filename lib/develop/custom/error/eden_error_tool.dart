import 'dart:io';

import 'package:eden/develop/tools/eden_develop_clipboard_util.dart';
import 'package:eden_logger/eden_logger.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'eden_error_logger.dart';

export 'eden_error_logger.dart';

class EdenErrorTool extends StatefulWidget {
  const EdenErrorTool({super.key});

  @override
  EdenErrorToolState createState() => EdenErrorToolState();
}

class EdenErrorToolState extends State<EdenErrorTool> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        mini: true,
        shape: const CircleBorder(),
        child: Icon(
          (Platform.isAndroid || Platform.isIOS)
              ? Icons.copy
              : Icons.folder_open,
          size: 16,
        ),
        onPressed: () {
          String path = EdenLogFile.getLogDirectoryPath();
          EdenDevelopClipboardUtil.copy(path);
        },
      ),
      body: GestureDetector(
        onLongPress: () async {
          EdenDevelopClipboardUtil.copy(
              Directory('${(await getApplicationSupportDirectory()).path}/logs')
                  .path);
        },
        child: StreamBuilder(
          stream: EdenErrorLogger.instance.stream,
          builder: (context, snapshot) {
            final events = EdenErrorLogger.instance.events;
            return ListView.separated(
              separatorBuilder: (_, index) {
                return 1.hLine();
              },
              itemBuilder: (_, index) {
                return ExpansionTile(
                  title: Text(
                    events[index].exceptionAsString().showContent,
                    style:
                        Theme.of(context).textTheme.titleSmall?.danger(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '错误来源:${events[index].library}',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.shade700(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  children: [
                    ListTile(
                      subtitle: Text(
                        events[index].toString().showContent,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.shade500(context),
                      ),
                    )
                  ],
                );
              },
              itemCount: events.length,
            );
          },
        ),
      ),
    );
  }
}
