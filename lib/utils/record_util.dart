import 'dart:async';
import 'dart:io';

import 'package:eden/utils/music_player.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:vibration/vibration.dart';
import 'package:path/path.dart' as p;

class RecordUtil {
  factory RecordUtil() => _getInstance();

  static RecordUtil get instance => _getInstance();
  static RecordUtil? _instance;

  RecordUtil._internal();

  static RecordUtil _getInstance() {
    _instance ??= RecordUtil._internal();
    return _instance!;
  }

  late final AudioRecorder _audioRecorder;
  StreamSubscription<RecordState>? _responseStream;
  StreamSubscription<Amplitude>? _amplitudeStream;
  String? _filePath;
  final ValueNotifier<List<double>> _dbList = ValueNotifier([]);
  final ValueNotifier<RecordState> _state = ValueNotifier(RecordState.stop);
  final ValueNotifier<int> _recordTime = ValueNotifier(0);
  final int _maxTime = 100;
  Timer? _timer;

  void init() {
    _audioRecorder = AudioRecorder();
    _audioRecorder.hasPermission();

    _responseStream = _audioRecorder.onStateChanged().listen((recordState) {
      if (recordState == RecordState.record) {
        // 开启计时器
        _startTimer();
        //开始震动
        Vibration.vibrate(duration: 60);
      }
      _state.value = recordState;
    });

    _amplitudeStream = _audioRecorder
        .onAmplitudeChanged(const Duration(
      milliseconds: 100,
    ))
        .listen((amp) {
      double db = amp.current / amp.max;
      if (db >= 1) {
        return;
      }
      _dbList.value = _dbList.value.toList()..add(db);
    });
  }

  /// 开启计时器
  void _startTimer() {
    _stopTimer();
    // 开启倒计时
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _recordTime.value = _recordTime.value + 1;
      // 停止计时器
      if (_recordTime.value >= _maxTime) {
        stop();
      }
    });
  }

  /// 关闭计时器
  void _stopTimer() {
    _timer?.cancel();
  }

  /// 删除文件
  void _deleteFile(String? path) {
    if (path == null) {
      return;
    }
    final File file = File(path);
    file.exists().then((bool exist) {
      if (exist) {
        file.delete();
      }
    });
  }

  Future<bool> _isEncoderSupported(AudioEncoder encoder) async {
    final isSupported = await _audioRecorder.isEncoderSupported(
      encoder,
    );

    if (!isSupported) {
      debugPrint('${encoder.name} is not supported on this platform.');
      debugPrint('Supported encoders are:');

      for (final e in AudioEncoder.values) {
        if (await _audioRecorder.isEncoderSupported(e)) {
          debugPrint('- ${encoder.name}');
        }
      }
    }

    return isSupported;
  }

  /// 开始录音的方法
  void start() async {
    try {
      //  先停止播放
      MusicPlayer.instance.stop();
      // 检查权限
      bool isPermission = await _audioRecorder.hasPermission();
      if (!isPermission) {
        return;
      }
      const encoder = AudioEncoder.wav;

      if (!await _isEncoderSupported(encoder)) {
        return;
      }

      final devs = await _audioRecorder.listInputDevices();
      debugPrint(devs.toString());

      const config = RecordConfig(encoder: encoder, numChannels: 1);
      //开始录音
      _audioRecorder.start(config, path: await _getPath());
    } catch (_) {}
  }

  Future<String> _getPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(
      dir.path,
      'audio_${DateTime.now().millisecondsSinceEpoch}.wav',
    );
  }

  /// 停止录音方法
  Future<String?> stop() async {
    // 停止计时器
    _stopTimer();
    _filePath = await _audioRecorder.stop();
    if (_filePath != null) {
      double audioLength = _recordTime.value.toDouble(); // 录音时长
      if (audioLength < 1) {
        _deleteFile(_filePath);
        _filePath = null;
      }
    } else {
      _deleteFile(_filePath);
      _filePath == null;
    }
    _resetOptions();
    return _filePath;
  }

  ///重置参数
  void _resetOptions() {
    _recordTime.value = 0;
    _dbList.value = [];
    _state.value = RecordState.stop;
  }

  void dispose() {
    _responseStream?.cancel();
    _amplitudeStream?.cancel();
    stop();
  }
}
