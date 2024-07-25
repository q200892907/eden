import 'dart:async';

import 'package:collection/collection.dart';
import 'package:eden/entities/toy_command_entity.dart';
import 'package:eden/pages/play/widgets/chart/eden_line_chart.dart';
import 'package:eden/pages/play/widgets/gesture/eden_play_gesture_detector.dart';
import 'package:eden/toy/toy_provider.dart';
import 'package:eden/uikit/appbar/eden_gradient_app_bar.dart';
import 'package:eden/uikit/background/eden_background.dart';
import 'package:eden/uikit/button/eden_gradient_button.dart';
import 'package:eden/utils/chart_util.dart';
import 'package:eden_intl/eden_intl.dart';
import 'package:eden_service/eden_service.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

class PlayTouchPage extends StatefulWidget {
  const PlayTouchPage({super.key});

  @override
  State<PlayTouchPage> createState() => _PlayTouchPageState();
}

class _PlayTouchPageState extends State<PlayTouchPage> {
  final EdenPlayGestureLinesNotifier _linesNotifier =
      EdenPlayGestureLinesNotifier();
  final ValueNotifier<ToyChartEntity> _chartNotifier =
      ValueNotifier(ToyChartEntity());
  DateTime? _time;
  Timer? _startTimer;
  bool _isTouch = false;
  final ValueNotifier<bool> _touchNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  void _start() {
    if (_startTimer != null) {
      return;
    }
    _time = DateTime.now();
    _touchNotifier.value = true;
    _startTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (_isTouch) {
        return;
      }
      _addPoint(0);
    });
  }

  void _stop() {
    _startTimer?.cancel();
    _startTimer = null;
    _time = null;
    _touchNotifier.value = false;
  }

  void _reset() {
    _chartNotifier.value = ToyChartEntity();
    _linesNotifier.reset();
  }

  void _save() {
    // TODO: 保存逻辑
    ChartUtil.instance.addChart(
      EdenAccountService.instance.account?.id ?? '',
      DateTime.now().toString(),
      _chartNotifier.value,
    );
    // 保存后清空
    _reset();
  }

  @override
  Widget build(BuildContext context) {
    return EdenBackground(
      child: Scaffold(
        appBar: EdenGradientAppBar(
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
                  _isTouch = true;
                  _addPoint(value.max);
                  context.read(toyNotifierProvider.notifier).roomCommand(
                        ToyRoomCommandEntity(value, lines),
                      ); //发送震动
                },
                onStart: () {
                  _start();
                },
                onEnd: () {
                  _isTouch = false;
                },
                linesNotifier: _linesNotifier,
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _touchNotifier,
              builder: (_, start, __) {
                return Row(
                  children: [
                    Expanded(
                      child: EdenGradientButton(
                        title: start ? 'Stop' : 'Start',
                        onTap: () {
                          if (start) {
                            _stop();
                            _save();
                          } else {
                            _start();
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ValueListenableBuilder(
                          valueListenable: ChartUtil.instance.charts,
                          builder: (context, charts, __) {
                            return EdenGradientButton(
                              title: '历史(${charts.length})',
                              onTap: () {
                                print(charts);
                                for (var e in charts) {
                                  ChartUtil.instance.deleteChart(e);
                                }
                              },
                            );
                          }),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addPoint(int max) {
    _chartNotifier.value = _chartNotifier.value.addPoint(
      DateTime.now().millisecondsSinceEpoch - _time!.millisecondsSinceEpoch,
      max,
    );
    _time = DateTime.now();
  }
}
