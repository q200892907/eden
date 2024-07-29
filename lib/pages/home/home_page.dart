import 'dart:io';

import 'package:eden/router/eden_router.dart';
import 'package:eden/uikit/appbar/eden_gradient_app_bar.dart';
import 'package:eden/uikit/audio/eden_audio_view.dart';
import 'package:eden/uikit/background/eden_background.dart';
import 'package:eden/uikit/button/eden_gradient_button.dart';
import 'package:eden/uikit/button/eden_outlined_button.dart';
import 'package:eden/utils/eden_file_util.dart';
import 'package:eden/utils/eden_local_http_service.dart';
import 'package:eden/utils/eden_music_player.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    return EdenBackground(
      child: Scaffold(
        appBar: const EdenGradientAppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const EdenGradientButton(
              title: 'Play',
            ),
            EdenGradientButton(
              onTap: () {
                const PlayRoute().push(context);
              },
              title: 'Play',
            ),
            ValueListenableBuilder(
              valueListenable: EdenLocalHttpService.instance.localServerUri,
              builder: (_, uri, __) {
                return Text(uri ?? '未开启本地服务');
              },
            ),
            TextButton(
              onPressed: () {
                EdenLocalHttpService.instance.start().then((value) {
                  if (!value) {
                    EdenToast.show('未连接wifi');
                  }
                });
              },
              child: const Text('Wifi上传音乐'),
            ),
            TextButton(
              onPressed: () {
                EdenLocalHttpService.instance.stop();
              },
              child: const Text('退出Wifi上传音乐'),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: EdenMusicPlayer.instance.musicList,
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
                                EdenMusicPlayer.instance.play(index);
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(file.path.fileName),
                                  Text(file.lengthSync().getRollupSize()),
                                ],
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
}
