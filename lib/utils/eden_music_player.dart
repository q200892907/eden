import 'dart:io';

import 'package:eden/utils/eden_file_util.dart';
import 'package:eden/utils/eden_local_http_service.dart';
import 'package:eden/utils/eden_waveform.dart';
import 'package:eden_logger/eden_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

abstract class EdenMusicListener {
  void onMusicChanged(int index);

  void onMusicPlaying(bool playing);

  void onMusicPlayingChanged(Duration duration, double currentDb);
}

class EdenMusicPlayer {
  factory EdenMusicPlayer() => _getInstance();

  static EdenMusicPlayer get instance => _getInstance();
  static EdenMusicPlayer? _instance;

  EdenMusicPlayer._internal() {
    _player = Player();
    _player.setPlaylistMode(PlaylistMode.loop);
    _player.stream.playlist.listen((value) {
      final int index = value.index;
      if (musicList.value.elementAtOrNull(index) != null) {
        _curWaveForm = null;
        EdenWaveform.parse(
          musicList.value[index].path,
        ).then((waveform) {
          _curWaveForm = waveform;
        });
      }
      for (var element in _listeners) {
        element.onMusicChanged(index);
      }
    });
    _player.stream.playing.listen((playing) {
      for (var element in _listeners) {
        element.onMusicPlaying(playing);
      }
    });
    _player.stream.position.listen((p) {
      final int milliSeconds = p.inMilliseconds;
      EdenLogger.d('当前音频进度(ms):$milliSeconds');
      double dbPercent = 0;
      if (_curWaveForm != null) {
        int sampleId = _curWaveForm!
            .positionToPixel(Duration(milliseconds: milliSeconds))
            .toInt();
        int min = _curWaveForm!.getPixelMin(sampleId);
        int max = _curWaveForm!.getPixelMax(sampleId);
        EdenLogger.d('波形文件min：$min；max：$max');
        if (_curWaveForm!.flags == 0) {
          dbPercent = (min.abs() + max.abs()) / 65535;
        } else {
          dbPercent = (min.abs() + max.abs()) / 255;
        }
        EdenLogger.d('dbPercent：$dbPercent');
      }
      for (var element in _listeners) {
        element.onMusicPlayingChanged(p, dbPercent);
      }
    });
  }

  static EdenMusicPlayer _getInstance() {
    _instance ??= EdenMusicPlayer._internal();
    return _instance!;
  }

  final ValueNotifier<List<File>> musicList = ValueNotifier([]);

  late final Player _player;

  Player get player => _player;
  Waveform? _curWaveForm;
  late final controller = VideoController(_player);

  final Set<EdenMusicListener> _listeners = {};

  void addListener(EdenMusicListener listener) {
    _listeners.add(listener);
  }

  void removeListener(EdenMusicListener listener) {
    _listeners.remove(listener);
  }

  /// 扫描本地路径，查看音乐
  void scan() {
    _getAudioFiles(EdenLocalHttpService.instance.localMusicDir).then((value) {
      List<File> playlist = [];
      // 扫描波形文件
      for (var e in value) {
        bool isExists = EdenWaveform.existsSync(e.path);
        if (isExists) {
          playlist.add(e);
        } else {
          e.deleteSync();
        }
      }
      musicList.value = playlist;
      _player.stop();
      _player.open(
        Playlist(
          musicList.value.map((e) {
            return Media(e.path);
          }).toList(),
          index: musicList.value.length - 1,
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
        if (EdenFileUtil.isAudio(entity.path)) {
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
      _player.jump(index);
    }
    _player.play();
  }

  void next() {
    _player.next();
  }

  void previous() {
    _player.previous();
  }

  void stop() {
    _player.stop();
  }
}
