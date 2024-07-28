import 'dart:async';
import 'dart:io';

import 'package:eden/router/eden_router.dart';
import 'package:eden/uikit/appbar/eden_gradient_app_bar.dart';
import 'package:eden/uikit/audio/eden_audio_view.dart';
import 'package:eden/uikit/background/eden_background.dart';
import 'package:eden/uikit/button/eden_gradient_button.dart';
import 'package:eden/uikit/button/eden_outlined_button.dart';
import 'package:eden/utils/ble/ble_manager_provider.dart';
import 'package:eden/utils/file_util.dart';
import 'package:eden/utils/local_http_service.dart';
import 'package:eden/utils/music_player.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:media_kit/media_kit.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late StreamSubscription _indexStreamListener;
  late StreamSubscription _posStreamListener;

  Waveform? _curWaveForm;

  @override
  void initState() {
    super.initState();
    _indexStreamListener = MusicPlayer.instance.player.stream.playlist.listen((value) {
      final int index = value.index;
      debugPrint('当前音频Index:$index');
      _curWaveForm = null;
      File waveFile = File('${MusicPlayer.instance.musicList.value[index].path}.wave');
      // 解析波形文件
      Stopwatch stopwatch = Stopwatch();
      stopwatch.start();
      JustWaveform.parse(waveFile).then((waveForm) {
        stopwatch.stop();
        debugPrint("解析波形文件耗时(ms)：${stopwatch.elapsed.inMilliseconds}");
        _curWaveForm = waveForm;
      });
    });
    _posStreamListener = MusicPlayer.instance.player.stream.position.listen((p) {
      final int milliSeconds = p.inMilliseconds;
      debugPrint('当前音频进度(ms):$milliSeconds');
      if (_curWaveForm != null) {
        int sampleId = _curWaveForm!.positionToPixel(Duration(milliseconds: milliSeconds)).toInt();
        int min = _curWaveForm!.getPixelMin(sampleId);
        int max = _curWaveForm!.getPixelMax(sampleId);
        debugPrint('波形文件min：$min；max：$max');
        double dbPercent;
        if (_curWaveForm!.flags == 0) {
          dbPercent = (min.abs() + max.abs()) / 65535;
        } else {
          dbPercent = (min.abs() + max.abs()) / 255;
        }
        debugPrint('dbPercent：$dbPercent');
        ref.read(bleDeviceStateProvider)?.musicMotor(dbPercent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return EdenBackground(
      child: Scaffold(
        appBar: const EdenGradientAppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            EdenGradientButton(
              title: 'Play',
            ),
            EdenGradientButton(
              onTap: () {
                const PlayRoute().push(context);
              },
              title: 'Play',
            ),
            ValueListenableBuilder(
              valueListenable: LocalHttpService.instance.localServerUri,
              builder: (_, uri, __) {
                return Text(uri ?? '未开启本地服务');
              },
            ),
            TextButton(
              onPressed: () {
                LocalHttpService.instance.start().then((value) {
                  if (!value) {
                    EdenToast.show('未连接wifi');
                  }
                });
              },
              child: const Text('Wifi上传音乐'),
            ),
            TextButton(
              onPressed: () {
                LocalHttpService.instance.stop();
              },
              child: const Text('退出Wifi上传音乐'),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: MusicPlayer.instance.musicList,
                builder: (_, list, __) {
                  return Column(
                    children: [
                      Visibility(
                        visible: list.isNotEmpty,
                        child: const EdenAudioView(),
                      ),
                      Expanded(
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (_, index) {
                            File file = list[index];
                            return EdenOutlinedButton(
                              onTap: () {
                                MusicPlayer.instance.play(index);
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(file.path.fileName),
                                  Text(file.lengthSync().getRollupSize()),
                                ],
                              ),
                            );
                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              child: Container(
                                margin: EdgeInsets.all(8.w),
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1.w),
                                  borderRadius: BorderRadius.circular(4.w),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(file.path.fileName),
                                    Text(file.lengthSync().getRollupSize()),
                                  ],
                                ),
                              ),
                            );
                          },
                          itemCount: list.length,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _indexStreamListener.cancel();
    _posStreamListener.cancel();
  }
}
