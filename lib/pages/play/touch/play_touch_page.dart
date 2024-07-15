import 'package:collection/collection.dart';
import 'package:eden/entities/toy_command_entity.dart';
import 'package:eden/pages/play/widgets/chart/eden_line_chart.dart';
import 'package:eden/pages/play/widgets/gesture/eden_play_gesture_detector.dart';
import 'package:eden/toy/toy_provider.dart';
import 'package:eden_intl/eden_intl.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

class PlayTouchPage extends StatefulWidget {
  const PlayTouchPage({super.key});

  @override
  State<PlayTouchPage> createState() => _PlayTouchPageState();
}

class _PlayTouchPageState extends State<PlayTouchPage> {
  final EdenPlayGestureNotifier _notifier = EdenPlayGestureNotifier()
    ..value = true;
  final EdenPlayGestureLinesNotifier _linesNotifier =
      EdenPlayGestureLinesNotifier();
  final ValueNotifier<ToyChartEntity> _chartNotifier =
      ValueNotifier(ToyChartEntity());
  DateTime? time;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EdenAppBar(
        title: context.strings.touch,
      ),
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: _chartNotifier,
            builder: (context, chart, child) {
              return EdenLineChart(
                chart: chart,
                onEnd: () {},
                isOnlyShow: true,
              );
            },
          ),
          Expanded(
            child: EdenPlayGestureDetector(
              onChanged: (List<int> value, lines) {
                time ??= DateTime.now();
                _chartNotifier.value = _chartNotifier.value.addPoint(
                  DateTime.now().millisecondsSinceEpoch -
                      time!.millisecondsSinceEpoch,
                  value.max,
                );
                context.read(toyNotifierProvider.notifier).roomCommand(
                      ToyRoomCommandEntity(value, lines),
                    ); //发送震动
              },
              notifier: _notifier,
              onEnd: () {},
              linesNotifier: _linesNotifier,
            ),
          ),
        ],
      ),
    );
  }
}
