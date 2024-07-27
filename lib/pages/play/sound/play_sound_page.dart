import 'dart:math';

import 'package:eden/uikit/appbar/eden_gradient_app_bar.dart';
import 'package:eden/uikit/background/eden_background.dart';
import 'package:eden/utils/record_util.dart';
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
  @override
  void initState() {
    super.initState();
    RecordUtil.instance.init();
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
                            valueListenable: RecordUtil.instance.recordState,
                            builder: (context, recordState, child) {
                              return Visibility(
                                visible: recordState == RecordState.record,
                                child: const WaveWidget(),
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
                      GestureDetector(
                        onTap: () {
                          _onRecordClick();
                        },
                        child: Icon(
                          Icons.mic,
                          size: 60.w,
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
    if (RecordUtil.instance.recordState.value == RecordState.record) {
      await RecordUtil.instance.stop();
    } else {
      await RecordUtil.instance.start();
    }
  }

  @override
  void dispose() {
    RecordUtil.instance.dispose();
    super.dispose();
  }
}

class WaveWidget extends StatefulWidget {
  const WaveWidget({super.key});

  @override
  State<WaveWidget> createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<WaveWidget> {
  late IOS7SiriWaveformController controller;

  @override
  void initState() {
    super.initState();
    RecordUtil.instance.amplitude.addListener(_listener);
    controller = IOS7SiriWaveformController(
      amplitude: 0,
      frequency: 6,
      speed: 0.2,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller.color = context.theme.primary;
  }

  void _listener() {
    if (mounted) {
      controller.amplitude = RecordUtil.transformValue(RecordUtil.scaleValue(max(-40, RecordUtil.instance.amplitude.value.current)));
      debugPrint('amplitude = ${controller.amplitude}');
      setState(() {});
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
    // return ValueListenableBuilder(
    //   valueListenable: RecordUtil.instance.amplitude,
    //   builder: (context, amplitude, child) {
    //     controller.amplitude = RecordUtil.transformValue(RecordUtil.scaleValue(max(-40, amplitude.current)));
    //     debugPrint('amplitude = ${controller.amplitude}');
    //     return SiriWaveform.ios7(
    //       controller: controller,
    //       options: IOS7SiriWaveformOptions(
    //         width: 313.w,
    //         height: 250.w,
    //       ),
    //     );
    //   },
    // );
  }

  @override
  void dispose() {
    super.dispose();
    RecordUtil.instance.amplitude.removeListener(_listener);
  }
}
