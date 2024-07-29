import 'dart:math';

import 'package:eden/uikit/appbar/eden_gradient_app_bar.dart';
import 'package:eden/uikit/background/eden_background.dart';
import 'package:eden/utils/ble/ble_manager_provider.dart';
import 'package:eden/utils/eden_record.dart';
import 'package:eden/utils/function_proxy.dart';
import 'package:eden_intl/eden_intl.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:siri_wave/siri_wave.dart';

///
/// 声音模式
///
/// Created by Jack Zhang on 2024/7/27 .
///
class PlaySoundPage extends StatefulWidget {
  const PlaySoundPage({super.key});

  @override
  State<PlaySoundPage> createState() => _PlaySoundPageState();
}

class _PlaySoundPageState extends State<PlaySoundPage> {
  late final ValueNotifier<double> _sliderValueNotifier = ValueNotifier(1);

  @override
  void initState() {
    super.initState();
    EdenRecord.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return EdenBackground(
      child: Scaffold(
        appBar: EdenGradientAppBar(
          title: context.strings.sound,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.w),
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Container(
                  width: 313.w,
                  height: 295.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.w),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.w),
                  child: Column(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder(
                            valueListenable: EdenRecord.instance.recordState,
                            builder: (context, recordState, child) {
                              return Visibility(
                                visible: recordState == RecordState.record,
                                child:
                                    WaveWidget(notifier: _sliderValueNotifier),
                              );
                            }),
                      ),
                      Text(
                        '根据当前环境分贝变化控制强度',
                        style: 11.spts.medium,
                      )
                    ],
                  ),
                ),
                20.vGap,
                Container(
                  width: 313.w,
                  height: 295.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.w),
                    color: const Color(0xffFAF6F7),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.w),
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      Text(
                        '灵敏度',
                        style: 13.spts,
                      ),
                      Row(
                        children: [
                          Text(
                            '低',
                            style: 12.spts,
                          ),
                          Expanded(
                            child: ValueListenableBuilder(
                              valueListenable: _sliderValueNotifier,
                              builder: (context, value, child) {
                                return Slider(
                                  min: 0.5,
                                  max: 1.5,
                                  value: value,
                                  onChanged: (newValue) {
                                    _sliderValueNotifier.value = newValue;
                                  },
                                );
                              },
                            ),
                          ),
                          Text(
                            '高',
                            style: 12.spts,
                          ),
                        ],
                      ),
                      30.vGap,
                      GestureDetector(
                        onTap: () {
                          _onRecordClick();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.theme.primary,
                          ),
                          padding: EdgeInsets.all(16.w),
                          child: Icon(
                            Icons.mic,
                            size: 60.w,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onRecordClick() async {
    if (EdenRecord.instance.recordState.value == RecordState.record) {
      await EdenRecord.instance.pause();
    } else if (EdenRecord.instance.recordState.value == RecordState.pause) {
      await EdenRecord.instance.resume();
    } else {
      await EdenRecord.instance.start();
    }
  }

  @override
  void dispose() {
    EdenRecord.instance.dispose();
    super.dispose();
  }
}

class WaveWidget extends ConsumerStatefulWidget {
  const WaveWidget({super.key, required this.notifier});

  final ValueNotifier<double> notifier;

  @override
  ConsumerState<WaveWidget> createState() => _WaveWidgetState();
}

class _WaveWidgetState extends ConsumerState<WaveWidget> {
  late IOS7SiriWaveformController controller =
      IOS7SiriWaveformController(speed: .1, frequency: 2);

  ValueNotifier<double> get sliderNotifier => widget.notifier;

  double _sliderValue = 1;

  /// 强度
  double _intensity = .0;

  @override
  void initState() {
    super.initState();
    sliderNotifier.addListener(_sliderValueListener);
    EdenRecord.instance.amplitude.addListener(_listener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.amplitude = .0;
      controller.color = context.theme.primary;
    });
  }

  void _sliderValueListener() {
    _sliderValue = sliderNotifier.value;
  }

  void _listener() {
    if (mounted) {
      final double result = EdenRecord.transformValue(EdenRecord.scaleValue(
          max(-40, EdenRecord.instance.amplitude.value.current)));
      controller.amplitude = (result * _sliderValue).clamp(0.03, 1.0);
      debugPrint('amplitude = ${controller.amplitude}');
      setState(() {});
      _intensity = (result * _sliderValue).clamp(.0, 1.0);
      FunctionProxy(soundMotor, timeout: 120).throttleWithTimeout();
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build amplitude = ${controller.amplitude}');
    return SiriWaveform.ios7(
      controller: controller,
      options: IOS7SiriWaveformOptions(
        width: 313.w,
        height: 250.w,
      ),
    );
  }

  void soundMotor() {
    ref.read(bleDeviceStateProvider)?.soundMotor(_intensity);
  }

  @override
  void dispose() {
    super.dispose();
    EdenRecord.instance.amplitude.removeListener(_listener);
    sliderNotifier.removeListener(_sliderValueListener);
  }
}
