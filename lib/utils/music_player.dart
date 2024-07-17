import 'dart:io';

import 'package:eden/utils/file_util.dart';
import 'package:eden/utils/local_http_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MusicPlayer {
  factory MusicPlayer() => _getInstance();

  static MusicPlayer get instance => _getInstance();
  static MusicPlayer? _instance;

  MusicPlayer._internal() {
    player = Player();
    player.setPlaylistMode(PlaylistMode.loop);
    player.stream.playlist.listen((value) {
      print('play:${value.index}');
    });
    player.stream.position.listen((value) {
      print('position:$value');
      // getDbAtTime(value).then((db) {
      //   print('db:$db');
      // });
    });
  }

  // Future<num> getDbAtTime(Duration time) async {
  //   String path = musicList.value[player]; // 替换为你的音频文件路径
  //   int positionInSeconds = time.inSeconds;
  //   num currentDb = 0;
  //   // 构建 ffmpeg 命令
  //   String command =
  //       '-i $path -af astats=metadata=1:reset=1,ametadata=print:key=lavfi.astats.Overall.RMS_level:file=- -f null -';
  //
  //   // 执行 ffmpeg 命令
  //   int rc = await _flutterFFmpeg.execute(command);
  //
  //   // 解析输出结果，提取分贝值
  //   if (rc == 0) {
  //     List<String> output = await _flutterFFmpeg.listExecutions();
  //     String? rmsLevelLine = output.firstWhere(
  //         (line) => line.contains('lavfi.astats.Overall.RMS_level'),
  //         orElse: () => '');
  //     if (rmsLevelLine.isNotEmpty) {
  //       List<String> parts = rmsLevelLine.split('=');
  //       if (parts.length > 1) {
  //         String dbString = parts[1].trim();
  //         double dbValue = double.tryParse(dbString) ?? 0.0;
  //         currentDb = dbValue;
  //       }
  //     }
  //   }
  //   return currentDb;
  // }

  static MusicPlayer _getInstance() {
    _instance ??= MusicPlayer._internal();
    return _instance!;
  }

  final ValueNotifier<List<File>> musicList = ValueNotifier([]);

  late final Player player;
  late final controller = VideoController(player);

  /// 扫描本地路径，查看音乐
  void scan() {
    _getAudioFiles(LocalHttpService.instance.localMusicDir).then((value) {
      musicList.value = value;
      player.stop();
      player.open(
        Playlist(
          musicList.value.map((e) {
            return Media(e.path);
          }).toList(),
          index: value.length - 1,
        ),
        play: false,
      );
    });
  }

  Future<List<File>> _getAudioFiles(Directory dir) async {
    List<File> audioFiles = [];

    // 递归遍历目录及其子目录
    await for (FileSystemEntity entity
        in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        // 检查文件扩展名是否为音频文件类型
        if (FileUtil.isAudio(entity.path)) {
          audioFiles.add(entity);
        }
      }
    }

    return audioFiles;
  }

  void play([int? index]) {
    if (musicList.value.isEmpty) {
      return;
    }
    if (index != null) {
      if (index >= musicList.value.length || index < 0) {
        return;
      }
      player.jump(index);
    }
    player.play();
  }

  void next() {
    player.next();
  }

  void previous() {
    player.previous();
  }

  void stop() {
    player.stop();
  }
}
