import 'dart:async';

import 'package:eden/utils/music_player.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';

class RecordUtil {
  factory RecordUtil() => _getInstance();

  static RecordUtil get instance => _getInstance();
  static RecordUtil? _instance;

  RecordUtil._internal();

  static RecordUtil _getInstance() {
    _instance ??= RecordUtil._internal();
    return _instance!;
  }

  late final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<RecordState>? _responseStream;
  StreamSubscription<Amplitude>? _amplitudeStream;
  final ValueNotifier<List<double>> _dbList = ValueNotifier([]);
  final ValueNotifier<RecordState> _state = ValueNotifier(RecordState.stop);
  final ValueNotifier<Amplitude> _amplitude = ValueNotifier(Amplitude(current: -160, max: -160));

  ValueNotifier<RecordState> get recordState => _state;

  ValueNotifier<Amplitude> get amplitude => _amplitude;

  void init() {
    _audioRecorder.hasPermission();

    _responseStream = _audioRecorder.onStateChanged().listen((recordState) {
      _state.value = recordState;
    });

    _amplitudeStream = _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 500)).listen((amp) {
      _amplitude.value = amp;
      double db = amp.current / amp.max;
      if (db >= 1) {
        return;
      }
      _dbList.value = _dbList.value.toList()..add(db);
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
  Future<void> start() async {
    try {
      //  先停止播放
      MusicPlayer.instance.stop();
      // 检查权限
      bool isPermission = await _audioRecorder.hasPermission();
      if (!isPermission) {
        return;
      }
      const encoder = AudioEncoder.aacLc;
      if (!await _isEncoderSupported(encoder)) {
        return;
      }
      final devs = await _audioRecorder.listInputDevices();
      debugPrint(devs.toString());
      const config = RecordConfig(encoder: encoder, numChannels: 1);
      //开始录音
      await _audioRecorder.startStream(config);
    } catch (_) {}
  }

  /// 停止录音方法
  Future<void> stop() async {
    await _audioRecorder.stop();
    await _audioRecorder.cancel();
    _resetOptions();
  }

  ///重置参数
  void _resetOptions() {
    _dbList.value = [];
    _state.value = RecordState.stop;
  }

  void dispose() {
    _responseStream?.cancel();
    _amplitudeStream?.cancel();
    stop();
  }

  static double scaleValue(double originalValue) {
    double aMin = -40.0; // 原始区间最小值
    double aMax = 0.0;   // 原始区间最大值
    double bMin = -160.0; // 目标区间最小值
    double bMax = 0.0;   // 目标区间最大值
    double proportion = (originalValue - aMin) / (aMax - aMin);
    double targetValue = bMin + (proportion * (bMax - bMin));
    return targetValue;
  }

  static double transformValue(double originalValue) {
    double aMin = -160.0;
    double aMax = 0.0;
    double bMin = 0.0;
    double bMax = 1.0;
    double result = (originalValue - aMin) / (aMax - aMin);
    return double.parse(result.toStringAsFixed(2));
  }
}
