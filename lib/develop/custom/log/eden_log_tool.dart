import 'package:eden_logger/eden_logger.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'expanded_viewport.dart';

class EdenLogTool extends StatefulWidget {
  const EdenLogTool({super.key});

  @override
  EdenLogToolState createState() => EdenLogToolState();
}

class EdenLogToolState extends State<EdenLogTool> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: EdenLogLogger.instance.stream,
      builder: (context, snapshot) {
        final events = EdenLogLogger.instance.events;
        return Scrollable(
          physics: const BouncingScrollPhysics(),
          controller: _scrollController,
          axisDirection: AxisDirection.up,
          viewportBuilder: (BuildContext context, ViewportOffset offset) {
            return ExpandedViewport(
              offset: offset as ScrollPosition,
              axisDirection: AxisDirection.up,
              slivers: <Widget>[
                SliverExpanded(),
                //分类消息类型
                SliverPadding(
                  padding: EdgeInsets.all(16.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 10.w),
                          child: Text.rich(
                            TextSpan(
                              text: '${events[index].time.getString()}:\n',
                              children: [
                                TextSpan(
                                  text: events[index].info,
                                  style: 12.spts.shade700(context),
                                ),
                              ],
                            ),
                            style: 12.spts.shade500(context),
                          ),
                        );
                      },
                      childCount: events.length,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
