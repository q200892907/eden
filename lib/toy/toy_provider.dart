import 'dart:async';

import 'package:eden/entities/toy_command_entity.dart';
import 'package:eden/utils/vibration_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'toy_provider.g.dart';

@Riverpod(keepAlive: true)
class ToyNotifier extends _$ToyNotifier {
  final List<ToyCommandEntity> _commands = [];
  Timer? _toyTimer;
  Timer? _roomToyTimer;

  /// 是否正在执行
  bool get isExecute => _isExecute;
  bool _isExecute = false;

  @override
  dynamic build() {
    // BleDevice?
    return null;
  }

  /// 获取blueDevice
  void _getBlueDevice() {
    //todo
    // state = ref.read(bleDeviceStateProvider);
  }

  /// 执行礼物震动
  bool command(ToyCommandEntity command) {
    _getBlueDevice();
    _isExecute = true;
    _commands.add(command);
    _execute();
    return true;
  }

  /// 真实执行
  void _execute() {
    if (_toyTimer != null) {
      return;
    }
    if (_commands.isNotEmpty) {
      if (_commands.first.realVibrations.isNotEmpty) {
        ToyVibrationCommandEntity vibrationCommand =
            _commands.first.realVibrations.first;
        // 如果连接了设备,设别震动,否则手机振动
        if (state != null && _commands.first.isToy) {
          state?.motor([vibrationCommand.value, vibrationCommand.value]);
        } else {
          int mobileVibrate = 255 * vibrationCommand.value ~/ 100;
          VibrationUtils.vibrate(
            amplitude: mobileVibrate,
            duration: vibrationCommand.duration.toInt(),
          );
        }
        _commands.first.realVibrations.remove(vibrationCommand);
        _toyTimer = Timer(
            Duration(milliseconds: vibrationCommand.duration.toInt()), () {
          _toyTimer?.cancel();
          _toyTimer = null;
          if (_commands.first.realVibrations.isEmpty) {
            _commands.removeAt(0);
          }
          //继续执行
          _execute();
        });
      } else {
        _commands.removeAt(0);
        _execute();
      }
    } else {
      stop();
    }
  }

  /// 停止
  bool stop() {
    _isExecute = false;
    _getBlueDevice();
    if (state == null) {
      return false;
    }
    state?.motor([0, 0]);
    _toyTimer?.cancel();
    _toyTimer = null;
    _commands.clear();
    return true;
  }

  /// 执行房间命令
  bool roomCommand(ToyRoomCommandEntity command) {
    _getBlueDevice();
    if (state == null) {
      return false;
    }
    _stopRoomTimer();
    _startRoomTimer();
    // 执行震动
    state?.motor(command.vibration);
    return true;
  }

  void _startRoomTimer() {
    _roomToyTimer ??= Timer(const Duration(milliseconds: 500), () {
      state?.motor([0, 0]);
    });
  }

  void _stopRoomTimer() {
    _roomToyTimer?.cancel();
    _roomToyTimer = null;
  }
}
